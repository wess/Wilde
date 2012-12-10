//
//  CSSInc.h
//  Wilde
//
//  Created by Wess Cope on 11/26/12.
//  Copyright (c) 2012 Wess Cope. All rights reserved.
//
// Taken from Sam Stewart (https://github.com/veritech/CSSApply)
// Updated By Wess Cope.
//

#include <stdio.h>

#ifndef CSSSample_CSSInc_h
#define CSSSample_CSSInc_h

typedef enum {
    CSSFIRST_TOKEN = 0x100,
    CSSSTRING = CSSFIRST_TOKEN,
    CSSIDENT, //0x101
    CSSHASH, //0x102
    CSSEMS, //0x103
    CSSEXS, //0x104
    CSSLENGTH, //0x105
    CSSANGLE, //0x106
    CSSTIME, //0x107
    CSSFREQ, //0x108
    CSSDIMEN, //0x109
    CSSPERCENTAGE, //0x10A
    CSSNUMBER, //0x10B
    CSSURI, //0x10C
    CSSFUNCTION, //0x10D
    CSSUNICODERANGE, //0x10E
    CSSUNKNOWN, //0x10F
    
} CssParserCodes;

extern const char* cssnames[];

#ifndef YY_TYPEDEF_YY_SCANNER_T
#define YY_TYPEDEF_YY_SCANNER_T
typedef void* yyscan_t;
#endif

extern FILE *cssin;

int cssConsume(char* text, int token);

#endif
