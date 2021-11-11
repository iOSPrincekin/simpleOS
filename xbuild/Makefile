sinclude scripts/env.mk

X_LDFLAGS	:= -no-pie -m elf_i386 -Ttext 0xc0001500 -e main
X_INCDIRS	:= ./
X_ASFLAGS	:= -f elf

NAME		:=	kernel.elf
SRC			+=	main.c print.asm
SRC			+= hierarchy1/




.PHONY: bochs qemu qemudbg gdb


bochs:
	bochs -f bochsrc


A_IMG := ./image/a.img
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




define CUSTOM_TARGET_CMD
echo [SETUP.BIN] $@; \
$(LD) $(X_LDFLAGS) -o $(obj)/setup.elf $(X_OBJS)
endef


