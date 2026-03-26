SCRIPTS_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))scripts
CLUSTER := $(word 2, $(MAKECMDGOALS))

.PHONY: deploy create bootstrap down artifact verify verify-kustomization verify-helmrelease verify-workload lint help mesh

help:
	@echo "Usage:"
	@echo "  make deploy <cluster>              Create cluster and bootstrap Flux"
	@echo "  make deploy mesh                   Deploy all clusters and connect via ClusterMesh"
	@echo "  make create <cluster>              Create k3d cluster only"
	@echo "  make bootstrap <cluster>           Bootstrap Flux only"
	@echo "  make down [cluster]                Delete k3d cluster (all if omitted)"
	@echo "  make artifact                      Push manifests to OCI registry"
	@echo "  make verify <cluster>              Verify kustomizations and helmreleases"
	@echo "  make verify mesh                   Deploy mesh and verify all clusters"
	@echo "  make verify-kustomization <cluster> Verify Flux kustomization reconciliation"
	@echo "  make verify-helmrelease <cluster>   Verify HelmRelease reconciliation"
	@echo "  make verify-workload <cluster>      Verify all workloads are healthy"
	@echo "  make lint                          Run yamllint across the repo"
	@echo ""
	@echo "Available clusters:"
	@for dir in clusters/*/; do echo "  $$(basename $$dir)"; done

deploy: $(if $(filter mesh,$(CLUSTER)),,_require-cluster)
ifeq ($(CLUSTER),mesh)
	@$(SCRIPTS_DIR)/deploy-mesh.sh
else
	@$(SCRIPTS_DIR)/create-cluster.sh $(CLUSTER)
	@$(SCRIPTS_DIR)/bootstrap-flux.sh $(CLUSTER)
endif

create: _require-cluster
	@$(SCRIPTS_DIR)/create-cluster.sh $(CLUSTER)

bootstrap: _require-cluster
	@$(SCRIPTS_DIR)/bootstrap-flux.sh $(CLUSTER)

down:
ifdef CLUSTER
	@$(SCRIPTS_DIR)/delete-cluster.sh $(CLUSTER)
else
	@for dir in local-clusters/*/; do \
		[ -d "$$dir" ] || continue; \
		cluster=$$(basename "$$dir"); \
		$(SCRIPTS_DIR)/delete-cluster.sh "$$cluster"; \
	done
endif

artifact:
	@$(SCRIPTS_DIR)/create-artifact.sh

lint:
	@yamllint .

verify: $(if $(filter mesh,$(CLUSTER)),,_require-cluster _ensure-cluster)
ifeq ($(CLUSTER),mesh)
	@$(MAKE) deploy mesh
	@for dir in local-clusters/*/; do \
		[ -d "$$dir" ] || continue; \
		name=$$(basename "$$dir"); \
		[ "$${name#_}" = "$$name" ] && [ "$${name#.}" = "$$name" ] || continue; \
		[ -f "$$dir/k3d-config.yaml" ] || continue; \
		[ -d "clusters/$$name" ] || continue; \
		echo "Verifying $$name..."; \
		CONTEXT=k3d-$$name $(SCRIPTS_DIR)/verify-kustomizations.sh $$name || exit 1; \
		CONTEXT=k3d-$$name $(SCRIPTS_DIR)/verify-helmreleases.sh $$name || exit 1; \
		CONTEXT=k3d-$$name $(SCRIPTS_DIR)/verify-workloads.sh $$name || exit 1; \
	done
else
	@CONTEXT=k3d-$(CLUSTER) $(SCRIPTS_DIR)/verify-kustomizations.sh $(CLUSTER)
	@CONTEXT=k3d-$(CLUSTER) $(SCRIPTS_DIR)/verify-helmreleases.sh $(CLUSTER)
	@CONTEXT=k3d-$(CLUSTER) $(SCRIPTS_DIR)/verify-workloads.sh $(CLUSTER)
endif

verify-kustomization: _require-cluster
	@CONTEXT=k3d-$(CLUSTER) $(SCRIPTS_DIR)/verify-kustomizations.sh $(CLUSTER)

verify-helmrelease: _require-cluster
	@CONTEXT=k3d-$(CLUSTER) $(SCRIPTS_DIR)/verify-helmreleases.sh $(CLUSTER)

verify-workload: _require-cluster
	@CONTEXT=k3d-$(CLUSTER) $(SCRIPTS_DIR)/verify-workloads.sh $(CLUSTER)

_ensure-cluster:
	@k3d cluster get $(CLUSTER) >/dev/null 2>&1 || $(MAKE) deploy $(CLUSTER)

_require-cluster:
ifndef CLUSTER
	$(error Cluster name required. Usage: make $(MAKECMDGOALS) <cluster-name>)
endif
ifeq ($(wildcard clusters/$(CLUSTER)),)
	$(error Unknown cluster '$(CLUSTER)'. Run 'make help' to see available clusters)
endif

mesh:
	@:

# Swallow cluster name argument so Make doesn't treat it as a target
%:
	@:
