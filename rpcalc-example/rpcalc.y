/*
 * Reverse Polish Notation calculator 
 * 1 2 + 3 * = 9
 */

%{
#include <stdio.h>
#include <math.h>

int yylex();
void yyerror(char const *);
%}

/* Type for semantic values (default int) */
%define api.value.type {double}

/* Each terminal symbol that is not a single-character literal must be declared */

/* Token kind for numeric constants */
%token NUM

%%

/* Nonterminal symbols: input, line, exp */

input:
  %empty
| input line
;

line:
  '\n'
| exp '\n'      { printf ("%.10g\n", $1); }
;

exp:
  NUM
| exp exp '+'   { $$ = $1 + $2; printf("Rule +\n"); }
| exp exp '-'   { $$ = $1 - $2; printf("Rule -\n");      }
| exp exp '*'   { $$ = $1 * $2; printf("Rule *\n");      }
| exp exp '/'   { $$ = $1 / $2; printf("Rule /\n");      }
| exp exp '^'   { $$ = pow ($1, $2); printf("Rule ^\n"); }  /* Exponentiation */
| exp 'n'       { $$ = -$1; printf("Rule M\n");          }  /* Unary minus   */
;
%%

#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>

int yylex()
{
    int c = getchar();
    while (c == ' ' || c == '\t') {
        c = getchar();
    }

    /* Process floating point numbers */
    if (c == '.' || isdigit(c)) {
        ungetc(c, stdin);
        if (scanf("%lf", &yylval) != 1)
            abort();
        return NUM;
    } else if (c == EOF) {
        return YYEOF;
    }
    /* Single char token */
    return c;
}

/* Called by yyparse on error */
void yyerror (char const *s)
{
    fprintf (stderr, "Error: %s\n", s);
}

int main()
{
    return yyparse();
}
