#ifndef __LIB_KERNEL_PRINT_H
#define __LIB_KERNEL_PRINT_H
//#include "stdint.h"
typedef unsigned char		uint8_t;
typedef unsigned int		uint32_t;
void put_char(uint8_t char_asci); 
void put_str(char* message);
void put_int(uint32_t num); // 以十六进制打印
#endif
