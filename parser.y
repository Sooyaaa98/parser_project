%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *);
int yylex();
extern char *yytext;

/* Enhanced Symbol Table */
struct symbol {
    char *name;
    int value;
    struct symbol *next;
};

#define NHASH 9997
struct symbol *symtab[NHASH];

unsigned symhash(char *sym) {
    unsigned hash = 0;
    while (*sym) hash = hash * 9 + *sym++;
    return hash % NHASH;
}

struct symbol *lookup(char *sym) {
    struct symbol *sp = symtab[symhash(sym)];
    while (sp) {
        if (strcmp(sp->name, sym) == 0) return sp;
        sp = sp->next;
    }
    
    sp = malloc(sizeof(struct symbol));
    sp->name = strdup(sym);
    sp->value = 0;
    sp->next = symtab[symhash(sym)];
    symtab[symhash(sym)] = sp;
    return sp;
}
%}

%union {
    int num;
    char *id;
}

%token ERROR
%token <num> NUMBER
%token <id> IDENTIFIER
%token PLUS MINUS MULTIPLY DIVIDE ASSIGN
%token GT LT EQ      /* Comparison operators */
%token SEMICOLON LPAREN RPAREN LBRACE RBRACE
%token IF ELSE WHILE PRINT

/* Operator precedence */
%left OR
%left AND
%left NOT
%left GT LT EQ
%left PLUS MINUS
%left MULTIPLY DIVIDE
%right ASSIGN
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%type <num> expr condition

%%

program:
    /* empty */
    | program statement
    ;

statement:
    expr SEMICOLON
    | PRINT expr SEMICOLON { printf("Print: %d\n", $2); }
    | if_stmt
    | WHILE LPAREN condition RPAREN statement
    | LBRACE program RBRACE
    | error SEMICOLON { yyerrok; fprintf(stderr, "Error recovered\n"); }
    ;

if_stmt:
    IF LPAREN condition RPAREN statement %prec LOWER_THAN_ELSE {
        if ($3) {} /* Condition was true */
    }
    | IF LPAREN condition RPAREN statement ELSE statement {
        if (!$3) { /* Execute else part */ }
    }
    ;

condition:
    expr GT expr { $$ = $1 > $3 ? 1 : 0; }
    | expr LT expr { $$ = $1 < $3 ? 1 : 0; }
    | expr EQ expr { $$ = $1 == $3 ? 1 : 0; }
    | LPAREN condition RPAREN { $$ = $2; }
    ;

expr:
    NUMBER
    | IDENTIFIER { 
        $$ = lookup($1)->value;
        printf("Access: %s = %d\n", $1, $$);
      }
    | expr PLUS expr { $$ = $1 + $3; }
    | expr MINUS expr { $$ = $1 - $3; }
    | expr MULTIPLY expr { $$ = $1 * $3; }
    | expr DIVIDE expr { 
        if ($3 == 0) {
            yyerror("Division by zero");
            YYERROR;
        }
        $$ = $1 / $3;
      }
    | IDENTIFIER ASSIGN expr { 
        lookup($1)->value = $3;
        $$ = $3;
        printf("Assign: %s = %d\n", $1, $3);
      }
    | LPAREN expr RPAREN { $$ = $2; }
    | ERROR { $$ = 0; }
    ;

%%

void yyerror(const char *s) {
    extern int yylineno;
    fprintf(stderr, "Line %d: %s\n", yylineno, s);
    if (yytext) fprintf(stderr, "Near token: %s\n", yytext);
}

int main() {
    printf("Parser ready. Enter expressions:\n");
    yyparse();
    return 0;
}
