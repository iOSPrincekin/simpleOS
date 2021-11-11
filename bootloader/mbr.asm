%include "boot.inc"
;主引导程序
;-------------------------------------------------------------
;SECTION MBR vstart=0x7c00
[BITS 16]           ; Tells nasm to build 16 bits code
[ORG 0x7C00]        ; The address the code will start
     mov ax,cs
     mov ds,ax
     mov es,ax
     mov ss,ax 
     mov fs,ax
     mov sp,0x7c00
     mov ax,0xb800
     mov gs,ax  

;清屏
;利用0x06 号功能，上卷全部行，则可清屏
;--------------------------------------------------------------------
;INT 0x10       功能号: 0x06   功能描述: 上卷窗口
;--------------------------------------------------------------------
;输入
;AH 功能号 = 0x6
;AL = 上卷的行数(如果为0，表示全部)
;BH = 上卷行属性
;(CL,CH) = 窗口左上角的(X,Y)位置
;(DL,DH) = 窗口右下角的(X,Y)位置
;无返回值
    mov ax, 0600h
    mov bx, 0700h
    mov cx, 0            ;左上角:  (0,0)
    mov dx, 184fh        ;右下角:(80,25),
                ; VGA文本模式中，一行只能容纳80个字符，共25行
			    ; 下标从0开始，所以0x18=24,0x4f=79
    int 10h              ;int 10h
    ; 输出背景色绿色，前景色红色，并且跳动的字符串"1 MBR"
	mov byte [gs:0x00],'b'
	mov byte [gs:0x01],0xA4

	mov byte [gs:0x02],'o'
	mov byte [gs:0x03],0xA4
    
	mov byte [gs:0x04],'o'
	mov byte [gs:0x05],0xA4

	mov byte [gs:0x06],'t'
	mov byte [gs:0x07],0xA4

	mov ax,0x90       
	mov dx,0
	mov si,LOADER_START_SECTOR          
	mov cx,4                         
	xor bx, bx
	call read_sectors                 ;以下读取程序的起始部分(一个扇区)
	jmp LOADER_BASE_ADDR + 0x300


align 4
DAP:    ; disk address packet
	db 0x10 ; [0]: packet size in bytes
	db 0    ; [1]: reserved, must be 0
	db 0    ; [2]: nr of blocks to transfer (0~127)
	db 0    ; [3]: reserved, must be 0
	dw 0    ; [4]: buf addr(offset)
	dw 0    ; [6]: buf addr(seg)
	dd 0    ; [8]: lba. low 32-bit
	dd 0    ; [12]: lba. high 32-bit

; function: read a sector data from harddisk
; @input:
;       ax: dx  -> buffer seg: off
;       si     -> lba low 32 bits
harddisk_read_sector:
	push ax
	push bx
	push cx
	push dx
	push si

	mov word [DAP + 2], 1       ; count
	mov word [DAP + 4], dx      ; offset
	mov word [DAP + 6], ax      ; segment
	mov word [DAP + 8], si      ; lba low 32 bits
	mov dword [DAP + 12], 0     ; lba high 32 bits
	
	xor bx, bx
	mov ah, 0x42
	mov dl, 0x80
	mov si, DAP
	int 0x13
	
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret

read_sectors:
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push es

.reply:
	call harddisk_read_sector
	add ax, 0x20    ; next buffer

	


	inc si          ; next lba
	loop .reply

	pop es
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret


	times 510-($-$$) db 0
	db 0x55,0xaa
