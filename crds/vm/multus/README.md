# Getting pcie id's of devices
You can get pcie of devices with command `lshw -class network -businfo`  
Example output below:  
```
Bus info          Device     Class          Description
=======================================================
pci@0000:06:12.0             network
virtio@2          eth0       network        Ethernet interface
pci@0000:06:13.0             network
virtio@4          eth1       network        Ethernet interface
pci@0000:06:14.0             network
virtio@5          eth2       network        Ethernet interface
pci@0000:06:15.0             network
virtio@6          eth3       network        Ethernet interface
```