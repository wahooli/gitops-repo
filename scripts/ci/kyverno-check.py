#!/usr/bin/env python3
import base64
import glob
import os
import re
import subprocess
import sys
import tempfile

import yaml

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
WORKLOADS = {"Deployment", "StatefulSet", "DaemonSet", "Job", "CronJob", "Pod"}
SKIPPED_NAMESPACES = {"kube-system", "kyverno"}
VAR = re.compile(r"(\$?)\$\{([_a-zA-Z][_a-zA-Z0-9]*)(?::=([^}]*))?\}")

yaml.SafeLoader.add_constructor("tag:yaml.org,2002:value", lambda loader, node: loader.construct_scalar(node))


def load_all(text):
    return [d for d in yaml.safe_load_all(text) if isinstance(d, dict)]


def substitute(doc, variables):
    ann = (doc.get("metadata") or {}).get("annotations") or {}
    if ann.get("kustomize.toolkit.fluxcd.io/substitute") == "disabled":
        return doc

    def repl(m):
        if m.group(1):
            return m.group(0)[1:]
        return variables.get(m.group(2), m.group(3) if m.group(3) is not None else "")

    return yaml.safe_load(VAR.sub(repl, yaml.safe_dump(doc, width=1 << 20)))


def kustomize(path):
    out = subprocess.run(["kubectl", "kustomize", "--load-restrictor", "LoadRestrictionsNone", path],
                         capture_output=True, text=True, check=True)
    return load_all(out.stdout)


def build_path(path):
    if os.path.exists(os.path.join(path, "kustomization.yaml")):
        return kustomize(path)
    docs = []
    for dp, dns, fs in os.walk(path):
        if "kustomization.yaml" in fs:
            docs += kustomize(dp)
            dns[:] = []
            continue
        for f in sorted(fs):
            if f.endswith((".yaml", ".yml")):
                docs += load_all(open(os.path.join(dp, f)).read())
    return docs


def tenant_sources(tenant):
    sources = {}
    for f in glob.glob(os.path.join(REPO, "local-clusters", tenant, "bootstrap", "**", "*.y*ml"), recursive=True):
        for d in load_all(open(f).read()):
            if d.get("kind") not in ("Secret", "ConfigMap"):
                continue
            values = dict(d.get("stringData") or {})
            for k, v in (d.get("data") or {}).items():
                values[k] = base64.b64decode(v).decode() if d["kind"] == "Secret" else v
            sources[(d["kind"], d["metadata"]["name"])] = values
    return sources


def prune_nulls(o):
    if isinstance(o, dict):
        return {k: prune_nulls(v) for k, v in o.items() if v is not None}
    if isinstance(o, list):
        return [prune_nulls(v) for v in o if v is not None]
    return o


def merge(a, b):
    for k, v in b.items():
        if isinstance(v, dict) and isinstance(a.get(k), dict):
            merge(a[k], v)
        else:
            a[k] = v
    return a


def render_helmrelease(hr, objects, repos, workdir):
    spec = hr["spec"]
    values = {}
    for ref in spec.get("valuesFrom") or []:
        src = objects.get((ref["kind"], hr["metadata"].get("namespace"), ref["name"]))
        if src is None:
            if ref.get("optional"):
                continue
            raise RuntimeError(f'{hr["metadata"]["name"]}: missing {ref["kind"]}/{ref["name"]}')
        data = dict(src.get("stringData") or {})
        for k, v in (src.get("data") or {}).items():
            data[k] = base64.b64decode(v).decode() if ref["kind"] == "Secret" else v
        text = data.get(ref.get("valuesKey", "values.yaml"))
        if text is None:
            if ref.get("optional"):
                continue
            raise RuntimeError(f'{hr["metadata"]["name"]}: missing key in {ref["name"]}')
        merge(values, yaml.safe_load(text) or {})
    merge(values, spec.get("values") or {})

    chart = spec["chart"]["spec"]
    repo = repos[chart["sourceRef"]["name"]]
    namespace = spec.get("targetNamespace") or hr["metadata"]["namespace"]
    release = spec.get("releaseName") or (f'{spec["targetNamespace"]}-{hr["metadata"]["name"]}'
                                          if spec.get("targetNamespace") else hr["metadata"]["name"])
    url = repo["url"]
    ref = f'{url.rstrip("/")}/{chart["chart"]}' if url.startswith("oci://") else chart["chart"]
    args = ["helm", "template", release, ref, "-n", namespace]
    if not url.startswith("oci://"):
        args += ["--repo", url]
    version = chart.get("version", "")
    if version:
        args += ["--version", version]
        if any(c in version for c in "<>=*xX ^~-"):
            args += ["--devel"]
    values_file = os.path.join(workdir, "values.yaml")
    with open(values_file, "w") as f:
        yaml.safe_dump(values, f)
    out = subprocess.run(args + ["-f", values_file], capture_output=True, text=True)
    if out.returncode:
        raise RuntimeError(f'{hr["metadata"]["name"]}: helm template failed: {out.stderr.strip()[:400]}')
    docs = [d for d in load_all(out.stdout)
            if "test" not in ((d.get("metadata") or {}).get("annotations") or {}).get("helm.sh/hook", "")]
    for d in docs:
        d["metadata"].setdefault("namespace", namespace)

    patches = [p for r in spec.get("postRenderers") or [] for p in (r.get("kustomize") or {}).get("patches") or []]
    if patches:
        pr = os.path.join(workdir, "postrender")
        os.makedirs(pr, exist_ok=True)
        with open(os.path.join(pr, "rendered.yaml"), "w") as f:
            yaml.safe_dump_all(docs, f)
        with open(os.path.join(pr, "kustomization.yaml"), "w") as f:
            yaml.safe_dump({"apiVersion": "kustomize.config.k8s.io/v1beta1", "kind": "Kustomization",
                            "resources": ["rendered.yaml"], "patches": patches}, f)
        docs = kustomize(pr)
    return docs


def scaledjob_to_job(sj):
    return {"apiVersion": "batch/v1", "kind": "Job",
            "metadata": {"name": sj["metadata"]["name"], "namespace": sj["metadata"].get("namespace", "default"),
                         "labels": sj["metadata"].get("labels") or {}},
            "spec": sj["spec"]["jobTargetRef"]}


def main():
    tenant = sys.argv[1]
    cluster_dir = os.path.join(REPO, "clusters", tenant)
    os.chdir(REPO)
    sources = tenant_sources(tenant)
    overrides_file = os.path.join(REPO, "local-clusters", tenant, "kyverno-check-vars.yaml")
    overrides = yaml.safe_load(open(overrides_file)) if os.path.exists(overrides_file) else {}

    built = []
    for f in sorted(glob.glob(os.path.join(cluster_dir, "*.yaml"))):
        for ks in load_all(open(f).read()):
            if ks.get("kind") != "Kustomization" or not ks.get("apiVersion", "").startswith("kustomize.toolkit"):
                continue
            post = ks["spec"].get("postBuild") or {}
            variables = {}
            for src in post.get("substituteFrom") or []:
                variables.update(sources.get((src["kind"], src["name"]), {}))
            variables.update(post.get("substitute") or {})
            variables.update(overrides or {})
            built += [substitute(d, variables) for d in build_path(ks["spec"]["path"])]

    objects = {(d["kind"], d["metadata"].get("namespace"), d["metadata"]["name"]): d
               for d in built if d.get("kind") in ("ConfigMap", "Secret")}
    repos = {d["metadata"]["name"]: d["spec"] for d in built if d.get("kind") == "HelmRepository"}
    policies = [d for d in built if d.get("kind") == "ValidatingPolicy"]
    exceptions = [d for d in built if d.get("kind") == "PolicyException"]
    if not policies:
        print(f"{tenant}: no Kyverno policies, skipping")
        return 0

    keep = bool(os.environ.get("KYVERNO_CHECK_KEEP"))
    with tempfile.TemporaryDirectory(delete=not keep) as tmp:
        if keep:
            print(f"working dir: {tmp}")
        resources = [d for d in built if d.get("kind") in WORKLOADS]
        resources += [scaledjob_to_job(d) for d in built if d.get("kind") == "ScaledJob"]
        errors = []
        for hr in (d for d in built if d.get("kind") == "HelmRelease"):
            try:
                with tempfile.TemporaryDirectory(dir=tmp) as work:
                    resources += [d for d in render_helmrelease(hr, objects, repos, work) if d.get("kind") in WORKLOADS]
            except (RuntimeError, KeyError) as e:
                errors.append(str(e))
        resources = [prune_nulls(d) for d in resources if d["metadata"].get("namespace", "default") not in SKIPPED_NAMESPACES]

        res_dir = os.path.join(tmp, "resources")
        os.makedirs(res_dir)
        for i, d in enumerate(resources):
            with open(os.path.join(res_dir, f'{i:04d}-{d["kind"]}-{d["metadata"]["name"]}.yaml'), "w") as f:
                yaml.safe_dump(d, f)
        args = ["kyverno", "apply"]
        for i, p in enumerate(policies):
            path = os.path.join(tmp, f"policy-{i}.yaml")
            yaml.safe_dump(p, open(path, "w"))
            args.append(path)
        for i, e in enumerate(exceptions):
            path = os.path.join(tmp, f"exception-{i}.yaml")
            yaml.safe_dump(e, open(path, "w"))
            args += ["--exception", path]
        args += ["--resource", res_dir]
        out = subprocess.run(args, capture_output=True, text=True)

    print(f"{tenant}: {len(resources)} workloads, {len(policies)} policies, {len(exceptions)} exceptions")
    for e in errors:
        print(f"render error: {e}")
    lines = (out.stdout + "\n" + out.stderr).splitlines()
    failures = [l for l in lines if re.match(r"^policy .* -> resource .* (failed|error)", l, re.I)
                or (re.search(r"\berror\b", l, re.I) and not l.startswith("pass:"))]
    for l in failures:
        print(l)
    summary = [l for l in out.stdout.splitlines() if l.startswith("pass:")]
    print(summary[-1] if summary else out.stdout[-2000:] + out.stderr[-2000:])
    m = re.search(r"fail: (\d+).*error: (\d+)", summary[-1]) if summary else None
    if errors or not m or int(m.group(1)) or int(m.group(2)):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
