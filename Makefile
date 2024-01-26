# export SHORTNAME=monterey
DISK_SIZE := 256G

all: BaseSystem.img MyDisk.qcow2

BaseSystem.img: BaseSystem.dmg
	qemu-img convert BaseSystem.dmg -O raw BaseSystem.img

BaseSystem.dmg:
	./fetch-macOS-v2.py --shortname=$(SHORTNAME)

MyDisk.qcow2:
	qemu-img create -f qcow2 MyDisk.qcow2 ${DISK_SIZE}

clean:
	rm -rf BaseSystem{.dmg,.img,.chunklist}
