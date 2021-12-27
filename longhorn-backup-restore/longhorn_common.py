import longhorn
import time
import json

RETRY_COUNTS = 300
RETRY_INTERVAL = 0.5

VOLUME_FIELD_STATE = "state"
VOLUME_STATE_ATTACHED = "attached"
VOLUME_STATE_DETACHED = "detached"

def wait_for_volume_creation(client, name):
    for i in range(RETRY_COUNTS):
        volumes = client.list_volume()
        found = False
        for volume in volumes:
            if volume.name == name:
                found = True
                break
        if found:
            break
        time.sleep(RETRY_INTERVAL)
    assert found

def wait_for_volume_status(client, name, key, value):
    wait_for_volume_creation(client, name)
    for i in range(RETRY_COUNTS):
        volume = client.by_id_volume(name)
        if volume[key] == value:
            break
        time.sleep(RETRY_INTERVAL)
    assert volume[key] == value
    return volume

def wait_for_volume_detached(client, name):
    return wait_for_volume_status(client, name,
                                  VOLUME_FIELD_STATE,
                                  VOLUME_STATE_DETACHED)

def wait_volume_kubernetes_status(client, volume_name, expect_ks):
    for i in range(RETRY_COUNTS):
        expected = True
        volume = client.by_id_volume(volume_name)
        ks = volume.kubernetesStatus
        ks = json.loads(json.dumps(ks, default=lambda o: o.__dict__))

        for k, v in expect_ks.items():
            if k in ('lastPVCRefAt', 'lastPodRefAt'):
                if (v != '' and ks[k] == '') or \
                   (v == '' and ks[k] != ''):
                    expected = False
                    break
            else:
                if ks[k] != v:
                    expected = False
                    break
        if expected:
            break
        time.sleep(RETRY_INTERVAL)
    assert expected


def create_pv_for_volume(client, volume, pv_name, fs_type="ext4"):
    volume.pvCreate(pvName=pv_name, fsType=fs_type)
    ks = {
        'pvName': pv_name,
        'pvStatus': 'Available',
        'namespace': '',
        'lastPVCRefAt': '',
        'lastPodRefAt': '',
    }
    wait_volume_kubernetes_status(client, volume.name, ks)

def create_pvc_for_volume(client, pvcNs, volume, pvc_name):
    volume.pvcCreate(namespace=pvcNs, pvcName=pvc_name)

    ks = {
        'pvStatus': 'Bound',
        'namespace': 'default',
        'lastPVCRefAt': '',
    }
    wait_volume_kubernetes_status(client, volume.name, ks)
