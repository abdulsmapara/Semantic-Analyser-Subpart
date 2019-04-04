%{
	/*
	  * Made by ABDUL SATTAR MAPARA (BT16CSE053)
	  *	Date: 4th April, 2019
	  * Language Processors Assignment 3 (Semantic Analysis) - Question 5
	*/
    #include<stdio.h>
    #include<stdlib.h>
    #include <string.h>
    #include "y.tab.h"
    int yylex(void);

    void yyerror(char *s);
    extern char* yytext;

    #define MAX_VAR_SIZE 100
    #define INT_TYPE 1
    #define CHAR_TYPE 2
    #define OTHER 3
    #define UNKNOWN 0
    
    typedef struct TypeStructTag{
    	char varname[MAX_VAR_SIZE];
    	int vartype;
    	struct TypeStructTag* nextVar;
    }TypeStruct;

    typedef struct LinkedListTag{
    	TypeStruct* decList;
    	struct LinkedListTag* next;
    }LinkedList;


    typedef struct ErrorTag{
    	char error_msg[1000];
    	struct ErrorTag* next;
    }Error;

    Error* head_error=NULL;
    Error* tailError=NULL;


    LinkedList* linkedList = NULL;
    LinkedList* headLinkedList = NULL;
    

    void InitializeLinkedList(LinkedList** ptr){
    	(*ptr)->decList = NULL;
    	(*ptr)->next = NULL;
    	printf("LinkedList initialized\n");
    }
    void addVar(LinkedList* ptr,char* type,char* name){

    	int vartype=0;
    	if(strcmp(type,"int") == 0){
    		vartype=INT_TYPE;
    	}else if(strcmp(type,"char") == 0){
    		vartype=CHAR_TYPE;
    	}else{
    		vartype=OTHER;
    	}


    	TypeStruct* traverseBlock = ptr->decList;
    	while(traverseBlock != NULL){
    		if(strcmp(traverseBlock->varname,name) == 0){
	    		//error case
	    		Error* errornew = (Error*)malloc(sizeof(Error));
	    		errornew->next = NULL;
	    		if(vartype != traverseBlock->vartype){
	    			char msg_temp[] = "ERROR: Conflicting declarations for variable ";
	    			strcat(msg_temp,name);
	    			strcpy(errornew->error_msg,msg_temp);
	    		}else{
	    			char msg_temp[] = "ERROR: Re-declarations for variable ";
	    			strcat(msg_temp,name);
	    			strcpy(errornew->error_msg,msg_temp);
	    		}
	    		Error* temperr = head_error;

	    		head_error = errornew;
	    		errornew->next = temperr;

	    		if(tailError == NULL && temperr == NULL){
	    			tailError = errornew;
	    		}

    		}
    		traverseBlock = traverseBlock->nextVar;
    	}


    	TypeStruct* ts = (TypeStruct*)malloc(sizeof(TypeStruct));
    	ts->vartype = vartype;
    	ts->nextVar = NULL;
    	strcpy(ts->varname,name);
    	
    	TypeStruct* headts = ptr->decList;
    	ptr->decList = ts;
    	ts->nextVar = headts;


    	

    	
    }
    void addLevel(LinkedList* ptr){
    	LinkedList* newLevel = (LinkedList*)malloc(sizeof(LinkedList));
    	InitializeLinkedList(&newLevel);
    	linkedList->next = newLevel;
    	linkedList = newLevel;

    	return;

    }

%}
%union {
        long int4;              /* Constant integer value */
        float fp;               /* Constant floating point value */
        char *str;              /* Ptr to constant string (strings are malloc'd) */
        //exprT expr;             /* Expression -  constant or address */
        //operatorT *operatorP;   /* Pointer to run-time expression operator */
 };

%token IF ELSE OP START TYPE ISEQUAL SEMICOLON VAR NUM ELSEIF
%type <str> VAR
%type <str> TYPE
%type <long> NUM
%left op

%%

PROGRAM : START '(' ')' '{' CODE '}'
CODE : CODE STATEMENT | STATEMENT CODE | STATEMENT
STATEMENT: ASSIGNMENT SEMICOLON 
		   | OPERATION SEMICOLON 
		   | IFSTATEMENT 
		   | DECLARATION SEMICOLON
DECLARATION : TYPE VAR /*modify here*/ {
										 printf("DECLARATION %s name-%s\n",$1,$2);
										 addVar(linkedList,$1,$2);
										}
ASSIGNMENT : VAR '=' VAR
OPERATION: VAR '=' VAR OP VAR
IFSTATEMENT: IFSTART '{' CODE '}'
			| IFSTART '{' CODE '}' ELSEIFSTATEMENTS
			| IFSTART '{' CODE '}' ELSEIFSTATEMENTS ELSESTART '{' CODE '}'
			| IFSTART '{' CODE '}' ELSESTART '{' CODE '}' 
IFSTART: IF'(' CONDITION ')' {printf("if start\n"); addLevel(linkedList);}
ELSESTART : ELSE  {printf("else start\n");addLevel(linkedList);}
ELSEIFSTATEMENTS: ELSEIFSTART '{' CODE '}' ELSEIFSTATEMENTS | ELSEIFSTART '{' CODE '}'
ELSEIFSTART: ELSEIF '(' CONDITION ')' {printf("else if start\n");addLevel(linkedList);}
/*
IFSTATEMENT : IF '(' CONDITION ')' '{' CODE '}' 
			  |
			  IF '(' CONDITION ')' '{' CODE '}' ELSE '{' CODE '}'  
*/

CONDITION : ASSIGNMENT | OPERATION | EQUALITY
EQUALITY: VAR ISEQUAL VAR
%%
void yyerror(char *s){
    printf("Error: %s",s);
}
int main(){
	linkedList = (LinkedList*)malloc(sizeof(LinkedList));
	headLinkedList = linkedList;
	

	InitializeLinkedList(&linkedList);

	yyparse();

	LinkedList* traverse = headLinkedList;
	int blk =0;
	while(traverse != NULL){
		TypeStruct* typeList = traverse->decList;
		while(typeList != NULL){
			printf("BLOCK %d %s\n",blk,typeList->varname);
			typeList=typeList->nextVar;
		}
		blk++;
		traverse = traverse->next;
	}
	Error* headErrorCopy = head_error;
	while(headErrorCopy != NULL){
		printf("---------------------------------\n%s\n-------------------------------\n",headErrorCopy->error_msg);
		headErrorCopy = headErrorCopy->next;
	}

	free(linkedList);
	linkedList=NULL;
    
 	return 0;
}
