Restores PV & PVC from backup. Created for FluxCD startup. Created with [Longhorn python client](https://longhorn.io/docs/1.2.2/references/longhorn-client-python/).  

## Environment variables  

**LONGHORN_URL**  
Point to longhorn frontend, ie. "http://longhorn-frontend.longhorn-system/v1". Required  

**VOLUME_HANDLE**  
Longhorn volume handle name. Searches backups with volume name. Required  

**VOLUME_SIZE**  
Optional. Restored volume size in bytes. I don't recommend messing with this, I'm too lazy for creating parsing logic. Reads from backup kubernetesStatus if not defined  

**PV_NAME**  
Kubernetes persistent volume name. Creates on restore. Optional, reads from backup kubernetesStatus if not defined  

**PVC_NAME**  
Kubernetes persistent volume claim name. Creates on restore. Optional, reads from backup kubernetesStatus if not defined  

**PVC_NAMESPACE**  
Kubernetes namespace for pvc. Optional

**CREATE_PV**  
Create persistent volume during restoration? Defaults to "true"  

**CREATE_PVC**  
Create persistent volume claim during restoration? Defaults to "true"  

## Example kubernetes job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: homebridge-data-restore
  namespace: iot
spec:
  template:
    spec:
      containers:
      - name: pi
        image: wahooli/longhorn-backup-restore:latest
        env:
        - name: LONGHORN_URL
          value: http://longhorn-frontend.longhorn-system/v1 # default, can be omitted
        - name: VOLUME_HANDLE
          value: [volume-handle-name-here]
        - name: CREATE_PV
          value: "false" # will not create persistent volume and claims
        - name: CREATE_PVC
          value: "false"
      restartPolicy: Never
  backoffLimit: 0

```

## Bulk image
There's also `bulk-latest` image tag, which accepts everything else, except LONGHORN_URL configuration as json. 