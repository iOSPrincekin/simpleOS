# simpleOS
使用不同的工具链来构建一个简单的操作系统，旨在研究和探讨如何更加高效地进行操作系统开发

## 写在前面

阅读本工程之前，你应该具备基础的操作系统知识，本工程不会探讨具体的操作系统知识，旨在探讨和研究如何解决开发操作系统过程中遇到的效率问题，怎么使用现有的工具来提高开发和调试操作系统的效率，如何提高操作系统的开发体验

本工程主要由以下五个模块组成:<a href="#bootloader_id">bootloader</a>、<a href="#xbuild_id">xbuild</a>、<a href="#grub2_id">grub2</a>、
<a href="#CMake_id">CMake</a>、<a href="#IDE_id">IDE</a>、<a href="#VSCode_id">VSCode</a>

<span id="bootloader_id"></span>

这个五个模块是一个从低效到高效的过程，用一张图可以更加形象的表示

![人类进化图](./pic/人类进化图.png)
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




<span id="xbuild_id"></span>

## xbuild

基于makefile 使用[xbuild](https://github.com/ZhUyU1997/XBuild)进行辅助组织


### 使用:
```
cd xbuild
make 
make qemu
```
### 优点:
相对于  <a href="#bootloader_id">bootloader</a>而言，解决了大型操作系统源文件组织困难的问题，同时和CMake相比具有轻量的特点。


<span id="grub2_id"></span>
## grub2

### 使用:
```
cd grub2
make all
make qemu
```
### 为什么使用grub2

现在我们开发的kernel.elf 大小在6kb左右，换成16进制是 0x19FC，首先 kernel.elf会被loader.asm加载到物理地址 0x60000

```

loader_start:
;------------------------------------  加载 kernel  -------------------------------

mov eax, KERNEL_BIN_BASE_ADDR_SEG
mov si, KERNEL_START_SECTOR
mov edx, 0
mov ecx, 400
xor ebx, ebx 
call read_sectors

```
然后透过解析kernel.elf的 elf文件结构，将 kernel.elf 中的代码段加载到 物理地址 0x1500 左右


```
;---------------  讲 kernel.bin 中的 segment 拷贝到编译的地址 ----------------
kernel_init:     ; 0x0d47
xor eax, eax
xor ebx, ebx       ;ebx 记录程序头表地址
xor ecx, ecx       ;cx 记录程序头表中的 program header 数量 
xor edx, edx       ;dx 记录program header 尺寸，即 e_phentsize

mov dx,[KERNEL_BIN_BASE_ADDR + 42]   ;编译文件 42 字节处的属性是 e_phentsize, 表示 program header 大小
mov ebx, [KERNEL_BIN_BASE_ADDR + 28] ;偏移文件开始部分 28 字节的地方是 e_phoff，表示第 1 个program header 在文件中的偏移量
;其实该值是 0x34,不过还是谨慎一点，这里来读取实际值
add ebx, KERNEL_BIN_BASE_ADDR
mov cx, [KERNEL_BIN_BASE_ADDR + 44]  ;偏移文件开始部分 44 字节的地方是 e_phnum,表示有几个 program header
.each_segment:
cmp byte [ebx + 0], PT_NULL  ; 若 p_type 等于 PT_NULL, 说明此 program header 未使用   0xd62
je .PTNULL

;为函数 memcpy 压入参数，参数是从右往左依次压入,函数原型类似于 memcpy(dst, src, size)
push dword [ebx + 16]           ; program header 中偏移 16 字节的地方是 p_filesz,压入函数 memcpy 的第三个参数:size
mov eax, [ebx + 4]             ;  距程序偏移量为 4 字节的位置是 p_offset
add eax, KERNEL_BIN_BASE_ADDR    ;加上 kernel.bin 被加载到的物理地址， eax 为该段的物理地址
push eax             ; 压入函数 memcpy 的第二个参数: 源地址
mov eax,[ebx + 8]
push eax
;push dword [ebx + 8]; 压入函数 memcpy 的第一个参数: 目的地址,偏移程序头 8 字节的位置是 p_vaddr, 这就是目的地址 
call mem_cpy         ; 调用 mem_cpy 完成段复制 
add esp, 12          ; 清理栈中压入的三个参数
.PTNULL:
add ebx,     edx     ; edx 为 program header 大小，即 e_phentsize,在此 ebx 指向下一个 program header 
loop .each_segment 
ret 


```


随着开发的进行，kernel.elf 会越来越大，比如说大到 0x200000,那么kernel.elf中.bss段中的变量地址也很接近 0x200000，那么存放kernel.elf的0x60000起始的物理地址，将会和解析后kernel.elf代码段及.bss 端重合将导致未知错误，所以我们需要使用grub2帮我们处理这部分传统BootLoader需要做的工作，使用grub2后我们只要专心开发内核就行，至于我们上面说的kernel.elf的存放和解析则都由grub2完成。


### grub2核心

#### 1.我们需要标识我们的kernel.elf是具有grub2功能的文件

boot.S
```
/*  boot.S - bootstrap the kernel */
/*  Copyright (C) 1999, 2001, 2010  Free Software Foundation, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#define ASM_FILE        1
#include "multiboot2.h"

/*  C symbol format. HAVE_ASM_USCORE is defined by configure. */
#ifdef HAVE_ASM_USCORE
# define EXT_C(sym)                     _ ## sym
#else
# define EXT_C(sym)                     sym
#endif

/*  The size of our stack (16KB). */
#define STACK_SIZE                      0x4000

/*  The flags for the Multiboot header. */
#ifdef __ELF__
# define AOUT_KLUDGE 0
#else
# define AOUT_KLUDGE MULTIBOOT_AOUT_KLUDGE
#endif
		
		.text

		.globl  start, _start
start:
_start:
		jmp     multiboot_entry

		/*  Align 64 bits boundary. */
		.align  8
		
		/*  Multiboot header. */
multiboot_header:
		/*  magic */
		.long   MULTIBOOT2_HEADER_MAGIC
		/*  ISA: i386 */
		.long   GRUB_MULTIBOOT_ARCHITECTURE_I386
		/*  Header length. */
		.long   multiboot_header_end - multiboot_header
		/*  checksum */
		.long   -(MULTIBOOT2_HEADER_MAGIC + GRUB_MULTIBOOT_ARCHITECTURE_I386 + (multiboot_header_end - multiboot_header))
		.long   0
		.long   8
#ifndef __ELF__
address_tag_start:      
		.short MULTIBOOT_HEADER_TAG_ADDRESS
		.short MULTIBOOT_HEADER_TAG_OPTIONAL
		.long address_tag_end - address_tag_start
		/*  header_addr */
		.long   multiboot_header
		/*  load_addr */
		.long   _start
		/*  load_end_addr */
		.long   _edata
		/*  bss_end_addr */
		.long   _end
address_tag_end:
entry_address_tag_start:        
		.short MULTIBOOT_HEADER_TAG_ENTRY_ADDRESS
		.short MULTIBOOT_HEADER_TAG_OPTIONAL
		.long entry_address_tag_end - entry_address_tag_start
		/*  entry_addr */
		.long multiboot_entry
entry_address_tag_end:
#endif /*  __ELF__ */
framebuffer_tag_start:  
		.short MULTIBOOT_HEADER_TAG_FRAMEBUFFER
		.short MULTIBOOT_HEADER_TAG_OPTIONAL
		.long framebuffer_tag_end - framebuffer_tag_start
		.long 1024
		.long 768
		.long 32
framebuffer_tag_end:
		.short MULTIBOOT_HEADER_TAG_END
		.short 0
		.long 8
multiboot_header_end:
multiboot_entry:
		/*  Initialize the stack pointer. */
		movl    $(stack + STACK_SIZE), %esp

		/*  Reset EFLAGS. */
		pushl   $0
		popf

		/*  Push the pointer to the Multiboot information structure. */
		pushl   %ebx
		/*  Push the magic value. */
		pushl   %eax

		/*  Now enter the C main function... */
		call    EXT_C(main)

		/*  Halt. */
		pushl   $halt_message
		call    EXT_C(put_str)
		
loop:   hlt
		jmp     loop

halt_message:
		.asciz  "Halted."

		/*  Our stack area. */
		.comm   stack, STACK_SIZE

```

#### 2.grub2 默认寻找multiboot_header的地址是 0x100000，我们需要将kernel.elf的地址编译为从0x100000开始

```
	i386-elf-ld -no-pie -m elf_i386 boot.o main.o print.o hierarchy1/hierarchy1.o hierarchy1/hierarchy2/hierarchy2.o hierarchy1/hierarchy2/hierarchy3/hierarchy3.o -Ttext 0x100000 -o kernel.elf

```

完成以上两步后，我们的kernel.elf 就是具备grub2能力的文件，可以被grub2加载

#### 3.设置kernel.elf的grub2载体

这里我们选用 .iso 文件

```
iso:
	cp	$(TARGET) isofiles/boot/
	grub-mkrescue -o simpleOS.iso isofiles
```

#### 4.生成.iso文件后，启动虚拟机即可

```
make qemu
```

<span id="CMake_id"></span>
## CMake

使用[CMake](https://cmake.org/cmake/help/v3.22/) 对操作系统源文件进行组织

### 使用:
```
cd CMake
cmake ./
make iso
make qemu
```
### 优点:
老牌大厂，稳定可靠，功能齐全

### 缺点:
到现在为止，我们编辑源文件还是很困难的，如果能将工程集成到 XCode、Visual Stdio 这样的IDE进行编辑，同时可以进行方法跳转、界面调试将能大大提高开发效率

<span id="IDE_id"></span>
## IDE

### XCode

### 使用:
```
cd IDE
./run_cmake.sh
```
打开 build 文件夹下的 simpleOS.xcodeproj 工程，选择 `kernel` target,直接运行即可，我们看到，一个简单的XCode运行按钮，我们就完成了qemu启动，及lldb连接调试，我们在lldb命令界面执行`c`命令即可完成我们系统的运行，从下图可以看到，我们的源文件已经成树状结构在XCode中展示出来，同时方法名也高亮了，可以进行跳转

![XCode效果](./pic/xcode_1.png)


### 优点:
工程更加直观，具备方法跳转、方法名高亮、全局查找、一键调试等优点

<span id="VSCode_id"></span>
## VSCode

vscode 需要安装两个扩展插件：`Native Debug`和`CodeLLDB`

其中 .vscode/launch.json 配置如下

```
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "KernelDbg",
            "type": "lldb",
            "request": "custom",
            "preLaunchTask": "run",
            "targetCreateCommands": ["target create ${workspaceFolder}/kernel.elf"],
            "processCreateCommands": ["gdb-remote localhost:1234"],
            "sourceMap": {"${workspaceFolder}" : "${workspaceFolder}"},
            "console": "internalConsole",
        }
    ]
}

```
这样配置完以后就可以使用vscode实时断点调试了

![](./vscode_1.png)

# 待做:

如果你看到了这里，可以发现我们的操作系统开发方式较之前高效了很多，但是我们还没实现界面调试的功能，我们不能像IDE本身平台工程那样给我们操作系统工程下断点，这个功能如果实现了，我们的开发效率将会到达一个新的高度。
以XCode为例，XCode默认的调试器是lldb，我们现在也实现了用lldb调试我们的内核kernel.elf,就是无法将断点映射到图形界面上，从理论上来说，这是可行的，由于本人技术有限，暂时无法实现，还请各位大神一起群策群力,加入qq群大家一起交流提高开发操作系统的效率。

## qq群:
开发效率群:809565047

![开发效率群](./pic/qq群.png)
