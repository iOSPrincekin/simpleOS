AS 	:= nasm 
ASFLAGS 	:= -f elf
CC 	:= i386-elf-gcc
CFLAGS 	:= -I ./ -march=i386 -c -o

TARGET	:= kernel.elf
$(TARGET):boot.S main.c print.asm hierarchy1/hierarchy1.c hierarchy1/hierarchy2/hierarchy2.c hierarchy1/hierarchy2/hierarchy3/hierarchy3.c
	$(CC) $(CFLAGS) boot.o boot.S
	$(CC) $(CFLAGS) main.o main.c
	$(AS) $(ASFLAGS) print.asm -o print.o
	$(CC) $(CFLAGS) hierarchy1/hierarchy1.o hierarchy1/hierarchy1.c
	$(CC) $(CFLAGS) hierarchy1/hierarchy2/hierarchy2.o hierarchy1/hierarchy2/hierarchy2.c
	$(CC) $(CFLAGS) hierarchy1/hierarchy2/hierarchy3/hierarchy3.o hierarchy1/hierarchy2/hierarchy3/hierarchy3.c
	i386-elf-ld -no-pie -m elf_i386 boot.o main.o print.o hierarchy1/hierarchy1.o hierarchy1/hierarchy2/hierarchy2.o hierarchy1/hierarchy2/hierarchy3/hierarchy3.o -Ttext 0x100000 -o kernel.elf




clean:
	rm -rf *.o *.elf

iso:
	cp	$(TARGET) isofiles/boot/
	grub-mkrescue -o simpleOS.iso isofiles
	

SIMPLEISO	= simpleOS.iso
# virtual machine

bochs:
	bochs -f bochsrc


QEMU 		= qemu-system-i386
QEMU_ARG		= -cdrom
QEMU_GDB_OPT := -S -gdb tcp::10001,ipv4
# 调试配置：-S -gdb tcp::10001,ipv4
qemu:
	$(QEMU) $(QEMU_ARG) $(SIMPLEISO)

all:clean $(TARGET) iso bochs