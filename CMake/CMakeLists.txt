cmake_minimum_required(VERSION 3.5)


########################################################## host 环境配置 开始 ##############################################

if (APPLE)
set(CROSS_COMPILE i386-elf-)
set(MKISOFS       grub-mkrescue)
else()
set(CROSS_COMPILE)
set(MKISOFS       genisoimage)
endif()

set(BOOT_DIR       boot)
set(GRUB_DIR       ${BOOT_DIR}/grub)
set(GRUB_ELTORITO  ${BOOT_DIR}/stage2_eltorito)

set(MKISOFS_FLAGS -graft-points -input-charset utf8 -sysid "" -appid "" -volid "simpleOS" -R -no-emul-boot -boot-load-size 4 -boot-info-table -b ${GRUB_ELTORITO} -o)



if (WIN32)
    message(STATUS "windows 平台！！！")
endif (WIN32)

# Make variables (CC, etc...)
set(AS				${CROSS_COMPILE}gcc)
set(CC				${CROSS_COMPILE}gcc)
set(CPP				${CROSS_COMPILE}gcc -E)
set(CXX				${CROSS_COMPILE}g++)
set(LD				${CROSS_COMPILE}ld)
set(AR				${CROSS_COMPILE}ar)
set(OC				${CROSS_COMPILE}objcopy)
set(OD				${CROSS_COMPILE}objdump)
set(NM				${CROSS_COMPILE}nm)

set(HOSTCC			gcc)


########################################################## host 环境配置 结束 ##############################################

# 工程名称
project(simpleOS)
set(CMAKE_OSX_SYSROOT "")
# 工程内变量
set(CMAKE_DEBUG YES)

# 支持的语言 
enable_language(C ASM ASM_NASM)


set(CMAKE_C_FLAGS_LIST "-c -march=i386 -fno-builtin -Wall -Wunused -fno-PIE -m32 -std=gnu99 -fno-stack-protector")
# C 语言 .c
set(CMAKE_C_COMPILER ${CC})
set(CMAKE_C_FLAGS ${CMAKE_C_FLAGS_LIST})
set(CMAKE_C_LINK_FLAGS "-m elf_i386 -v -Ttext 0x100000")
set(CMAKE_C_LINKER ${LD})
set(CMAKE_C_LINK_EXECUTABLE  "${CMAKE_C_LINKER} <CMAKE_C_LINK_FLAGS>  <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")



# ASM 语言 .S
set(CMAKE_ASM_SOURCE_FILE_EXTENSIONS S)
set(CMAKE_ASM_COMPILER ${AS})
set(CMAKE_ASM_FLAGS "-x assembler-with-cpp")
set(CMAKE_ASM_LINK_FLAGS "-m elf_i386")
#set(CMAKE_ASM_LINKER ${LD})

# ASM NASM 语言 .asm 
set(CMAKE_ASM_NASM_SOURCE_FILE_EXTENSIONS asm)
set(CMAKE_ASM_NASM_COMPILER nasm)
set(CMAKE_ASM_NASM_FLAGS "-f elf")
set(CMAKE_ASM_NASM_COMPILE_OBJECT "${CMAKE_ASM_NASM_COMPILER} <INCLUDES> ${CMAKE_ASM_NASM_FLAGS} -o <OBJECT> <SOURCE>")


#set(CMAKE_ASM_LINK_EXECUTABLE  "<CMAKE_ASM_LINKER>  <CMAKE_ASM_LINK_FLAGS>  <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")

#set(CMAKE_ASM_OBJECT_FORMAT elf32)
#set(CMAKE_ASM_COMPILE_OBJECT "<CMAKE_ASM_COMPILER> <INCLUDES> <FLAGS> -f ${CMAKE_ASM_OBJECT_FORMAT} -o <OBJECT> <SOURCE>")

# 自定义属性
set_property(GLOBAL PROPERTY USE_FOLDERS TRUE)
define_property(
    TARGET
    PROPERTY FOLDER
    INHERITED
    BRIEF_DOCS "Set the folder name."
    FULL_DOCS  "Use to organize targets in an IDE."
)



#编译 kernel.elf
set(target kernel.elf)

include_directories(./)


file(GLOB "SOURCE" "${CMAKE_CURRENT_SOURCE_DIR}/*.c" "${CMAKE_CURRENT_SOURCE_DIR}/*.asm" "${CMAKE_CURRENT_SOURCE_DIR}/*.S")
if(CMAKE_DEBUG)
    message(STATUS "${target}_SRC: ${SOURCE}")
endif()


add_subdirectory(hierarchy1)

# 整理文件结构
set(sub_files)
set(last_sub_dir_prefix)
foreach(s_file IN LISTS SOURCE)
	#s_file:/Users/lee/Desktop/Computer_Systems/操作系统真象还原/第16章_网络/16.1_网络驱动/bin/bash/builtins/return.c
	string(REPLACE ${CMAKE_CURRENT_SOURCE_DIR} "" s_file_suffix ${s_file})
	#s_file_suffix:/builtins/return.c
	string(REGEX MATCHALL "/.+/" sub_dir_prefix ${s_file_suffix})
	#sub_dir_prefix:/builtins/
	if(NOT sub_dir_prefix STREQUAL "")
	string(REGEX REPLACE "(.+)(/)" "\\1" sub_dir_prefix ${sub_dir_prefix})
	#sub_dir_prefix:/builtins
   	 	if(NOT last_sub_dir_prefix STREQUAL ${sub_dir_prefix})
			string(REPLACE "/" "\\\\" sub_dir_prefix_dealed "${last_sub_dir_prefix}")
			source_group("${sub_dir_prefix_dealed}" FILES ${sub_files})
			set(sub_files)
   	 		set(last_sub_dir_prefix ${sub_dir_prefix})
 	 	endif()
	list(APPEND sub_files ${s_file})
	else()
	
	endif()
endforeach()
source_group("" FILES ${SOURCE})
string(REPLACE "/" "\\\\" sub_dir_prefix_dealed "${last_sub_dir_prefix}")
source_group("${sub_dir_prefix_dealed}" FILES ${sub_files})



add_executable(${target}
	 ${SOURCE}
)

## 工具
set(TRUNC		truncate)
set(CP			${CMAKE_COMMAND} -E copy)
set(RM			rm)
set(DD			dd)
set(MKDIR	 	${CMAKE_COMMAND} -E make_directory)
set(OBJDUMP		objdump)

#生成 .iso 文件
add_custom_target(iso DEPENDS ${target}
)

add_custom_command(
TARGET iso POST_BUILD
COMMAND ${CP} ${target} ./isofiles/boot
COMMAND ${MKISOFS} ${MKISOFS_FLAGS} simpleOS.iso isofiles
)


#qemu启动

#QEMU
set(OS_NAME simpleOS.iso)
set(QEMU qemu-system-i386)
set(QEMU_ARG "-cdrom")

add_custom_target(qemu DEPENDS iso
)

add_custom_command(
TARGET qemu POST_BUILD
COMMAND ${QEMU} ${QEMU_ARG} ${OS_NAME}
)



