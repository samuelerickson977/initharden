# initharden
## A hardening script for Ubuntu 22.04 x86-64

### Description
initharden is a project aimed at quickly hardening Ubuntu 22.04
x86-64. One can quickly harden their new OS install by running 
the `harden.sh` script and adding the recommended kernel command 
line parameters to grub.

### Quick Start
Run the following commands to get quickly started:
```bash
chmod +x harden.sh
./harden.sh
```

### Harden Kernel Command Line Parameters
You may harden the kernel command line parameters by editing 
`/etc/default/grub`.

Change `GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"` to be the following:
```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash powersave=off libata.ignore_hpa=1 
intel_iommu=on,strict iommu=force,nobypass,nopt iommu.passthrough=0 
intremap=on iomem=strict iommu.forcedac=1 iommu.strict=1 
sysctl.kernel.kexec_load_disabled=1 pti=on page_poison=1 slub_debug=FZP 
hardened_usercopy=on disable_ipv6=1 slab_nomerge init_on_free=1 init_on_alloc=1 
lsm=landlock,yama,apparmor vsyscall=none random.trust_cpu=on 
page_alloc.shuffle=1 module.sig_enforce=1 ipv6.disable=1 
module_blacklist='ipv6,firewire,firewire-core,can,atm,mei,dccp,sctp,rds,tipc,
n-hdlc,ax25,netrom,x25,rose,decnet,econet,af_802154,ipx,appletalk,psnap,p8023,
p8022,cramfs,freevxfs,jffs2,udf,cifs,nfs,nfsv3,nfsv4,gfs2,vivid,uvcvideo,qnx4,
jfs,hfs,hfsplus,ufs' integrity_audit=1 spectre_v2=on 
spec_store_bypass_disable=on tsx=off tsx_async_abort=full,nosmt mds=full,nosmt 
l1tf=full,force srbds=on stack_guard_gap=512 ssbd=force-on l1d_flush=on 
spectre_v2_user=on debugfs=off randomize_kstack_offset=on"
```

After saving the changes to `/etc/default/grub`, run the following command:
```bash
sudo update-grub
```

A reboot is required for the changes to take effect.

See https://www.kernel.org/doc/html/v4.14/admin-guide/kernel-parameters.html 
for more details.

### More Software
#### Intrusion Detection Systems
I have found both snort and suricata very useful in the past. Snort is more
of an intrusion detection system (IDS), while suricata is also capable
of being an intrusion prevention system (IPS). Suricata supports higher
traffic throughput due to its multi-threading capabilities. However,
this functionality also makes suricata more complex than snort, and
snort is also more of a mature product.

The nice thing about suricata is that it can also be used in specialized
environments that make traffic inspection even faster. I have personally
used suricata with a Myricom NIC that is able to offload some traffic
inspection to the NIC itself. I was able to adequately inspect all traffic
using all available rules while maintaining an 800 Mbps internet connection
speed.

More information about suricata and snort can be found at:
- https://suricata.io/
- https://www.snort.org/

### Contributing
Suggestions and pull requests are always welcomed and appreciated.
