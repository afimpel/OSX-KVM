### Note

This `README.md` documents the process of creating a `Virtual Hackintosh`
system.

Working with `Proxmox` and macOS? See [Nick's blog for sure](https://www.nicksherlock.com/).

Yes, we support offline macOS installations now - see [this document](./run_offline.md) 🎉

### Requirements

* A modern Linux distribution. E.g. Ubuntu 22.04 LTS 64-bit or later.

* QEMU >= 6.2.0

* A CPU with Intel VT-x / AMD SVM support is required (`grep -e vmx -e svm /proc/cpuinfo`)

* A CPU with SSE4.1 support is required for >= macOS Sierra

* A CPU with AVX2 support is required for >= macOS Mojave

Note: Older AMD CPU(s) are known to be problematic but modern AMD Ryzen
processors work just fine (even for macOS Sonoma).


### Installation Preparation

* Install QEMU and other packages.

  ```bash
  sudo apt-get install qemu uml-utilities virt-manager git \
      wget libguestfs-tools p7zip-full make dmg2img tesseract-ocr \
      tesseract-ocr-eng genisoimage -y
  ```

  This step may need to be adapted for your Linux distribution.

* Clone this repository on your QEMU system. Files from this repository are
  used in the following steps.

  ```bash
  cd ~ ### important

  git clone --depth 1 --recursive https://github.com/afimpel/OSX-KVM.git

  cd OSX-KVM
  ```

  Repository updates can be pulled via the following command:

  ```bash
  git pull --rebase
  ```

  This repository uses rebase based workflows heavily.

* KVM may need the following tweak on the host machine to work.

  ```bash
  sudo modprobe kvm; 
  echo 1 | sudo tee /sys/module/kvm/parameters/ignore_msrs
  ```

  To make this change permanent, you may use the following command.

  ```bash
  sudo cp kvm.conf /etc/modprobe.d/kvm.conf  # for intel boxes only

  sudo cp kvm_amd.conf /etc/modprobe.d/kvm.conf  # for amd boxes only
  ```

* Add user to the `kvm` and `libvirt` groups (might be needed).

  ```bash
  sudo systemctl enable --now libvirtd
  sudo systemctl enable --now virtlogd
  sudo usermod -aG kvm $(whoami)
  sudo usermod -aG libvirt $(whoami)
  sudo usermod -aG input $(whoami)
  ```

  Note: Reboot after executing this command.

* Fetch macOS installer.

  ```bash
  ./fetch-macOS-v2.py
  ```

  You can choose your desired macOS version here. After executing this step,
  you should have the `BaseSystem.dmg` file in the current folder.

  ATTENTION: Let `>= Big Sur` setup sit at the `Country Selection` screen, and
  other similar places for a while if things are being slow. The initial macOS
  setup wizard will eventually succeed.

  Sample run:

  ```
  $ ./fetch-macOS-v2.py
  1. High Sierra (10.13)
  2. Mojave (10.14)
  3. Catalina (10.15)
  4. Big Sur (11.7)
  5. Monterey (12.6)
  6. Ventura (13) - RECOMMENDED
  7. Sonoma (14)

  Choose a product to download (1-6): 6
  ```

  Note: Modern NVIDIA GPUs are supported on HighSierra but not on later
  versions of macOS.

* Convert the downloaded `BaseSystem.dmg` file into the `BaseSystem.img` file.

  ```bash
  dmg2img -i BaseSystem.dmg BaseSystem.img
  rm BaseSystem.dmg
  ```

* Create a virtual HDD image where macOS will be installed. If you change the
  name of the disk image from `MyDisk.qcow2` to something else, the boot scripts
  will need to be updated to point to the new image name.

  ```bash
  qemu-img create -f qcow2 MyDisk.qcow2 256G # or 64G
  ```

  NOTE: Create this HDD image file on a fast SSD/NVMe disk for best results.

* Now you are ready to install macOS 🚀


### Installation

- CLI method (primary). Just run the `OpenCore-Boot.sh` script to start the
  installation process.

  ```bash
  ./OpenCore-Boot.sh
  ```

  Note: This same script works for all recent macOS versions.

- Use the `Disk Utility` tool within the macOS installer to partition, and
  format the virtual disk attached to the macOS VM. Use `APFS` (the default)
  for modern macOS versions.

- Go ahead, and install macOS 🙌

- Use this macOS VM disk with libvirt (virt-manager / virsh stuff).

  - OPTION: A:
    - Run command: (The `4` means `4GB` of ram in virt-manager. (Remendation `8GB` would be an `8`))
      ```bash
      ./make-libvirt.sh 4
      ```
    - Launch `virt-manager` and start the `macOS` virtual machine.

  - OPTION: B:

    - Edit `macOS-libvirt-Catalina.xml` file and change the various file paths (search
      for `CHANGEME` strings in that file). The following command should do the
      trick usually.

      ```bash
      sed "s/CHANGEME/$USER/g" macOS-libvirt-Catalina.xml > macOS.xml

      virt-xml-validate macOS.xml
      ```

    - Create a VM by running the following command.

      ```bash
      virsh --connect qemu:///system define macOS.xml
      ```

    - If needed, grant necessary permissions to libvirt-qemu user,

      ```bash
      sudo setfacl -m u:libvirt-qemu:rx /home/$USER
      sudo setfacl -R -m u:libvirt-qemu:rx /home/$USER/OSX-KVM
      ```

    - Launch `virt-manager` and start the `macOS` virtual machine.


### Headless macOS

- Use the provided [boot-macOS-headless.sh](./boot-macOS-headless.sh) script.

  ```bash
  ./boot-macOS-headless.sh
  ```


### Post-Installation

* See [networking notes](networking-qemu-kvm-howto.txt) on how to setup networking in your VM, outbound and also inbound for remote access to your VM via SSH, VNC, etc.

* To passthrough GPUs and other devices, see [these notes](notes.md#gpu-passthrough-notes).

* Need a different resolution? Check out the [notes](notes.md#change-resolution-in-opencore) included in this repository.

* Trouble with iMessage? Check out the [notes](notes.md#trouble-with-imessage) included in this repository.

* Highly recommended macOS tweaks - https://github.com/sickcodes/osx-optimizer
