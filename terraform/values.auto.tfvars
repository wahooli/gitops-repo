masters = {
  "k3s-master-01" = {
    id              = 600
    cores			      = 4
    memory			    = 4096
    net_cidr		    = "10.3.0.7/24"
    net_gw			    = "10.3.0.253"
    net_bridge		  = "vmbr150"
    storage_cidr	  = "10.2.0.200/25"
    storage_bridge	= "vmbr140"
    target_node		  = "pitfall"
    disk_size		    = "50G"
    disk_storage	  = "nvme-mirror"
  },
  "k3s-master-02" = {
    id              = 601
    cores			      = 4
    memory			    = 4096
    net_cidr		    = "10.3.0.8/24"
    net_gw			    = "10.3.0.253"
    net_bridge		  = "vmbr150"
    storage_cidr	  = "10.2.0.201/25"
    storage_bridge	= "vmbr140"
    target_node		  = "berzerk"
    disk_size		    = "50G"
    disk_storage	  = "nvme-mirror"
  },
  "k3s-master-03" = {
    id              = 602
    cores			      = 4
    memory			    = 4096
    net_cidr		    = "10.3.0.9/24"
    net_gw			    = "10.3.0.253"
    net_bridge		  = "vmbr150"
    storage_cidr	  = "10.2.0.202/25"
    storage_bridge	= "vmbr140"
    target_node		  = "solaris"
    disk_size		    = "50G"
    disk_storage	  = "nvme-mirror"
  }
}

workers = {
  "k3s-worker-01" = {
    id              = 603
    cores			      = 8
    memory			    = 16384
    net_cidr		    = "10.3.0.10/24"
    net_gw			    = "10.3.0.253"
    net_bridge		  = "vmbr150"
    storage_cidr	  = "10.2.0.203/25"
    storage_bridge	= "vmbr140"
    target_node		  = "berzerk"
    disk_size		    = "50G"
    disk_storage	  = "nvme-mirror"
  },
  "k3s-worker-02" = {
    id              = 604
    cores			      = 8
    memory			    = 16384
    net_cidr		    = "10.3.0.11/24"
    net_gw			    = "10.3.0.253"
    net_bridge		  = "vmbr150"
    storage_cidr	  = "10.2.0.204/25"
    storage_bridge	= "vmbr140"
    target_node		  = "pitfall"
    disk_size		    = "50G"
    disk_storage	  = "nvme-mirror"
  },
  "k3s-worker-03" = {
    id              = 605
    cores			      = 8
    memory			    = 16384
    net_cidr		    = "10.3.0.12/24"
    net_gw			    = "10.3.0.253"
    net_bridge		  = "vmbr150"
    storage_cidr	  = "10.2.0.205/25"
    storage_bridge	= "vmbr140"
    target_node		  = "solaris"
    disk_size		    = "50G"
    disk_storage	  = "nvme-mirror"
  }
}