%{
#include <stdio.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
extern int words;

//ADAUGAT MAX NR OF PARAMETERS


#define MAX_VAR_PARAM 5
#define MAX_CLASS_FUNC 10
#define MAX_CLASS_VAR 10

void printv(char*);
int searchV(char*);
int searchF(char*);
int searchP(char*, char*);
void addVar(char*,  char*);
void addFunc(char*,  char*);
void addParam(char*, char*);
void addClass(char*);
int searchC(char*);

struct varData {
     char * id_name;
     char * data_type;
     int line_no;
} var_table[40];

struct funcData {
     char * id_name;
     char * data_type;
     int line_no;
     struct varData param[MAX_VAR_PARAM];
     int param_no;
} func_table[40];

struct classData{
     char* name;
     struct varData lista_variabile[MAX_CLASS_VAR];     
     struct funcData lista_functii[MAX_CLASS_FUNC];
     int nr_variables;
     int nr_functions;
     int line_no;
} class_table[40];


int count_var = 0;
int count_function = 0;
int count_class= 0;
%}
%union{
     char* idValue;
     char* idType;
     char* stringVal;
}


%token RETURN NR VOID CLASS IF THEN ELSE FOR WHILE DO INIT CONST COMMENT SECTION GLOBAL FUNCTIONS DATA_TYPES
%token LOWER GREATER LEQUAL GEQUAL EQUAL NOT AND OR ASSIGN IMPORT_S EVAL TYPEOF FILE_NAME UNOP PRINT
%token <idValue>ID
%token <idType>TIP
%token <stringVal>STRING

%left '+' '-'
%left '*' ':' '%'
%left '{' '}' '[' ']' '(' ')'
%start progr
%%
progr: imports_sec SECTION GLOBAL global_sec SECTION FUNCTIONS functions_sec SECTION DATA_TYPES data_types_sec INIT '{' bloc '}' {printf("\33[32m----PROGRAM CORECT SINTACTIC----\33[0m\n");}
     ;

//IMPORT

imports_sec : import
           | /* epsilon */
           ;

import : IMPORT_S FILE_NAME
       | import IMPORT_S FILE_NAME
       ;

//GLOBAL

global_sec : declaratii
           | /* epsilon */
           ;

declaratii : declaratie ';' 
           | declaratii declaratie ';'
           ;

declaratie : predefined_type
           | predefined_array_type
           | CONST predefined_type
           | CONST predefined_array_type
           ;

predefined_type : TIP ID { addVar($1, $2); }
                ;


predefined_array_type : TIP ID '['NR']' { char* type = (char*)malloc(64*sizeof(char)); strcpy(type, $1); strcat(type, "["); strcat(type, "]"); addVar(type, $2); free(type); }
                      ;

//FUNCTIONS

functions_sec : functions
              | /* epsilon */
              ;

functions : function 
          | functions function
          ;

function : VOID ID '(' function_param ')' '{' bloc '}' {addFunc("void", $2);}
         | TIP ID '(' function_param ')' '{' bloc RETURN ID ';' '}' {addFunc($1, $2);}
         | TIP ID '(' function_param ')' '{' bloc RETURN NR ';' '}' {addFunc($1, $2);}
         ;

function_param : predefined_param_type
               | function_param ',' predefined_param_type
               | /* epsilon */
               ;

predefined_param_type : predefined_type_param
           | predefined_array_type_param
           | CONST predefined_type_param
           | CONST predefined_array_type_param
           ;

predefined_type_param : TIP ID { addParam($1, $2); }
                ;


predefined_array_type_param : TIP ID '['NR']' { char* type = (char*)malloc(64*sizeof(char)); strcpy(type, $1); strcat(type, "["); strcat(type, "]"); addParam(type, $2); free(type); }
                      ;

//CLASSES

data_types_sec : classes 
               | /* epsilon */
               ;

classes : class ';'
        | classes class ';'
        ;

class : CLASS ID {addClass($2);} '{' class_bloc '}'
      ;

class_bloc : declaratie ';'
           | function 
           | class_bloc declaratie ';'
           | class_bloc function
           ;

bloc : statements
     | /* epsilon */
     ;

statements : statement 
           | statements statement
           ;

statement : declaratie ';'
           | if_statement
           | for_statement
           | while_statement
           | assignment_statement ';'
           | function_call ';'
           | predefined_func
           ;

assignment_statement : ID ASSIGN expression
                     | ID'['NR']' ASSIGN expression
                     | TIP ID ASSIGN expression { addVar($1, $2); }
                     | CONST TIP ID ASSIGN expression { addVar($2, $3); }
                     ;

if_statement : IF '(' boolean_expression ')' '{' bloc '}' ELSE '{' bloc '}'
             | IF '(' boolean_expression ')' '{' bloc '}'
             ;

for_statement : FOR '(' init_for ',' boolean_expression ',' step_for ')' '{' bloc '}'
              ;

init_for : ID ASSIGN NR 
         | ID ASSIGN ID 
         | TIP ID ASSIGN NR {addVar($1, $2);}
         | TIP ID ASSIGN ID {addVar($1, $2);}
         ;

step_for : ID ASSIGN expression
         | UNOP ID
         | ID UNOP
         ;

while_statement : WHILE '(' boolean_expression ')' DO '{' bloc '}'
                ;
boolean_expression : condition
                   | NOT '('condition')'
                   | boolean_expression AND condition
                   | boolean_expression OR condition
                   ;

condition : expression LOWER expression
          | expression GREATER expression
          | expression LEQUAL expression
          | expression GEQUAL expression
          | expression EQUAL expression
          | expression NOT EQUAL expression
          | expression
          ;

expression : expression '*' expression {}//$$ = $1 * $3;}
           | expression ':' expression {}//$$ = $1 / $3;}
           | expression '+' expression {}//$$ = $1 + $3;}
           | expression '-' expression {}//$$ = $1 - $3;}
           | expression '%' expression {}//$$ = $1 % $3;}
           | '(' expression ')'
           | ID '[' NR ']'
           | NR
           | ID
           | function_call
           ;

function_call : ID '(' function_call_list ')'
              ;

function_call_list: expression
                 | STRING
                 | function_call_list ',' expression
                 |  /* epsilon */
                 ;


predefined_func : EVAL '(' expression ')' ';'
                | TYPEOF '(' expression ')' ';'
                | PRINT '(' STRING ')' ';' { printv($3); }
                ;

%%
int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
yyin=fopen(argv[1],"r");
yyparse();
printf("Numar variabile: %d\nNumar functii: %d", count_var, count_function);
FILE *varfile,*fctfile;
varfile=fopen("symbol_table.txt","w");
fctfile=fopen("symbol_table_functions.txt","w");
char line[100]={0};
sprintf(line,"%-5s %-15s %-15s %-10s\n","ID","NAME","TYPE","LINE_NO");
fputs(line,varfile);
for(int i=0;i<count_var;i++)
{
    memset(line,0,sizeof(line));
    sprintf(line,"%-5d %-15s %-15s %-10d\n",i+1,var_table[i].id_name,var_table[i].data_type,var_table[i].line_no);
    fputs(line,varfile);
}
memset(line,0,sizeof(line));
sprintf(line,"%-5s %-15s %-15s %-5s %-20s\n","ID","NAME","TYPE","LINE_NO","PARAMETERS");
fputs(line,fctfile);
for(int i=0;i<count_function;i++)
{
    memset(line,0,sizeof(line));
    sprintf(line,"%-5d %-15s %-15s %-10d",i+1,func_table[i].id_name,func_table[i].data_type,func_table[i].line_no);
    fputs(line,fctfile);
    for(int j=0;j<func_table[i].param_no;j++)
    {
     memset(line,0,sizeof(line));
     sprintf(line," %-15s %-15s",func_table[i].param[j].id_name,func_table[i].param[j].data_type);
     fputs(line,fctfile);
    }
    fputc('\n',fctfile);
}
for(int i=0;i<count_var;i++) {
	free(var_table[i].id_name);
}
printf("\n\n");
} 

int searchV(char *vName) {
	for(int i=count_var-1; i>=0; i--) {
		if(strcmp(var_table[i].id_name, vName)==0) {
			return var_table[i].line_no;
			break;
		}
	}
	return -1;
}

int searchF(char *vName) {
	for(int i=count_function-1; i>=0; i--) {
		if(strcmp(func_table[i].id_name, vName)==0) {
			return func_table[i].line_no;
			break;
		}
	}
	return -1;
}

int searchP(char *vName, char* type) {
       for(int i=0; i < func_table[count_function].param_no; ++i) {
          if(strcmp(func_table[count_function].param[i].id_name, vName)==0) {
	  		return func_table[count_function].param[i].line_no;
	  		break;
	  	     }
       }
	return -1;
}

int searchC(char *cName) {
       for(int i=0; i < count_class; ++i) {
          if(strcmp(class_table[i].name, cName)==0) {
	  		return class_table[i].line_no;
	  		break;
	  	     }
       }
	return -1;
}

void addVar(char* tip, char* name){
     int index = searchV(name);
     if(index != -1){
          printf("\33[31mError at line %d:\33[0m Variable %s already exists at line %d!\n", yylineno, name, index);
          exit(-1);
     } else {
          var_table[count_var].id_name = strdup(name);
          var_table[count_var].data_type = strdup(tip);
          var_table[count_var].line_no = yylineno;
          count_var++;
          printf("\33[36mVARIABLE \33[0m- NAME: %s - TYPE: %s - LINE: %d\n", name, tip, yylineno);
     }
}

void addClass(char* name){
     int index = searchC(name);
     if(index != -1){
          printf("\33[31mError at line %d:\33[0m Class %s already exists at line %d!\n", yylineno, name, index);
          exit(-1);
     } else {
          class_table[count_class].name = strdup(name);
          class_table[count_class].line_no = yylineno;
          count_class++;
          printf("\33[31mCLASS \33[0m- NAME: %s - LINE: %d\n", name, yylineno);
     }
}

void addFunc(char* tip, char* name){
     int index = searchF(name);
     if(index != -1){
          printf("\33[31mError at line %d:\33[0m Function %s already exists at line %d!\n", yylineno, name, index);
          exit(-1);
     } else {
          func_table[count_function].id_name = strdup(name);
          func_table[count_function].data_type = strdup(tip);
          func_table[count_function].line_no = yylineno;
          count_function++;
          printf("\33[35mFUNCTION \33[0m- NAME: %s - TYPE: %s - LINE: %d\n", name, tip, yylineno);
     }
}

void addParam(char* tip, char* name){
     int index = searchP(name, tip);
     if(index != -1){
          printf("\33[31mError at line %d:\33[0m Parameter %s already exists!\n", yylineno, name);
          exit(-1);
     } else {
          int nr = func_table[count_function].param_no;
          if(nr == MAX_VAR_PARAM){
               printf("\33[31mError at line %d:\33[0m MAX NUMBER OF PARAMATERS REACHED!\n", yylineno, name, index);
               exit(-1);
          } else {
               func_table[count_function].param[nr].id_name = strdup(name);
               func_table[count_function].param[nr].data_type = strdup(tip);
               func_table[count_function].param[nr].line_no = yylineno;
               func_table[count_function].param_no++;
               printf("\33[34mFUNCTION PARAMETER \33[0m- NAME: %s - TYPE: %s - LINE: %d\n", func_table[count_function].param[nr].id_name, func_table[count_function].param[nr].data_type, func_table[count_function].param[nr].line_no);
          }
     }
}

void printv(char* string){
     printf("OUT: %s\n", string);
}

