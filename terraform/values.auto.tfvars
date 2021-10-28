masters = {
  "k8s-master-01" = {
    id              = 500
    cores			      = 4
    memory			    = 8192
    net_cidr		    = "10.3.0.1/24"
    net_gw			    = "10.3.0.253"
    net_bridge		  = "vmbr150"
    storage_cidr	  = "10.2.0.195/25"
    storage_bridge	= "vmbr140"
    target_node		  = "pitfall"
    disk_size		    = "50G"
    disk_storage	  = "nvme-mirror"
  }
}

workers = {
  "k8s-worker-01" = {
    id              = 501
    cores			      = 8
    memory			    = 16384
    net_cidr		    = "10.3.0.2/24"
    net_gw			    = "10.3.0.253"
    net_bridge		  = "vmbr150"
    storage_cidr	  = "10.2.0.196/25"
    storage_bridge	= "vmbr140"
    target_node		  = "berzerk"
    disk_size		    = "50G"
    disk_storage	  = "nvme-mirror"
  },
  "k8s-worker-02" = {
    id              = 502
    cores			      = 8
    memory			    = 16384
    net_cidr		    = "10.3.0.3/24"
    net_gw			    = "10.3.0.253"
    net_bridge		  = "vmbr150"
    storage_cidr	  = "10.2.0.197/25"
    storage_bridge	= "vmbr140"
    target_node		  = "pitfall"
    disk_size		    = "50G"
    disk_storage	  = "nvme-mirror"
  },
  "k8s-worker-03" = {
    id              = 503
    cores			      = 8
    memory			    = 16384
    net_cidr		    = "10.3.0.4/24"
    net_gw			    = "10.3.0.253"
    net_bridge		  = "vmbr150"
    storage_cidr	  = "10.2.0.198/25"
    storage_bridge	= "vmbr140"
    target_node		  = "solaris"
    disk_size		    = "50G"
    disk_storage	  = "nvme-mirror"
  }
}