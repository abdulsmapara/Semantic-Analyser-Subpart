%{
	#include "y.tab.h"
	#include <stdio.h>
	#include <string.h>

%}

digit [0-9]
%%
"int main" {return START;}


"if" {return IF;}
"else" {return ELSE;}
"else if" {return ELSEIF;}
[0-9]+ { yylval.str = strdup(yytext);
	return NUM;
	}
"==" {return ISEQUAL;}
"int" {
		yylval.str = strdup(yytext);
		return TYPE;
	  }
"char" {
		yylval.str = strdup(yytext);
		return TYPE;
	  }
";" {return SEMICOLON;}
[a-zA-Z_][a-zA-Z0-9_]* { 
						yylval.str = strdup(yytext);
						return VAR;}
[+-/*^&|]	{ return OP; }
[=,{}();] {return *yytext;}

[ \t\n]+	{}
.	{}

%%

int yywrap(){
    return 1;
}


