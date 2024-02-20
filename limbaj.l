%{
#include <stdio.h>
#include "y.tab.h"
int words = 0;
int countn =0;
%}
%option noyywrap
%%

"Eval" {return EVAL;}
"TypeOf" {return TYPEOF;}
"print" {return PRINT;}

"~import" {return IMPORT_S;}
".section" {return SECTION;}
"global" {return GLOBAL;}
"functions" {return FUNCTIONS;}
"data_types" {return DATA_TYPES;}
"init" {return INIT;}
"void" {return VOID;}
"if" {return IF;}
"then" {return THEN;}
"else" {return ELSE;}
"for" {return FOR;}
"return" {return RETURN;}
"while" {return WHILE;}
"$".*  { printf("\33[32mCOMMENT \33[0m- LINE - %d\n", yylineno);}
"do" {return DO; }
"class" {return CLASS;}
"const" {return CONST;}
\"[^\"]*\" { yylval.stringVal=strdup(yytext); return STRING;}
"int"|"float"|"char"|"string"|"bool" {yylval.idType = strdup(yytext); return TIP;}
[_a-zA-Z][_a-zA-Z0-9]*.txt {return FILE_NAME;}
[_a-zA-Z][_a-zA-Z0-9]* { words++; yylval.idValue = strdup(yytext); return ID;}

"++"|"--" {return UNOP;}
"<" {return LOWER;}
"<=" {return LEQUAL;}
">" {return GREATER;}
">=" {return GEQUAL;}
"==" {return EQUAL;}
"!" {return NOT;}
"&&" {return AND;}
"||" {return OR;}
"=" {return ASSIGN;}
[0-9]+ {return NR;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}
%%

