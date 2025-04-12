%{
#include "y.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

extern int yylineno;
void yyerror(const char *);
%}

%option noyywrap nounput noinput
%option yylineno

%%

[ \t]+      ;    /* Ignore whitespace */
\n          ;    /* Ignore newlines (flex tracks line numbers) */

[0-9]+      { yylval.num = atoi(yytext); return NUMBER; }
"if"        { return IF; }
"else"      { return ELSE; }
"while"     { return WHILE; }
"print"     { return PRINT; }
[a-zA-Z]+   { yylval.id = strdup(yytext); return IDENTIFIER; }
"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return MULTIPLY; }
"/"         { return DIVIDE; }
"="         { return ASSIGN; }
">"         { return GT; }
"<"         { return LT; }
"=="        { return EQ; }
";"         { return SEMICOLON; }
"("         { return LPAREN; }
")"         { return RPAREN; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }

.           { 
              fprintf(stderr, "Line %d: Invalid character '", yylineno);
              if (isprint(yytext[0])) fprintf(stderr, "%c'\n", yytext[0]);
              else fprintf(stderr, "0x%02x'\n", yytext[0]);
              return ERROR;
            }

%%
