%{
	/*
	  * Made by ABDUL SATTAR MAPARA (BT16CSE053)
	  *	Date: 4th April, 2019 , 5th April, 2019
	  * Language Processors Assignment 3 (Semantic Analysis) - Question 5
      * Issue(s): Memory Leak To be done.
	*/
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #include "y.tab.h"
    extern int line_number;
    int max(int a,int b){
        if(a>b) return a;
        return b;
    }
    int yylex(void);

    void yyerror(char *s);
    extern char* yytext;

    #define MAX_VAR_SIZE 100
    #define INT_TYPE 1
    #define CHAR_TYPE 2
    #define OTHER 3
    #define UNKNOWN 0
    #define MAX_BLOCKS 100

    typedef struct TypeStructTag{
    	char varname[MAX_VAR_SIZE];
    	int vartype;
        int line_number;
    	struct TypeStructTag* nextVar;
    }TypeStruct;

    typedef struct LinkedListTag{
    	TypeStruct* decList;
        int current_block;
    	struct LinkedListTag* next[MAX_BLOCKS];
        struct LinkedListTag* prev;
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
    	(*ptr)->prev = NULL;
        (*ptr)->current_block = 0;
        for (int i = 0; i < MAX_BLOCKS; ++i)
        {
            (*ptr)->next[i]=NULL;
        }
    	printf("LinkedList initialized\n");
    }
    void addVar(LinkedList* ptr,char* type,int lineno,char* name){

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
	    			char msg_temp[500];
                    sprintf(msg_temp,"ERROR: Conflicting declarations for variable %s at line number %d, previous declaration found at line %d",name,lineno,traverseBlock->line_number);
                    strcpy(errornew->error_msg,msg_temp);
	    		}else{
	    			char msg_temp[500];
                    sprintf(msg_temp,"ERROR: Re-declarations for variable %s at line number %d, previous declaration found at line %d",name,lineno,traverseBlock->line_number);
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
    	ts->line_number = lineno;
    	TypeStruct* headts = ptr->decList;
    	ptr->decList = ts;
    	ts->nextVar = headts;


    }

    void addLevel(LinkedList* ptr){
    	LinkedList* newLevel = (LinkedList*)malloc(sizeof(LinkedList));
    	InitializeLinkedList(&newLevel);
    	newLevel->prev = linkedList;
        linkedList->next[linkedList->current_block] = newLevel;
        linkedList->current_block+=1;
    	linkedList = newLevel;
        printf("NEW LEVEL ADDED\n");
    	return;

    }
    void removeLevel(LinkedList* ptr){
        //goto previous level
        printf("GOING TO PREVIOUS LEVEL\n");
        linkedList=ptr->prev;
    }

    int getDepth(LinkedList* root){
        if(root == NULL){
            return 0;
        }else{
            int h1 = 0;
            for (int i = 0; i < MAX_BLOCKS; ++i)
            {
                h1 = max(h1,getDepth(root->next[i]));
            }
            return h1+1;
        }

    }

    void printLevel(LinkedList* root,int level){
        if(root == NULL) return;
        else if(level == 1){
            TypeStruct* typeList = root->decList;
            printf("NEW BLOCK (level = %d) ",getDepth(root));
            while(typeList != NULL){
                switch(typeList->vartype){
                    case INT_TYPE:
                        printf("int ");
                        break;
                    case CHAR_TYPE:
                        printf("char ");
                        break;
                    case OTHER:
                        printf("other ");
                        break;
                    case UNKNOWN:
                    default:
                        printf("UNKNOWN ");
                        break;
                }
                printf("%s (line %d); ",typeList->varname,typeList->line_number);
                typeList=typeList->nextVar;
        
            }
            printf("\n");
        }else{
            for (int i = 0; i < MAX_BLOCKS; ++i)
            {
                printLevel(root->next[i],level-1);
            }
        }
    }

    void printSymbolTable(){
        LinkedList* traverse = headLinkedList;
        int blk =0;
        int depth = getDepth(traverse);
        //printf("%d\n",depth);
        for(int i=1;i<= depth;i++){
            printLevel(traverse,i);
        }
        
        
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
										 char* pch = strtok($1,",");
                                         char type_temp[100];
                                         strcpy(type_temp,pch);
                                         pch = strtok(NULL,",");
                                         int temp_line = atoi(pch);
                                         addVar(linkedList,type_temp,temp_line,$2);
										}
ASSIGNMENT : VAR '=' VAR
OPERATION: VAR '=' EXPRESSION OP EXPRESSION
EXPRESSION: VAR | NUM
IFSTATEMENT: IFONLY
			| IFONLY ELSEIFSTATEMENTS
			| IFONLY ELSEIFSTATEMENTS ELSEONLY
			| IFONLY ELSEIFONLY
IFONLY: IFSTART '{' CODE '}' {
                                removeLevel(linkedList);
                             }

IFSTART: IF'(' CONDITION ')' {addLevel(linkedList);}
ELSEONLY: ELSESTART '{' CODE '}' { removeLevel(linkedList); }
ELSESTART : ELSE  {printf("else start\n");addLevel(linkedList);}
ELSEIFSTATEMENTS: ELSEIFONLY ELSEIFSTATEMENTS
                  | 
                  ELSEIFONLY
ELSEIFONLY: ELSEIFSTART '{' CODE '}' {removeLevel(linkedList);}

ELSEIFSTART: ELSEIF '(' CONDITION ')' {addLevel(linkedList);}

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

	printSymbolTable();

	Error* headErrorCopy = head_error;
	while(headErrorCopy != NULL){
		printf("---------------------------------\n%s\n-------------------------------\n",headErrorCopy->error_msg);
		headErrorCopy = headErrorCopy->next;
	}

	free(linkedList);
	linkedList=NULL;
    
 	return 0;
}
