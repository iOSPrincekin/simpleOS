# 默认 target，选择性包含 (空，clean)
ifeq ($(strip $(filter-out clean,$(MAKECMDGOALS))),)
sinclude scripts/env.mk



X_LDFLAGS	:= -no-pie -m elf_i386 -Ttext 0xc0001500 -e main
X_INCDIRS	:= ./
X_ASFLAGS	:= -f elf



NAME		:=	kernel.elf
SRC			+=	main.c print.asm
SRC			+= hierarchy1/

define CUSTOM_TARGET_CMD
echo [$(NAME)] $@; \
echo [$(MAKECMDGOALS),$(strip $(filter-out clean,$(MAKECMDGOALS)))]]]; \
$(LD) $(X_LDFLAGS) -o $(obj)/$(NAME) $(X_OBJS)
endef

# 其他执行target
else

sinclude scripts/define.mk

IMAGE_DIR	:=./image
A_IMG	:= ${IMAGE_DIR}/a.img

KERNEL_DIR	:= ./
kernel:
	make -s -C ${KERNEL_DIR}

CLEAN:
	rm -f $(A_IMG)
	rm -f mbr.bin 
	rm -f loader.bin
	make -s -C ${KERNEL_DIR} clean
	rm -rf debug
	rm -rf *.o



DEBUG = debug

disk:
	[ -d "${DEBUG}" ] &&  echo "Directory ${DEBUG} found." || (echo "create ${DEBUG}"; mkdir ${DEBUG})
	[ -d "${IMAGE_DIR}" ] &&  echo "Directory ${IMAGE_DIR} found." || (echo "create ${IMAGE_DIR}"; mkdir ${IMAGE_DIR})
	[ -f "${A_IMG}" ] &&  echo "file ${A_IMG} found." || (echo "create ${A_IMG}"; bximage -hd=10M -imgmode="flat" -mode=create -sectsize=512 -q $(A_IMG))
	echo $@


mbr.bin:mbr.asm
	$(AS) $< -o $@

loader.bin:loader.asm
	$(AS) $< -o $@

hd: mbr.bin loader.bin 
	dd if=mbr.bin	\
	of=$(A_IMG)	\
	bs=512 count=1 seek=0 conv=notrunc

	dd if=loader.bin	\
	of=$(A_IMG)	\
	bs=512 count=4 seek=2 conv=notrunc

	dd if=kernel.elf  \
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
	echo [$(MAKECMDGOALS),$(strip $(filter-out clean,$(MAKECMDGOALS)))]]]; \
	$(QEMU) $(QEMU_ARG) $(A_IMG)

qemudbg: $(A_IMG) 
	$(QEMU) $(QEMU_ARG) $(QEMU_GDB_OPT) $(A_IMG)


bochs:
	bochs -f bochsrc

endif



