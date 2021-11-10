;-------------	 loader和kernel   ----------
; 配置引导方式，只能选择一个
%define NO_BOOT_TEST 0
%define LOADER_NO_BOOT_TEST 0
;%define CONFIG_BOOT_FLOPPY
%define CONFIG_BOOT_HARDDISK
LOADER_BASE_ADDR equ 0x900
LOADER_STACK_TOP equ LOADER_BASE_ADDR
LOADER_START_SECTOR equ 0x2

KERNEL_BIN_BASE_ADDR equ 0x60000
KERNEL_BIN_BASE_ADDR_SEG equ 0x6000
KERNEL_START_SECTOR equ 0x9
KERNEL_ENTRY_POINT equ 0xc0001500

;-------------   页表配置   ----------------
PAGE_DIR_TABLE_POS equ 0x100000

;-------------------  gdt 描述符属性  ------------------
;DESC_G_4K 表示 4k 的粒度，
DESC_G_4K equ 1_00000000000000000000000b
;DESC_D_32 表示描述符中的 D/B 字段，对代码段来说是 D 位，在此表示 32 位操作数
DESC_D_32 equ 1_0000000000000000000000b
;DESC_L 表示段描述符中的 L 位，其值见代码 4-2 的第 9 行，为 0，表示为 32 位代码段
DESC_L    equ 0_000000000000000000000b
;64位代码标记，此处标记为0便可  DESC_AVL 为 0，前面介绍 过啦，此位没实际意义，是留给操作系统用的
DESC_AVL  equ 0_00000000000000000000b
;CPU 不用此位，暂置为0
;DESC_LIMIT_CODE2 是代码段的段界限的第 2 部分(段界限 的第 1 部分在段描述符的低 4 字节中)，
;此处值为 1111b，它与段界限的第 1 部分将组成 20 个二进制 1，即总 共的段界限将是 0xFFFFF
DESC_LIMIT_CODE2  equ 1111_0000000000000000b
DESC_LIMIT_DATA2  equ DESC_LIMIT_CODE2
DESC_LIMIT_VIDEO2 equ 0000_000000000000000b
;DESC_P 表示段存在
DESC_P            equ 1_000000000000000b
;DESC_DPL_0 表示该段描述符对应的内存段的特权级是 0， 即最高特权级。当 CPU 在该段上运行时，将有至高无上的特权。
DESC_DPL_0        equ 00_0000000000000b
DESC_DPL_1        equ 01_0000000000000b
DESC_DPL_2        equ 10_0000000000000b
DESC_DPL_3        equ 11_0000000000000b
;DESC_S_CODE 是代码段的 S 位，此值为 1， 表示它是个普通的内存段，不是系统段。
DESC_S_CODE       equ 1_000000000000b
DESC_S_DATA       equ DESC_S_CODE
DESC_S_sys        equ 0_000000000000b
DESC_TYPE_CODE    equ 1000_00000000b
;x=1,c=0,r=0,a=0 代码是可执行的，非一致性，不可读，已访问位a清0

DESC_TYPE_DATA    equ 0010_00000000b
;x=0,e=0,w=1,a=0 数据段是不可执行的，向上拓展的，可写，已访问位a清0

DESC_CODE_HIGH4 equ (0x00 << 24) + DESC_G_4K + DESC_D_32 + \
DESC_L + DESC_AVL + DESC_LIMIT_CODE2 + \
DESC_P + DESC_DPL_0 + DESC_S_CODE + \
DESC_TYPE_CODE + 0x00

DESC_DATA_HIGH4 equ (0x00 << 24) + DESC_G_4K + DESC_D_32 + \
DESC_L + DESC_AVL + DESC_LIMIT_DATA2 + \
DESC_P + DESC_DPL_0 + DESC_S_DATA + \
DESC_TYPE_DATA + 0x00

DESC_VIDEO_HIGH4 equ (0x00 << 24) + DESC_G_4K + DESC_D_32 + \
DESC_L + DESC_AVL + DESC_LIMIT_VIDEO2 + DESC_P + \
DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x0b



;---------------------- 选择子属性 -----------------------
RPL0 equ 00b
RPL1 equ 01b
RPL2 equ 10b
RPL3 equ 11b
TI_GDT equ 000b
TI_LDT equ 100b



;----------------   页表相关属性    --------------
PG_P  equ   1b
PG_RW_R	 equ  00b
PG_RW_W	 equ  10b
PG_US_S	 equ  000b
PG_US_U	 equ  100b


;-------------  program type 定义   --------------
PT_NULL equ 0
