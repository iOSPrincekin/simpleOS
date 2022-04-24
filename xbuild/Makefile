
sinclude scripts/env.mk



X_LDFLAGS	:= -no-pie -m elf_i386 -Ttext 0xc0001500 -e main
X_INCDIRS	:= ./
X_ASFLAGS	:= -f elf



NAME		:=	kernel.elf
SRC			+=	main.c print.asm
SRC			+= hierarchy1/

define CUSTOM_TARGET_CMD
echo [$(NAME)] $@; \
$(LD) $(X_LDFLAGS) -o $(obj)/$(NAME) $(X_OBJS)
endef


A_IMG := ./image/a.img




clean:
	rm -f $(A_IMG)
	rm -f mbr.bin 
	rm -f loader.bin
	rm -f kernel.elf
	rm -rf debug
	rm -rf *.o



DEBUG = debug

disk:
	[ -d "${DEBUG}" ] &&  echo "Directory ${DEBUG} found." || (echo "create ${DEBUG}"; mkdir ${DEBUG})
	[ -f "${A_IMG}" ] &&  echo "file ${A_IMG} found." || (echo "create ${A_IMG}"; bximage -hd=10M -imgmode="flat" -mode=create -sectsize=512 -q $(A_IMG))
	echo $@


mbr.bin:mbr.asm
	$(AS) $< -o $@

loader.bin:loader.asm
	$(AS) $< -o $@

hd: FORCE mbr.bin loader.bin 
	dd if=mbr.bin	\
	of=$(A_IMG)	\
	bs=512 count=1 seek=0 conv=notrunc

	dd if=loader.bin	\
	of=$(A_IMG)	\
	bs=512 count=4 seek=2 conv=notrunc

	dd if=kernel.elf  \
	of=$(A_IMG) \
	bs=512 count=200 seek=9 conv=notrunc


build: disk mbr.bin loader.bin 
	echo $@


#############################################   gdb    #############################################
# virtual machine
QEMU 		= qemu-system-i386
QEMU_ARG		=
QEMU_GDB_OPT := -S -gdb tcp::10001,ipv4
# 调试配置：-S -gdb tcp::10001,ipv4
qemu: $(A_IMG)
	$(QEMU) $(QEMU_ARG) $(A_IMG)

qemudbg: $(A_IMG) 
	$(QEMU) $(QEMU_ARG) $(QEMU_GDB_OPT) $(A_IMG)

$(A_IMG): build hd



FORCE: ;

.PHONY : FORCE




