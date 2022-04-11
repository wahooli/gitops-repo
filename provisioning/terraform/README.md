### notes
I had to disable ipv6 on cloud-init image. copied following file to /etc/sysctl.d/ with virt-copy-in

```
net.ipv6.conf.all.disable_ipv6     = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6      = 1
```

also added to debian cloudinit base image

/etc/dhcp/dhclient-exit-hooks.d/disable-routes-hook
```
#!/bin/sh
## Prevent DHCP server on adding new default routes on specific subnets

case ${new_routers} in
  [gateway_ip].*)
     printf "executing ip route delete default via $new_routers\n"
     ip route delete default via $new_routers
  ;;
  192.168.2.*)
     printf "executing ip route delete default via $new_routers\n"
     ip route delete default via $new_routers
  ;;
  192.168.1.*)
     printf "executing ip route delete default via $new_routers\n"
     ip route delete default via $new_routers
  ;;
     *)
  ;;
esac
```