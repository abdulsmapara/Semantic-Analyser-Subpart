%{
	/*
	  * Made by ABDUL SATTAR MAPARA (BT16CSE053)
	  *	Date: 4th April, 2019 , 5th April, 2019
	  * Language Processors Assignment 3 (Semantic Analysis) - Question 5
	*/
	#include "y.tab.h"
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	int line_number = 1;

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
		char line_num_temp[100];
		sprintf(line_num_temp,",%d",line_number);
		strcat(yylval.str,line_num_temp);
		return TYPE;
	  }
"char" {
		yylval.str = strdup(yytext);
		char line_num_temp[100];
		sprintf(line_num_temp,",%d",line_number);
		strcat(yylval.str,line_num_temp);
		return TYPE;
	  }
";" {return SEMICOLON;}
[a-zA-Z_][a-zA-Z0-9_]* { 
						yylval.str = strdup(yytext);
						return VAR;}
[+-/*^&|]	{ return OP; }
[=,{}();] {return *yytext;}

[ \t]+	{}
[\n] {line_number++;}
.	{}

%%

int yywrap(){
    return 1;
}


