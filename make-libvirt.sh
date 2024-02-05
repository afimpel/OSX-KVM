#!/usr/bin/env bash
if [ -z "$1" ]; then
  CHANGEram=4194304
else
  CHANGEram=$(( $1 * 1048576))
fi
CHANGEramGB=$(( ( $CHANGEram / 1024 ) / 1024 ));
macaddr=$(echo $FQDN|md5sum|sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/')
CHANGEramGB=$(( ( $CHANGEram / 1024 ) / 1024 ));
echo "RAM: $CHANGEramGB GB / MAC ADDR: $macaddr / UUID: ${UUID}";
UUID=$(cat /proc/sys/kernel/random/uuid)
sed "s/CHANGEME/$USER/g" macOS-libvirt.xml > macOS00.xml
sed "s/CHANGEramGB/$CHANGEramGB/g" macOS00.xml > macOS01.xml
sed "s/CHANGEram/$CHANGEram/g" macOS01.xml > macOS02.xml
sed "s/CHANGEuuid/$UUID/g" macOS02.xml > macOS03.xml
sed "s/changeMacADDR/$macaddr/g" macOS03.xml > macOS_${UUID}.xml
virt-xml-validate macOS_${CHANGEramGB}G.xml
sudo setfacl -m u:libvirt-qemu:rx /home/$USER
sudo setfacl -R -m u:libvirt-qemu:rx /home/$USER/OSX-KVM
virsh --connect qemu:///system define macOS_${CHANGEramGB}G.xml
rm macOS0*.xml