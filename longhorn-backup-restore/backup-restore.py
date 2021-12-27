import longhorn
import longhorn_common
import os
import json
from hurry.filesize import size
from pprint import pprint

# If automation/scripting tool is inside the same cluster in which Longhorn is installed
longhornUrl = os.getenv('LONGHORN_URL')
volumeHandle = os.getenv('VOLUME_HANDLE')
volumeSize = os.getenv('VOLUME_SIZE')
pvName = os.getenv('PV_NAME')
pvcName = os.getenv('PVC_NAME')
pvcNamespace = os.getenv('PVC_NAMESPACE')
createPV = str(os.getenv('CREATE_PV')).lower()
createPVC = str(os.getenv('CREATE_PVC')).lower()

client = longhorn.Client(url=longhornUrl)
existingVolume = client.by_id_volume(id=volumeHandle)
if not existingVolume:
    print("Volume handle \"%s\" not found, restoring" % volumeHandle)
    bv = client.by_id_backupVolume(id=volumeHandle)
    lastBackup = bv.backupGet(name=bv.lastBackupName)
    if not volumeSize:
        volumeSize = bv.size
    url = lastBackup.url
    kStatus = json.loads(lastBackup.labels.KubernetesStatus)
    if not pvName:
        pvName = kStatus["pvName"]
    if not pvcName:
        pvcName = kStatus["pvcName"]
    if not pvcNamespace:
        pvcNamespace = kStatus["namespace"]
    client.create_volume(name=volumeHandle, size=volumeSize,
                            fromBackup=url)
    volume = longhorn_common.wait_for_volume_detached(client, volumeHandle)
    print("Restored volume %s" % volumeHandle)
    if createPV != "false":
        longhorn_common.create_pv_for_volume(client, volume, pvName)
        print("Restored PersistentVolume %s" % pvName)
    # if createPV != "false" and createPVC != "false": # persistent volume is required to create pvc
    if createPVC != "false":
        longhorn_common.create_pvc_for_volume(client, pvcNamespace, volume, pvcName)
        print("Restored PersistentVolumeClaim %s" % pvcNamespace)
else:
    print("Volume handle %s exists, skipping" % volumeHandle)
