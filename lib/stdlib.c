/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                            stdlib.c
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

#include "type.h"
#include "const.h"
#include "func.h"
#include "global.h"


/*======================================================================*
                               itoa
 *======================================================================*/
/* 数字前面的 0 不被显示出来, 比如 0000B800 被显示成 B800 */
PUBLIC char * itoa(char * str, int num)
{
    char *  p = str;
    char ch;
    int i;
    int flag = 0;

    *p++ = '0';
    *p++ = 'x';

    if (num == 0) {
        *p++ = '0';
    }
    else{   
        for (i = 28; i >= 0; i -= 4){
            ch = (num >> i) & 0xF;
            if(flag || (ch > 0)){
                flag = 1;
                ch += '0';
                if(ch > '9'){
                    ch += 7;
                }
                *p++ = ch;
            }
        }
    }

    *p = 0;

    return str;
}

/*======================================================================*
                               print_bit
 *======================================================================*/
PUBLIC void print_bit(int input, char color)
{
    char output[16];
    itoa(output, input);
    print(output, color);
}