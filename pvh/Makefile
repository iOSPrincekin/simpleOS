sinclude ../define.mk
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
CC  := /Users/lee/Desktop/Computer_Systems/serenity/Toolchain/Local/i686/bin/i686-pc-serenity-gcc
CFLAGS 	:= -std=gnu99 -ffreestanding -g -c 
LD  := ${CC}
LINKFLAGS := -ffreestanding -nostdlib -g -T linker.ld


TARGET	:= kernel.elf
$(TARGET):start.s kernel.c linker.ld
	$(CC) $(CFLAGS) start.s -o start.o
	$(CC) $(CFLAGS) kernel.c -o kernel.o
	$(LD) ${LINKFLAGS} start.o kernel.o -o ${TARGET} -lgcc




clean:
	rm -rf *.o *.elf *.iso

	

SIMPLEISO	= simpleOS.iso
# virtual machine

bochs:
	bochs -f bochsrc


QEMU 		= qemu-system-i386
QEMU_ARG		= -kernel
QEMU_GDB_OPT := -S -gdb tcp::10001,ipv4
# 调试配置：-S -gdb tcp::10001,ipv4
qemu: $(TARGET)
	$(QEMU) $(QEMU_ARG) ${TARGET}

all:clean $(TARGET) iso
