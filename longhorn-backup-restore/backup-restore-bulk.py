import longhorn
import longhorn_common
import os
import json
from hurry.filesize import size
from pprint import pprint

# If automation/scripting tool is inside the same cluster in which Longhorn is installed
with open(os.getenv('CONFIG_PATH')) as json_file:
    jsonData = json.load(json_file)
    longhornUrl = os.getenv('LONGHORN_URL')
    client = longhorn.Client(url=longhornUrl)

    for volumeHandle in jsonData: 
        existingVolume = client.by_id_volume(id=volumeHandle)
        if not existingVolume:
            createPV = True
            createPVC = True
            if "createPV" in jsonData[volumeHandle]:
                createPV = jsonData[volumeHandle]["createPV"]
            if "createPVC" in jsonData[volumeHandle]:
                createPVC = jsonData[volumeHandle]["createPVC"]

            print("Volume handle \"%s\" not found, restoring" % volumeHandle)
            bv = client.by_id_backupVolume(id=volumeHandle)
            lastBackup = bv.backupGet(name=bv.lastBackupName)
            if "size" in jsonData[volumeHandle]:
                volumeSize = jsonData[volumeHandle]["size"]
            else:
                volumeSize = bv.size
            url = lastBackup.url
            kStatus = json.loads(lastBackup.labels.KubernetesStatus)

            if "pvName" in jsonData[volumeHandle]:
                pvName = jsonData[volumeHandle]["pvName"]
            else:
                pvName = kStatus["pvName"]

            if "pvcName" in jsonData[volumeHandle]:
                pvcName = jsonData[volumeHandle]["pvcName"]
            else:
                pvcName = kStatus["pvcName"]
            
            if "pvcNamespace" in jsonData[volumeHandle]:
                pvcNamespace = jsonData[volumeHandle]["pvcNamespace"]
            else:
                pvcNamespace = kStatus["namespace"]

            client.create_volume(name=volumeHandle, size=volumeSize,
                                    fromBackup=url)
            volume = longhorn_common.wait_for_volume_detached(client, volumeHandle)
            print("Restored volume %s" % volumeHandle)
            if createPV:
                longhorn_common.create_pv_for_volume(client, volume, pvName)
                print("Restored PersistentVolume %s" % pvName)
            if createPVC:
                longhorn_common.create_pvc_for_volume(client, pvcNamespace, volume, pvcName)
                print("Restored PersistentVolumeClaim %s" % pvcNamespace)
        else:
            print("Volume handle %s exists, skipping" % volumeHandle)
