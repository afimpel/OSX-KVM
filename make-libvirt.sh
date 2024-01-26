#!/usr/bin/env bash
if [ -z "$1" ]; then
  CHANGEram=4194304
else
  CHANGEram=$(( $1 * 1048576))
fi
CHANGEramGB=$(( ( $CHANGEram / 1024 ) / 1024 ));
echo "RAM: $CHANGEramGB GB";
UUID=$(cat /proc/sys/kernel/random/uuid)
sed "s/CHANGEME/$USER/g" macOS-libvirt.xml > macOS00.xml
sed "s/CHANGEramGB/$CHANGEramGB/g" macOS00.xml > macOS01.xml
sed "s/CHANGEram/$CHANGEram/g" macOS01.xml > macOS02.xml
sed "s/CHANGEuuid/$UUID/g" macOS02.xml > macOS.xml
virt-xml-validate macOS.xml
sudo setfacl -m u:libvirt-qemu:rx /home/$USER
sudo setfacl -R -m u:libvirt-qemu:rx /home/$USER/OSX-KVM
virsh --connect qemu:///system define macOS.xml
rm macOS0*.xml