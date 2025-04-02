%{
#include <math.h>
#include <stdio.h>

int yylex(void);
void yyerror(char const*);
%}

/* Bison declarations */
%define api.value.type {double}
%token NUM

%left '-' '+'
%left '*' '/'
%precedence NEG    /* negation -- unary minus */
%right '^'         /* exponentiation */

%%  /* The grammar follows */

input:
    %empty
    | input line
    ;

line:
    '\n'
    | exp '\n' { printf("%.10g\n", $1); }
    ;

exp:
    NUM
    | exp '+' exp { $$ = $1 + $3; }
    | exp '-' exp { $$ = $1 - $3; }
    | exp '*' exp { $$ = $1 * $3; }
    | exp '/' exp { $$ = $1 / $3; }
    | '-' exp %prec NEG { $$ = -$2; }
    | exp '^' exp { $$ = pow($1, $3); }
    | '(' exp ')' { $$ = $2; }
    ;

%%

#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

extern double yylval;

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
    }
    /* Process inf/nan */
    else if (c == 'i' || c == 'n') {
        char buf[4];
        int i = 0;
        buf[i++] = c;
        
        // Читаем следующие 2 символа для "inf" или 2 символа для "nan"
        while (i < 3 && (c = getchar()) != EOF) {
            buf[i++] = c;
        }
        buf[i] = '\0';
        
        if (strcasecmp(buf, "inf") == 0) {
            yylval = INFINITY;
            return NUM;
        }
        else if (strcasecmp(buf, "nan") == 0) {
            yylval = NAN;
            return NUM;
        }
        else {
            for (int j = i-1; j >= 0; j--) {
                ungetc(buf[j], stdin);
            }
        }
    }
    else if (c == EOF) {
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
