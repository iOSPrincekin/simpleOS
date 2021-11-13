

PHONY		+=	boch


boch:
	bochs -f bochsrc

.PHONY : $(PHONY)
sinclude scripts/env.mk
sinclude scripts/wrapper.mk



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



define CUSTOM_AFTER_BUILD #结束build执行此命令
echo $(PHONY)
echo [MOUDLE A]
endef





