sinclude scripts/define.mk


#变量

IMAGE_DIR	:= ./image

A_IMG	:= ${IMAGE_DIR}/a.img

KERNEL_DIR	:= ./kernel

KERNEL_ELF	:= ${KERNEL_DIR}/kernel.elf


DEBUG = debug


#target


disk:
	[ -d "${DEBUG}" ] &&  echo "Directory ${DEBUG} found." || (echo "create ${DEBUG}"; mkdir ${DEBUG})
	[ -f "${A_IMG}" ] &&  echo "file ${A_IMG} found." || (echo "create ${A_IMG}"; bximage -hd=10M -imgmode="flat" -mode=create -sectsize=512 -q $(A_IMG))
	echo $@


mbr.bin:mbr.asm
	$(AS) $< -o $@

loader.bin:loader.asm
	$(AS) $< -o $@

kernel:
	@$(MAKE) -s -C $(KERNEL_DIR)


hd: mbr.bin loader.bin 
	dd if=mbr.bin	\
	of=$(A_IMG)	\
	bs=512 count=1 seek=0 conv=notrunc

	dd if=loader.bin	\
	of=$(A_IMG)	\
	bs=512 count=4 seek=2 conv=notrunc

	dd if=$(KERNEL_ELF)  \
	of=$(A_IMG) \
	bs=512 count=200 seek=9 conv=notrunc


build: disk mbr.bin loader.bin kernel hd
	echo $@


#############################################   gdb    #############################################
# virtual machine
QEMU 		= qemu-system-i386
QEMU_ARG		=
QEMU_GDB_OPT := -S -gdb tcp::10001,ipv4
# 调试配置：-S -gdb tcp::10001,ipv4
qemu: build
	$(QEMU) $(QEMU_ARG) $(A_IMG)

qemudbg: $(A_IMG) 
	$(QEMU) $(QEMU_ARG) $(QEMU_GDB_OPT) $(A_IMG)



bochs:
	bochs -f bochsrc




clean:
	rm -f $(A_IMG)
	rm -f mbr.bin 
	rm -f loader.bin
	rm -f $(KERNEL_ELF)
	$(MAKE) -s -C $(KERNEL_DIR) clean
	rm -rf debug
	rm -rf *.o



.PHONY: kernel
