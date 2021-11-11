sinclude scripts/env.mk


NAME		:=	kernel.elf
SRC			+=	main.c

X_LDFLAGS	+= 	-no-pie -m elf_i386



define CUSTOM_TARGET_CMD
echo [SETUP.BIN] $@; \
$(LD) $(X_LDFLAGS) -o $(obj)/setup.elf $(X_OBJS)
endef