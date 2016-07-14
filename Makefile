# Makefile
# 目标 : 生成MuteOS的磁盘镜像 MuteOS.img

MAKE     = 	make -r
LD   	 = 	ld
DD 		 = 	dd
NASM     =  nasm
CC 		 =  gcc
QEMU     =  qemu-system-i386
RM		 =  rm -f

KERNELDIR= 	kernel
BOOTDIR	 = 	boot
MOUNTDIR =  mnt
LIBDIR 	 = 	lib
ROOTDIR  =  .

RAW 	 =  ${ROOTDIR}/raw.img
CONTAINER= 	${ROOTDIR}/image.img
OSIMG 	 = 	${ROOTDIR}/MuteOS.img



default :
	$(MAKE) run

bootloader : ${BOOTDIR}/boot.asm ${BOOTDIR}/loader.asm
	cd ${BOOTDIR} && ${MAKE}
	cd ${ROOTDIR}

kernel : ${KERNELDIR}/kernel.asm Makefile ${LIBDIR}/lib.asm ${KERNELDIR}/start.c
	$(NASM) -f elf64 ${KERNELDIR}/kernel.asm -o ${KERNELDIR}/kernel.o
	$(CC) -c -o ${KERNELDIR}/start.o ${KERNELDIR}/start.c
	$(LD) -s -Ttext 0x600 -o ${KERNELDIR}/kernel.bin ${KERNELDIR}/kernel.o \
			${KERNELDIR}/start.o ${LIBDIR}/lib.o

lib : ${LIBDIR}/lib.asm
	$(NASM) -f elf64 ${LIBDIR}/lib.asm -o ${LIBDIR}/lib.o


usb : img
	$(DD) if=${OSIMG} of=/dev/sdb

f12image : bootloader kernel
	$(DD) if=/dev/zero of=${RAW} bs=1440K count=1
	mkfs.fat -F 12 -r 224 -s 1 -S 512 -M 0xF0 -R 1 ${RAW}
	mount ${RAW} ${MOUNTDIR}
	cp ${BOOTDIR}/loader.bin ${MOUNTDIR}
	cp ${KERNELDIR}/kernel.bin ${MOUNTDIR}
	umount ${RAW}

img : f12image
	$(DD) if=${RAW} of=${CONTAINER} bs=512 skip=1
	cat ${BOOTDIR}/boot.bin ${CONTAINER} > ${OSIMG}
	$(RM) ${RAW} ${CONTAINER}

run : img
	$(QEMU) -drive file=${OSIMG},format=raw,index=0,if=floppy

debug : bootloader
	$(QEMU) -s -S -drive file=${OSIMG},format=raw,index=0,if=floppy

clean :
	$(RM) ${OSIMG} ${BOOTDIR}/boot.bin ${BOOTDIR}/loader.bin ${KERNELDIR}/kernel.bin

