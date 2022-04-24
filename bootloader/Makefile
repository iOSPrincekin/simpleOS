sinclude ../define.mk
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

AS 	:= nasm 
ASFLAGS 	:= -f elf

CFLAGS 	:= -v -march=i386 -I$(ROOT_DIR) -c -o
########################   汇编代码编译   ####################
mbr.bin:mbr.asm
	$(AS) $< -o $@
loader.bin:loader.asm
	$(AS) $< -o $@
kernel.elf:main.c print.asm hierarchy1/hierarchy1.c hierarchy1/hierarchy2/hierarchy2.c hierarchy1/hierarchy2/hierarchy3/hierarchy3.c
	$(CC) $(CFLAGS) main.o main.c
	$(AS) $(ASFLAGS) print.asm -o print.o
	$(CC) $(CFLAGS) hierarchy1/hierarchy1.o hierarchy1/hierarchy1.c
	$(CC) $(CFLAGS) hierarchy1/hierarchy2/hierarchy2.o hierarchy1/hierarchy2/hierarchy2.c
	$(CC) $(CFLAGS) hierarchy1/hierarchy2/hierarchy3/hierarchy3.o hierarchy1/hierarchy2/hierarchy3/hierarchy3.c

	${LD} -no-pie -m elf_i386 main.o print.o hierarchy1/hierarchy1.o hierarchy1/hierarchy2/hierarchy2.o hierarchy1/hierarchy2/hierarchy3/hierarchy3.o -Ttext 0xc0001500 -e main -o kernel.elf

IMAGE_DIR	:=./image
A_IMG	:= ${IMAGE_DIR}/a.img

.PHONY:rm cp hd clean qemu all 

debug:
	mkdir debug
cp:
	cp mbr.bin ../../
	cp loader.bin ../../

DEBUG = debug

disk:
	[ -d "${DEBUG}" ] &&  echo "Directory ${DEBUG} found." || (echo "create ${DEBUG}"; mkdir ${DEBUG})
	[ -d "${IMAGE_DIR}" ] &&  echo "Directory ${IMAGE_DIR} found." || (echo "create ${IMAGE_DIR}"; mkdir ${IMAGE_DIR})
	[ -f "${A_IMG}" ] &&  echo "file ${A_IMG} found." || (echo "create ${A_IMG}"; bximage -hd=10M -imgmode="flat" -mode=create -q $(A_IMG))
	echo $@
hd:     
	dd if=mbr.bin	\
	of=$(A_IMG)	\
	bs=512 count=1 seek=0 conv=notrunc

	dd if=loader.bin	\
	of=$(A_IMG)	\
	bs=512 count=4 seek=2 conv=notrunc

	dd if=kernel.elf  \
	of=$(A_IMG) \
	bs=512 count=200 seek=9 conv=notrunc
  
clean:
	rm -f $(A_IMG)
	rm -f mbr.bin 
	rm -f loader.bin
	rm -f kernel.elf
	rm -rf debug
	rm -rf image
	rm -rf *.o


build: mbr.bin loader.bin kernel.elf


bochs:
	bochs -f bochsrc



#############################################   gdb    #############################################
# virtual machine
QEMU 		= qemu-system-i386
QEMU_ARG		= -d int -D debug/qemu.txt
QEMU_GDB_OPT := -S -gdb tcp::10001,ipv4
# 调试配置：-S -gdb tcp::10001,ipv4
qemu: all
	$(QEMU) $(QEMU_ARG) $(A_IMG)
qemudbg:
	$(QEMU) $(QEMU_ARG) $(QEMU_GDB_OPT) $(A_IMG)


# 连接gdb server: target remote localhost:10001
gdb:
	gdb


all: clean debug disk build  hd 

