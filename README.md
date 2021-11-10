# simpleOS
使用不同的工具链来构建一个简单的操作系统，旨在研究和探讨如何更加高效地进行操作系统开发

## 写在前面

阅读本工程之前，你应该具备基础的操作系统知识，本工程不会探讨具体的操作系统知识，旨在探讨和研究如何解决开发操作系统过程中遇到的效率问题，怎么使用现有的工具来提高开发和调试操作系统的效率，如何提高操作系统的开发体验

本工程主要由以下四个模块组成:`bootloader`、`xbuild`、`cmake`、`IDE`

## bootloader

使用makefile 进行组织

### 使用:
```
cd bootloader
make all
make qemu
```

### 缺点:

对大型操作系统中复杂的源文件结构不好进行组织

比如这种对 hierarchy1、hierarchy2、hierarchy3多层级源文件的组织在大型操作系统开发中是不可取的！

```
kernel.elf:main.c print.S hierarchy1/hierarchy1.c
	i386-elf-gcc $(CFLAGS) main.o main.c
	i386-elf-gcc $(CFLAGS) hierarchy1/hierarchy1.o hierarchy1/hierarchy1.c
	i386-elf-gcc $(CFLAGS) hierarchy1/hierarchy2/hierarchy2.o hierarchy1/hierarchy2/hierarchy2.c
	i386-elf-gcc $(CFLAGS) hierarchy1/hierarchy2/hierarchy3/hierarchy3.o hierarchy1/hierarchy2/hierarchy3/hierarchy3.c
	$(AS) $(ASFLAGS) print.S -o print.o
	i386-elf-ld -no-pie -m elf_i386 main.o print.o hierarchy1/hierarchy1.o hierarchy1/hierarchy2/hierarchy2.o hierarchy1/hierarchy2/hierarchy3/hierarchy3.o -Ttext 0xc0001500 -e main -o kernel.elf

```




