AS = nasm 
ASFLAGS = -f elf
########################   汇编代码编译   ####################
mbr.bin:mbr.S
	$(AS) $< -o $@
loader.bin:loader.S
	$(AS) $< -o $@
kernel.elf:main.c print.S
	i386-elf-gcc -march=i386 -c -o main.o main.c
	$(AS) $(ASFLAGS) print.S -o print.o
	i386-elf-ld -no-pie -m elf_i386 main.o print.o -Ttext 0xc0001500 -e main -o kernel.elf

A_IMG := ./image/a.img

.PHONY:rm cp hd clean qemu all 

cp:
	cp mbr.bin ../../
	cp loader.bin ../../

disk:
	mkdir debug
	bximage -hd=10M -imgmode="flat" -mode=create -sectsize=512 -q $(A_IMG)

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


build: mbr.bin loader.bin kernel.elf


bochs:
	bochs -f bochsrc



#############################################   gdb    #############################################
# virtual machine
QEMU 		= qemu-system-i386
QEMU_ARG		= -d int -D debug/qemu.txt
QEMU_GDB_OPT := -S -gdb tcp::10001,ipv4
# 调试配置：-S -gdb tcp::10001,ipv4
qemu:
	$(QEMU) $(QEMU_ARG) $(A_IMG)
qemudbg:
	$(QEMU) $(QEMU_ARG) $(QEMU_GDB_OPT) $(A_IMG)


# 连接gdb server: target remote localhost:10001
gdb:
	gdb


all: clean disk build  hd 

