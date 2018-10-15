%{
#include <stdlib.h>
#include<iostream>
#include<fstream>
#include <stdio.h>
#include<cstring>
#include<string>
#include<string.h>
#include "1305037_SymbolInfo.h"
#include "1305037_SymbolTable.h"

#define YYSTYPE SymbolInfo*

using namespace std;

int pFlag=0;
int yyparse(void);
int yylex(void);
double var[26];

extern int lCount;
extern int errCount;

int dataType;

SymbolTable *hashTable=new SymbolTable(30);
FILE *output=fopen("1305037_log.txt","w");

void yyerror(char const*s)
{fprintf(output,"%s %d %c %s\n","Error at Line ",lCount,':',s);
errCount++;
}
ofstream fout; 
int labelCount=0;
int tempCount=0;
string initialAsm="Title Prog: codeGeneration\n.MODEL SMALL\n.STACK 100H\n.DATA\n ";
string declarationAsm="";
string codeAsm=".CODE\nMAIN PROC\nMOV AX,@DATA\nMOV DS,AX\n";
string endAsm="END MAIN"; 



char *newLabel()
{
	char *lb= new char[4];
	strcpy(lb,"L");
	char b[3];
	sprintf(b,"%d", labelCount);
	labelCount++;
	strcat(lb,b);
	return lb;
}

char *newTemp()
{
	char *t= new char[4];
	strcpy(t,"t");
	char b[3];
	sprintf(b,"%d", tempCount);
	tempCount++;
	strcat(t,b);
	 declarationAsm+=string(t)+" dw " + "?\n";
	return t;
}


int getVal(char c)
{
	if(c=='0') return 0;
	else if(c=='a') return 7;
	else if(c=='b') return 8;
	else if(c=='t') return 9;
	else if(c=='n') return 10;
	else if(c=='v') return 11;
	else if(c=='f') return 12;
	else if(c=='r') return 13;
	else if(c=='"') return 34;
	else if(c=='\\') return 92;
}




%}

%error-verbose
%token CONST_FLOAT  CONST_INT ADDOP MULOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD SEMICOLON COMMA IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE CONTINUE DEFAULT MAIN  ASSIGNOP INCOP DECOP RELOP LOGICOP CONST_CHAR ID PRINTLN STRING

%nonassoc "then"
%nonassoc ELSE






%%
Program : INT MAIN LPAREN RPAREN compound_statement 

		{fprintf(output,"%s","Program : INT MAIN LPAREN RPAREN compound_statement\n\n");
		
	
		fout<<initialAsm+declarationAsm+codeAsm+$5->code+endAsm;
		
		}
		
		
	;




compound_statement : LCURL var_declaration statements RCURL {
			fprintf(output,"%s","compound_statement : LCURL var_declaration statements RCURL\n\n");
			$$=$3;
			
			$$->code=$2->code+$3->code;
			}

		   | LCURL statements RCURL
			{fprintf(output,"%s","compound_statement : LCURL statements RCURL\n\n"); $$=$2;}

		   | LCURL RCURL 
			{fprintf(output,"%s","compound_statement : LCURL CURL\n\n");
			$$=new SymbolInfo("compound_statement","dummy");
			}
		   ;

		


	 
var_declaration	: type_specifier declaration_list SEMICOLON {
			fprintf(output,"%s","var_declaration	: type_specifier declaration_list SEMICOLON \n\n");
			$$=$2;
			
			
		}

		|  var_declaration type_specifier declaration_list SEMICOLON {
			$$=$1;
		
			$$->code+=$3->code;
			fprintf(output,"%s","var_declaration	:var_declaration type_specifier declaration_list SEMICOLON \n\n");}
		;





type_specifier	: INT {fprintf(output,"%s","type_specifier: INT\n\n"); dataType=1;$$= new SymbolInfo("int","type");}
		| FLOAT {fprintf(output,"%s","type_specifier: FLOAT\n\n"); dataType=2;$$= new SymbolInfo("float","type");}
		| CHAR {fprintf(output,"%s","type_specifier: CHAR\n\n"); dataType=3;$$= new SymbolInfo("char","type");}
		;



			
declaration_list : declaration_list COMMA ID {

			fprintf(output,"%s","declaration_list :declaration_list COMMA ID\n");
		     	fprintf(output,"%s\n\n",$3->getName());
			
			if(hashTable->Insert($3)[0]==-1)
				{fprintf(output,"%s %d %s %s\n\n","Error at line ",lCount," : Multiple Declaration of ",$3->getName());errCount++;}
			else {$3->setVType(dataType);declarationAsm+=string($3->getName())+" dw " + "?\n";}
			//hashTable->printTable(output);
		}
		 | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD{ 

			fprintf(output,"%s","declaration_list :declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n");
			fprintf(output,"%s\n\n",$3->getName());
			
			if(hashTable->Insert($3)[0]==-1)
				{fprintf(output,"%s %d %s %s\n\n","Error at line ",lCount," : Multiple Declaration of ",$3->getName());errCount++;}
			else {$3->setVType(dataType);
			$3->setArrSize($5->ival);
			declarationAsm+=string($3->getName())+" dw ";
						for(int i=0;i<$5->ival-1;i++){
							declarationAsm += "?, " ;
						}
						declarationAsm+="?\n";
			$3->iniArr($3->getName(),$3->getType());}
		}

		 | ID {
			fprintf(output,"%s","declaration_list :ID\n");
			fprintf(output,"%s\n\n",$1->getName());
			
			//hashTable->Insert($1);
				if(hashTable->Insert($1)[0]==-1){fprintf(output,"%s %d %s %s\n\n","Error at line ",lCount," : Multiple Declaration of ",$1->getName());errCount++;}
				else {$1->setVType(dataType);
			        declarationAsm+=string($1->getName())+" dw " + "?\n";
				}
		}

		 | ID LTHIRD CONST_INT RTHIRD {
			fprintf(output,"%s","declaration_list :ID LTHIRD CONST_INT RTHIRD\n");
			fprintf(output,"%s\n\n",$1->getName());
			
			//hashTable->Insert($1);
				if(hashTable->Insert($1)[0]==-1){fprintf(output,"%s %d %s %s\n\n","Error at line ",lCount," : Multiple Declaration of ",$1->getName());errCount++;}
				else {$1->setVType(dataType);
			$1->setArrSize($3->ival);
			
			declarationAsm+=string($1->getName())+" dw ";
						for(int i=0;i<$3->ival-1;i++){
							declarationAsm += "?, " ;
						}
						declarationAsm+="?\n";
			$1->iniArr($1->getName(),$1->getType());}	
		}
		 ;




statements : statement {fprintf(output,"%s","statements: statement\n\n");//cout<<"st:"<<$$->code<<"\n\n";
}
	   | statements statement {fprintf(output,"%s","statements: statements statement\n\n");
	   			$$=$1;
	   			
				$$->code += $2->code;
				//fout<<"7777{"<<$$->code<<"}"<<endl;
				}
	   ;



statement  : expression_statement {fprintf(output,"%s","statement  : expression_statement\n\n");//fout<<"6666{"<<$$->code<<"}"<<endl;
	//cout << $1->code << endl;
}
	   | compound_statement {fprintf(output,"%s","statement  :  compound_statement\n\n");}
	   | FOR LPAREN expression_statement expression_statement expression RPAREN statement 			{
		fprintf(output,"%s","statement  :  FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n");
		
				
					$$=$3;
					char *label1=newLabel();
					char *label2=newLabel();
					$$->code+=string(label1)+":"+"\n";
					$$->code+=$4->code;
					$$->code+="mov ax, "+string($4->getName())+"\n";
					$$->code+="cmp ax, 1\n";
					$$->code+="jne "+string(label2)+"\n";
					$$->code+=$7->code;
					$$->code+=$5->code;
					$$->code+="jmp "+string(label1)+"\n";
					$$->code+=string(label2)+":"+"\n";
					
					
		} 

	   | IF  LPAREN expression RPAREN statement %prec "then"
		{fprintf(output,"%s","statement  :  IF LPAREN expression RPAREN statement\n\n");
		//cout << "statement  :  IF LPAREN expression RPAREN statement\n\n";
		$$=$3;
		//cout<<$5->code;
					
					char *label=newLabel();
					$$->code+="mov ax, "+string($3->getName())+"\n";
					$$->code+="cmp ax, 1\n";
					$$->code+="jne "+string(label)+"\n";
					$$->code+=$5->code;
					
					$$->code+=string(label)+":\n";
					
					$$->setName("if");//not necessary
		}
		//else break;

	   | IF LPAREN expression RPAREN statement ELSE statement 
		{fprintf(output,"%s","statement  :   IF LPAREN expression RPAREN statement ELSE statement\n\n");
		//$$=new SymbolInfo();
		$$=$3;
					
					char *label=newLabel();
					char *label2=newLabel();
					$$->code+="mov ax, "+string($3->getName())+"\n";
					$$->code+="cmp ax, 1\n";
					$$->code+="jne "+string(label)+"\n";
					$$->code+=$5->code;
					$$->code+="jmp "+string(label2)+"\n";
					$$->code+=string(label)+":\n";
					$$->code+=$7->code;
					$$->code+=string(label2)+":\n";
					$$->setName("if");//not necessary
		}

	   | WHILE LPAREN expression RPAREN statement
		 {fprintf(output,"%s","statement  :  WHILE LPAREN expression RPAREN statement\n\n");
		 
		 $$=new SymbolInfo($3);
					char *label1=newLabel();
					char *label2=newLabel();
					$$->code=string(label1)+":"+"\n";
					$$->code+=$3->code;
					$$->code+="mov ax, "+string($3->getName())+"\n";
					$$->code+="cmp ax, 1\n";
					$$->code+="jne "+string(label2)+"\n";
					$$->code+=$5->code;
					$$->code+="jmp "+string(label1)+"\n";
					$$->code+=string(label2)+":"+"\n";
		 
		 }
	   | PRINTLN LPAREN ID RPAREN SEMICOLON
		 {fprintf(output,"%s","statement  :  PRINTLN LPAREN ID RPAREN SEMICOLON\n\n");
		 
		 SymbolInfo *s=hashTable->LookUpTo($3->getName());
		 if(!s) {fprintf(output,"%s %d %s %s\n\n","Error at line ",lCount," : Undeclared Variable ",$3->getName());errCount++;}
		else 
			{
			
			
			$$=$3;
			$$->code+="mov ax,"+string($3->getName())+"\n";
			$$->code+="call outdec\n";
			pFlag=1;
			
			//$$->code+="mov dx, $3->getName()\n";
			//$$->code+="mov ah, 2\nint 21h\n";
			
			
			if(s->arrSize==-1){
			if(s->vType==1) printf("%s = %d\n",s->getName(),s->ival);
			else if(s->vType==2) printf("%s = %f\n",s->getName(),s->dval);
			else if(s->vType==3) printf("%s = %c\n",s->getName(),s->cval);}
			
			else 
			{	printf("%s = {",s->getName());
				
				
				if(s->vType==1) 
				{
					//fprintf(output,"{");
					for(int i=0;i<s->arrSize;i++)
					{
					int j=s->siArr[i]->ival;
						printf("%d,",j);
					}
					printf("%s","}");
				}	
				else if(s->vType==2) 
				{
					fprintf(output,"{");
					for(int i=0;i<s->arrSize;i++)
					{
					float j=s->siArr[i]->dval;
						printf("%f,",j);
					}
					printf("%s","}");
				}
			
				else if(s->vType==3) 
				{
					//fprintf(output,"{");
					for(int i=0;i<s->arrSize;i++)
					{
					char j=s->siArr[i]->cval;
						printf("%c,",j);
					}
					printf("%s","}");
				}
			}
		 } 
		 
		 }

	   | RETURN expression SEMICOLON  
		{fprintf(output,"%s","statement  :   RETURN expression SEMICOLON\n\n");
		$$=$2;
		$$->code+="MOV AH,4CH\nINT 21H\nMAIN ENDP\n";
		if(pFlag==1)
		{
		$$->code+= "\n\nOUTDEC PROC\n\
;INPUT AX\n\
PUSH AX\n\
PUSH BX\n\
PUSH CX\n\
PUSH DX\n\
OR AX,AX\n\
JGE @END_IF1\n\
PUSH AX\n\
MOV DL,'-'\n\
MOV AH,2\n\
INT 21H\n\
POP AX\n\
NEG AX\n\
\n\
@END_IF1:\n\
XOR CX,CX\n\
MOV BX,10D\n\
\n\
@REPEAT1:\n\
XOR DX,DX\n\
DIV BX\n\
PUSH DX\n\
INC CX\n\
OR AX,AX\n\
JNE @REPEAT1\n\
\n\
MOV AH,2\n\
\n\
@PRINT_LOOP:\n\
\n\
POP DX\n\
OR DL,30H\n\
INT 21H\n\
LOOP @PRINT_LOOP\n\
\n\
POP DX\n\
POP CX\n\
POP BX\n\
POP AX\n\
RET\n\
OUTDEC ENDP\n";

		
		}
		}
	   ;



		
expression_statement	: SEMICOLON		{fprintf(output,"%s","expression_statement	: SEMICOLON\n\n");}	
			| expression SEMICOLON  {fprintf(output,"%s","expression_statement	: expression SEMICOLON\n\n");
			
			$$=$1;
			
			//cout<<"ex state:"<<$$->code<<"\n\n";
			//fout<<"8888{"<<$$->code<<"}"<<endl;
			}
			;



						
variable : ID 		 {	
			fprintf(output,"%s","variable : ID \n");fprintf(output,"%s\n\n",$1->getName());
			SymbolInfo* s=hashTable->LookUpTo($1->getName());
			if(!s){fprintf(output,"%s %d %s %s\n\n","Error at line ",lCount," : Undeclared Variable ",$1->getName());errCount++;}
			else $$=s;
			
			}

	 | ID LTHIRD expression RTHIRD  {
			fprintf(output,"%s","variable : ID LTHIRD expression RTHIRD \n");
			fprintf(output,"%s\n\n",$1->getName());
			SymbolInfo* s=hashTable->LookUpTo($1->getName());
			
			//cout << endl << "^^^^^^^^^" << $3->getName() << endl;

			if(!s){$$=s;fprintf(output,"%s %d %s %s\n\n","Error at line ",lCount," : Undeclared Variable ",$1->getName());}
			else
				{
					if($3->vType!=1) {}
					else if ($3->ival>=s->arrSize){fprintf(output,"%s %d %s\n\n","Error at line ",lCount," : Array Index Out of Bound ");errCount++;}
					else {
					
						//printf("arr:%d\n",$3->ival);
						$$=s->siArr[$3->ival];
						$$->code=$3->code;
					
						$$->code+="lea di, " + string($1->getName())+"\n";
						for(int i=0;i<2;i++){
							$$->code += "add di, " + (string)$3->getName() +"\n";
						}
						
				
			
				//fout<<"{"<<$$->code<<"}"<<endl;
				
					      }
				}
			}
	 ;


			
expression : logic_expression	 {fprintf(output,"%s","expression : logic_expression\n\n");//hashTable->printTable(output);
//fout<<"000"<<"{"<<$$->code<<"}"<<endl;
//cout<<"exp"<<$$->code<<"\n\n";
}

	   | variable ASSIGNOP logic_expression  {
	//   printf("%s",$1->getName());
		SymbolInfo* s=hashTable->LookUpTo($1->getName());
		
		
		fprintf(output,"%s","expression : variable ASSIGNOP logic_expression\n\n");	
		//SymbolInfo* s=$1;//hashTable->LookUpTo($1->getName());
		
		
		$$=$3;
		
		$$->code+=$1->code;
		//fout<<"$$:"<<$$->code<<endl;
	//	fout<<"4441{"<<$$->code<<"}"<<endl;
		if($1->arrSize!=-1) 
			{
				fprintf(output,"%s %d %s \n\n","Error at line ",lCount," : Type Mismatch ");
				errCount++;
			}

		else 	{
		
		if(s->arrSize>-1)
		{
			$$->code+="mov ax, "+string($3->getName())+"\n";
			string str="mov [di],ax\n";
			$$->code+=str;
		}
				//printf("%s",$$->getName());
			else
			{	$$->code+="mov ax, "+string($3->getName())+"\n";
				$$->code+= "mov "+string($1->getName())+", ax\n";}
				
			if($1->vType != $3->vType) {//printf("2");
			
				//if()/*???error not  matched*/}//else if//float=char float=int float=char


				if($1->vType==2) 

					 {fprintf(output,"%s %d %s \n\n","Warning at line ",lCount," : Type Mismatch ");
					   if($3->vType==1) $1->dval=(double)$3->ival;
					   else if($3->vType==3 && $3->charType==1) {$1->dval=(double)$3->cval;}
					   else if($3->vType==3 && $3->charType==2) {$1->dval=(double)(getVal($3->cval));}
					 }

				else if($1->vType==1) 

					 {fprintf(output,"%s %d %s \n\n","Warning at line ",lCount," : Type Mismatch ");
					   if($3->vType==2) $1->ival=(int)$3->dval;
					   else if($3->vType==3 && $3->charType==1) {$1->ival=(int)$3->cval;}
					   else if($3->vType==3 && $3->charType==2) {$1->ival=getVal($3->cval);}
					 }

				else if($1->vType==3) 

					 {fprintf(output,"%s %d %s \n\n","Warning at line ",lCount," : Type Mismatch ");
					   if($3->vType==1){ $1->cval=(char)$3->ival;
						//printf("%c",$1->cval);
						int i=$3->ival;
						if(i==0||i==7||i==8||i==9||i==10||i==11||i==12||i==13||i==34||i==92) $1->charType=2;
						else $1->charType=1;}
					else{
					fprintf(output,"%s %d %s \n\n","Error at line ",lCount," : Type Mismatch ");
					errCount++;}
					}
						 }
			
				


			else	{//printf("3");
				
				if($1->vType==1) {$1->ival=$3->ival;}
				else if($1->vType==2) {$1->dval=$3->dval;}
				else if($1->vType==3) {$1->cval=$3->cval;$1->charType=$3->charType;}
				
				
				}//	$$=$1;
			hashTable->printTable(output);
			}
			//fout<<"4444{"<<$$->code<<"}"<<endl;
			}

			
	   ;


			
logic_expression : rel_expression 	 {//fout<<"3333{"<<$$->code<<"}"<<endl;
fprintf(output,"%s","logic_expression : rel_expression \n\n");//hashTable->printTable(output);
//fout<<"{"<<$1->code<<"}"<<endl;
//cout << endl << "nnnnnnnnn" << $1->code << endl;
//cout<<"logic"<<$$->code<<"\n\n";
}
		 | rel_expression LOGICOP rel_expression 	

			 {fprintf(output,"%s","logic_expression : rel_expression LOGICOP rel_expression  \n\n");
			 

			SymbolInfo *s=new SymbolInfo($1);$$=s;
			$$->code=$1->code+$3->code;
				
				
				char *temp=newTemp();
				char *label1=newLabel();
				char *label2=newLabel();
			if(!strcmp($2->getName(),"&&")) 
				{
				
				$$->code+="mov ax, " + string($1->getName())+"\n";
				$$->code+="cmp ax, " + string("1") +"\n";
				$$->code+="jl , " + string(label1)+"\n";
				$$->code+="mov ax, " + string($3->getName())+"\n";
				$$->code+="cmp ax, " + string("1")+"\n";
				$$->code+="jl , " + string(label1)+"\n";
				$$->code+="mov "+string(temp) +", 1\n";
				$$->code+="jmp "+string(label2) +"\n";
				$$->code+=string(label1)+":\nmov "+string(temp)+", 0\n";
				
				
					if($1->vType==1 && $3->vType==1){$$->ival=$1->ival&&$3->ival;$$->vType=1;}
					else if($1->vType==2 &&$3->vType==2){$$->dval=$1->dval&&$3->dval;$$->vType=2;}
					else if($1->vType==3 &&$3->vType==3){$$->cval=$1->cval&&$3->cval;$$->vType=3;}
					else if($1->vType==1 && $3->vType==2 ){$$->dval=$1->ival&&$3->dval;$$->vType=2;}
					else if($1->vType==2 && $3->vType==1 ){$$->dval=$1->dval&&$3->ival;$$->vType=2;}
					else if($1->vType==1 && $3->vType==3 ){$$->ival=$1->ival&&$3->cval;$$->vType=1;}
					else if($1->vType==3 && $3->vType==1 ){$$->ival=$1->cval&&$3->ival;$$->vType=1;}
					else if($1->vType==2 && $3->vType==3 ){$$->dval=$1->dval&&$3->cval;$$->vType=2;}
					else if($1->vType==3 && $3->vType==2 ){$$->dval=$1->cval&&$3->dval;$$->vType=2;}
					
				}

			   else if(!strcmp($2->getName(),"||")) 
				{
				
				{
				
				$$->code+="mov ax, " + string($1->getName())+"\n";
				$$->code+="cmp ax, " + string("1")+"\n";
				$$->code+="jge , " + string(label1)+"\n";
				$$->code+="mov ax, " + string($3->getName())+"\n";
				$$->code+="cmp ax, " +string( "1")+"\n";
				$$->code+="jge , " + string(label1)+"\n";
				$$->code+="mov "+string(temp) +", 0\n";
				$$->code+=string(label1)+":\nmov "+string(temp)+", 1\n";
				
					if($1->vType==1&&$3->vType==1){$$->ival=$1->ival||$3->ival;$$->vType=1;}
					else if($1->vType==2&&$3->vType==2){$$->dval=$1->dval||$3->dval;$$->vType=2;}
					else if($1->vType==3&&$3->vType==3){$$->cval=$1->cval||$3->cval;$$->vType=3;}
					else if($1->vType==1 && $3->vType==2 ){$$->dval=$1->ival||$3->dval;$$->vType=2;}
					else if($1->vType==2 && $3->vType==1 ){$$->dval=$1->dval||$3->ival;$$->vType=2;}
					else if($1->vType==1 && $3->vType==3 ){$$->ival=$1->ival||$3->cval;$$->vType=1;}
					else if($1->vType==3 && $3->vType==1 ){$$->ival=$1->cval||$3->ival;$$->vType=1;}
					else if($1->vType==2 && $3->vType==3 ){$$->dval=$1->dval||$3->cval;$$->vType=2;}
					else if($1->vType==3 && $3->vType==2 ){$$->dval=$1->cval||$3->dval;$$->vType=2;}
					
				}
				
				
				$$->code+=string(label2)+":\n";
				$$->setName(temp);
			
				//hashTable->printTable(output);	
				}
			


}
		 ;



			
rel_expression	: simple_expression  {fprintf(output,"%s","rel_expression	: simple_expression\n\n");//fout<<"2222{"<<$$->code<<"}"<<endl;//hashTable->printTable(output);
//fout<<"{"<<$1->code<<"}"<<endl;
}
		| simple_expression RELOP simple_expression	
			 {fprintf(output,"%s","rel_expression	: simple_expression RELOP simple_expression\n\n");
			
			SymbolInfo *s=new SymbolInfo($1);$$=s;
			//$$=$1;
				$$->code+=$3->code;
				$$->code+="mov ax, " + string($1->getName())+"\n";
				$$->code+="cmp ax, " + string($3->getName())+"\n";
				char *temp=newTemp();
				char *label1=newLabel();
				char *label2=newLabel();
			if(!strcmp($2->getName(),">=")) 
				{
				
					$$->code+="jge " + string(label1)+"\n";
					if($1->vType==1&&$3->vType==1){$$->ival=$1->ival>=$3->ival;$$->vType=1;}
					else if($1->vType==2&&$3->vType==2){$$->dval=$1->dval>=$3->dval;$$->vType=2;}
					else if($1->vType==3&&$3->vType==3){$$->cval=$1->cval>=$3->cval;$$->vType=3;}
					else if($1->vType==1 && $3->vType==2 ){$$->dval=$1->ival>=$3->dval;$$->vType=2;}
					else if($1->vType==2 && $3->vType==1 ){$$->dval=$1->dval>=$3->ival;$$->vType=2;}
					else if($1->vType==1 && $3->vType==3 ){$$->ival=$1->ival>=$3->cval;$$->vType=1;}
					else if($1->vType==3 && $3->vType==1 ){$$->ival=$1->cval>=$3->ival;$$->vType=1;}
					else if($1->vType==2 && $3->vType==3 ){$$->dval=$1->dval>=$3->cval;$$->vType=2;}
					else if($1->vType==3 && $3->vType==2 ){$$->dval=$1->cval>=$3->dval;$$->vType=2;}
					
				}

			   else if(!strcmp($2->getName(),"<=")) 
				{
					$$->code+="jle " + string(label1)+"\n";
					if($1->vType==1&& $3->vType==1){$$->ival=$1->ival<=$3->ival;$$->vType=1;}
					else if($1->vType==2&& $3->vType==2){$$->dval=$1->dval<=$3->dval;$$->vType=2;}
					else if($1->vType==3&& $3->vType==3){$$->cval=$1->cval<=$3->cval;$$->vType=3;}
					else if($1->vType==1 && $3->vType==2 ){$$->dval=$1->ival<=$3->dval;$$->vType=2;}
					else if($1->vType==2 && $3->vType==1 ){$$->dval=$1->dval<=$3->ival;$$->vType=2;}
					else if($1->vType==1 && $3->vType==3 ){$$->ival=$1->ival<=$3->cval;$$->vType=1;}
					else if($1->vType==3 && $3->vType==1 ){$$->ival=$1->cval<=$3->ival;$$->vType=1;}
					else if($1->vType==2 && $3->vType==3 ){$$->dval=$1->dval<=$3->cval;$$->vType=2;}
					else if($1->vType==3 && $3->vType==2 ){$$->dval=$1->cval<=$3->dval;$$->vType=2;}
					
				}
				
			else if(!strcmp($2->getName(),">")) 
				{
					$$->code+="jg " + string(label1)+"\n";
					if($1->vType==1&&$3->vType==1){$$->ival=$1->ival>$3->ival;$$->vType=1;}
					else if($1->vType==2&&$3->vType==2){$$->dval=$1->dval>$3->dval;$$->vType=2;}
					else if($1->vType==3&&$3->vType==3){$$->cval=$1->cval>$3->cval;$$->vType=3;}
					else if($1->vType==1 && $3->vType==2 ){$$->dval=$1->ival>$3->dval;$$->vType=2;}
					else if($1->vType==2 && $3->vType==1 ){$$->dval=$1->dval>$3->ival;$$->vType=2;}
					else if($1->vType==1 && $3->vType==3 ){$$->ival=$1->ival>$3->cval;$$->vType=1;}
					else if($1->vType==3 && $3->vType==1 ){$$->ival=$1->cval>$3->ival;$$->vType=1;}
					else if($1->vType==2 && $3->vType==3 ){$$->dval=$1->dval>$3->cval;$$->vType=2;}
					else if($1->vType==3 && $3->vType==2 ){$$->dval=$1->cval>$3->dval;$$->vType=2;}
					
				}

			   else if(!strcmp($2->getName(),"<")) 
				{
				
					$$->code+="jl " + string(label1)+"\n";
					if($1->vType==1&&$3->vType==1){$$->ival=$1->ival-$3->ival;$$->vType=1;}
					else if($1->vType==2&&$3->vType==2){$$->dval=$1->dval-$3->dval;$$->vType=2;}
					else if($1->vType==3&&$3->vType==3){$$->cval=$1->cval-$3->cval;$$->vType=3;}
					else if($1->vType==1 && $3->vType==2 ){$$->dval=$1->ival<$3->dval;$$->vType=2;}
					else if($1->vType==2 && $3->vType==1 ){$$->dval=$1->dval<$3->ival;$$->vType=2;}
					else if($1->vType==1 && $3->vType==3 ){$$->ival=$1->ival<$3->cval;$$->vType=1;}
					else if($1->vType==3 && $3->vType==1 ){$$->ival=$1->cval<$3->ival;$$->vType=1;}
					else if($1->vType==2 && $3->vType==3 ){$$->dval=$1->dval<$3->cval;$$->vType=2;}
					else if($1->vType==3 && $3->vType==2 ){$$->dval=$1->cval<$3->dval;$$->vType=2;}
					
				}
			

			   else if(!strcmp($2->getName(),"==")) 
				{
					$$->code+="je " + string(label1)+"\n";
					if($1->vType==1&&$3->vType==1){$$->ival=$1->ival==$3->ival;$$->vType=1;}
					else if($1->vType==2&&$3->vType==2){$$->dval=$1->dval==$3->dval;$$->vType=2;}
					else if($1->vType==3&&$3->vType==3){$$->cval=$1->cval==$3->cval;$$->vType=3;}
					else if($1->vType==1 && $3->vType==2 ){$$->dval=$1->ival==$3->dval;$$->vType=2;}
					else if($1->vType==2 && $3->vType==1 ){$$->dval=$1->dval==$3->ival;$$->vType=2;}
					else if($1->vType==1 && $3->vType==3 ){$$->ival=$1->ival==$3->cval;$$->vType=1;}
					else if($1->vType==3 && $3->vType==1 ){$$->ival=$1->cval==$3->ival;$$->vType=1;}
					else if($1->vType==2 && $3->vType==3 ){$$->dval=$1->dval==$3->cval;$$->vType=2;}
					else if($1->vType==3 && $3->vType==2 ){$$->dval=$1->cval==$3->dval;$$->vType=2;}
					
				}
				
				$$->code+="mov "+string(temp) +", 0\n";
				$$->code+="jmp "+string(label2) +"\n";
				$$->code+=string(label1)+":\nmov "+string(temp)+", 1\n";
				$$->code+=string(label2)+":\n";
				$$->setName(temp);
				//cout<<$$->code;
			
			
			//hashTable->printTable(output);
				}


		;
				
simple_expression : term 
			 {fprintf(output,"%s","simple_expression : term \n\n");//hashTable->printTable(output);
			//fprintf("%%%%s",$$->code);
			//fout<<"{"<<$1->code<<"}"<<endl;
			//fout<<"1111{"<<$$->code<<"}"<<endl;
			$$=$1;
			//cout << endl << "*************" << $$->getName() << endl;
}
		  | simple_expression ADDOP term 
			 {fprintf(output,"%s","simple_expression :  simple_expression ADDOP term\n\n");    
			SymbolInfo *s=new SymbolInfo($1);$$=s;
			
			char *temp=newTemp();
			int flag=0;
			if(!strcmp($3->getName(),"0")) {flag=1;}
			else if(!strcmp($1->getName(),"0")) {flag=2;}
			else
			{
			$$->code =$1->code+$3->code;
			$$->code += "mov ax, "+ string($1->getName())+"\n";
			
			
			$$->setName(temp);
			}
			
			if(!strcmp($2->getName(),"+")) 
				{
				if(flag==0){
					$$->code += "add ax,"+ string($3->getName())+"\n";
					$$->code += "mov "+ string(temp) + ", ax\n";}
					if($1->vType==1 &&$3->vType==1){$$->ival=$1->ival+$3->ival;$$->vType=1;}
					else if($1->vType==2&&$3->vType==2){$$->dval=$1->dval+$3->dval;$$->vType=2;}
					else if($1->vType==3&&$3->vType==3){$$->cval=$1->cval+$3->cval;$$->vType=3;}
					else if($1->vType==1 && $3->vType==2 ){$$->dval=$1->ival+$3->dval;$$->vType=2;}
					else if($1->vType==2 && $3->vType==1 ){$$->dval=$1->dval+$3->ival;$$->vType=2;}
					else if($1->vType==1 && $3->vType==3 ){$$->ival=$1->ival+$3->cval;$$->vType=1;}
					else if($1->vType==3 && $3->vType==1 ){$$->ival=$1->cval+$3->ival;$$->vType=1;}
					else if($1->vType==2 && $3->vType==3 ){$$->dval=$1->dval+$3->cval;$$->vType=2;}
					else if($1->vType==3 && $3->vType==2 ){$$->dval=$1->cval+$3->dval;$$->vType=2;}
					
				}

			   else if(!strcmp($2->getName(),"-")) 
				{
				if(flag==0){
					$$->code += "sub ax, string($3->getName())\n";
					$$->code += "mov "+ string(temp) + ", ax\n";}
					if($1->vType==1&&$3->vType==1){$$->ival=$1->ival-$3->ival;$$->vType=1;}
					else if($1->vType==2&&$3->vType==2){$$->dval=$1->dval-$3->dval;$$->vType=2;}
					else if($1->vType==3&&$3->vType==3){$$->cval=$1->cval-$3->cval;$$->vType=3;}
					else if($1->vType==1 && $3->vType==2 ){$$->dval=$1->ival-$3->dval;$$->vType=2;}
					else if($1->vType==2 && $3->vType==1 ){$$->dval=$1->dval-$3->ival;$$->vType=2;}
					else if($1->vType==1 && $3->vType==3 ){$$->ival=$1->ival-$3->cval;$$->vType=1;}
					else if($1->vType==3 && $3->vType==1 ){$$->ival=$1->cval-$3->ival;$$->vType=1;}
					else if($1->vType==2 && $3->vType==3 ){$$->dval=$1->dval-$3->cval;$$->vType=2;}
					else if($1->vType==3 && $3->vType==2 ){$$->dval=$1->cval-$3->dval;$$->vType=2;}
					
				}
				
				if(flag==1) $$=$1;
	else if(flag==2) $$=$3;
				
//	hashTable->printTable(output);		
	}
	
		  ;



					
term :	unary_expression {fprintf(output,"%s","term :	unary_expression\n\n");//hashTable->printTable(output);
}

     |  term MULOP unary_expression 
			{fprintf(output,"%s","term:   term MULOP unary_expression\n\n");
			$$=new SymbolInfo($1);
			
			//cout << endl <<"term:   term MULOP unary_expression\n\n"<< $1->getName() << "     " << $3->getName() << endl;
			char *temp=newTemp();
			int flag=0;
			if(!strcmp($3->getName(),"1")&&!strcmp($2->getName(),"*")) {flag=1;}
			else if(!strcmp($1->getName(),"1")) {flag=2;}
			else
			{
			$$->code =$1->code+$3->code;
			$$->code += "mov ax, "+ string($1->getName())+"\n";
			//printf("aa%s\n",$1->getName());
			$$->code += "mov bx, "+ string($3->getName()) +"\n";
			
			$$->setName(temp);		}	
							
						
						
									
			if(!strcmp($2->getName(),"*")) 
				{
					if(flag==0){
					$$->code += "mul bx\n";
					$$->code += "mov "+ string(temp) + ", ax\n";}
					
					if($1->vType==1 &&$3->vType==1){int i=$1->ival;$$->ival=i*$3->ival;
					$$->vType=1;}
					else if($1->vType==2 &&$3->vType==2){$$->dval=$1->dval*$3->dval;$$->vType=2;}
					else if($1->vType==3 && $3->vType==3){$$->cval=$1->cval*$3->cval;$$->vType=3;}
					else if($1->vType==1 && $3->vType==2 ){$$->dval=$1->ival*$3->dval;$$->vType=2;}
					else if($1->vType==2 && $3->vType==1 ){$$->dval=$1->dval*$3->ival;$$->vType=2;}
					else if($1->vType==1 && $3->vType==3 ){$$->ival=$1->ival*$3->cval;$$->vType=1;}
					else if($1->vType==3 && $3->vType==1 ){$$->ival=$1->cval*$3->ival;$$->vType=1;}
					else if($1->vType==2 && $3->vType==3 ){$$->dval=$1->dval*$3->cval;$$->vType=2;}
					else if($1->vType==3 && $3->vType==2 ){$$->dval=$1->cval*$3->dval;$$->vType=2;}
					
				}
		
			else if(!strcmp($2->getName(),"/")) 
				{
				if(flag==0){
					$$->code+="xor dx,dx\n";
					$$->code += "div bx\n";
					$$->code += "mov "+ string(temp) + ", ax\n";}
					
					if($1->vType==1 && $3->vType==1){$$->ival=$1->ival/$3->ival;$$->vType=1;}
					else if($1->vType==2&&$3->vType==2){$$->dval=$1->dval*$3->dval;$$->vType=2;}
					else if($1->vType==3&&$3->vType==3){$$->cval=$1->cval/$3->cval;$$->vType=3;}
					else if($1->vType==1 && $3->vType==2 ){$$->dval=$1->ival/$3->dval;$$->vType=2;}
					else if($1->vType==2 && $3->vType==1 ){$$->dval=$1->dval/$3->ival;$$->vType=2;}
					else if($1->vType==1 && $3->vType==3 ){$$->ival=$1->ival/$3->cval;$$->vType=1;}
					else if($1->vType==3 && $3->vType==1 ){$$->ival=$1->cval/$3->ival;$$->vType=1;}
					else if($1->vType==2 && $3->vType==3 ){$$->dval=$1->dval/$3->cval;$$->vType=2;}
					else if($1->vType==3 && $3->vType==2 ){$$->dval=$1->cval/$3->dval;$$->vType=2;}
					
				}

			else if(!strcmp($2->getName(),"%")) 
				{
				
				if(flag==0){
					$$->code+="xor dx,dx\n";
					$$->code += "div bx\n";
					$$->code += "mov "+ string(temp) + ", dx\n";}
					if($1->vType==1&&$3->vType==1){$$->ival=$1->ival%$3->ival;$$->vType=1;}
					else if($1->vType==1 && $3->vType==3 ){$$->ival=$1->ival%$3->cval;$$->vType=1;$$->vType=1;}
					else if($1->vType==3 && $3->vType==1 ){$$->ival=$1->cval*$3->ival;$$->vType=1;$$->vType=1;}
					else {	fprintf(output,"%s %d %s\n\n","Error at line ",lCount," : Integer operand on modulus operator ");errCount++;
						}
						}
				
					//fout<<$$->code;
						if(flag==1) $$=$1;
	if(flag==1) $$=$1;
	else if(flag==2) $$=$3;				}

//hashTable->printTable(output);

     ;




unary_expression : ADDOP unary_expression   
			{fprintf(output,"%s","unary_expression : ADDOP unary_expression\n\n");
				SymbolInfo *s=new SymbolInfo($2); 
				//$$=s; $$->vType=$2->vType;
				if(!strcmp($1->getName(),"-")) {
					if($2->vType==1) $$->ival=-($2->ival);
					else if($2->vType==2) $$->dval=-($2->dval);
					else if($2->vType==3) $$->cval=-($2->cval);
					char *temp=newTemp();
					
					$$->code="mov ax, " + string($2->getName()) + "\n";
					$$->code+="neg ax\n";
					$$->code+="mov "+string(temp)+", ax\n";
					
					}
				else if(!strcmp($1->getName(),"+")) {
					if($2->vType==1) $$->ival=($2->ival);
					else if($2->vType==2) $$->dval=($2->dval);
					else if($2->vType==3) $$->cval=($2->cval);}
//hashTable->printTable(output);
			}

		 | NOT unary_expression  
			{fprintf(output,"%s","unary_expression : NOT unary_expression\n\n");
				//$$=$1;
				SymbolInfo *s=new SymbolInfo($2);
			
				 $$=s; 
				// $$->vType=$2->vType;
				
				char *temp=newTemp();
				$$->code="mov ax, " + string($2->getName()) + "\n";
				$$->code+="not ax\n";
				$$->code+="mov "+string(temp)+", ax\n";
			//	fout<<$$->code;
				if($2->vType==1) $$->ival=!($2->ival);
				else if($2->vType==2) $$->dval=!($2->dval);
				else if($2->vType==3) $$->cval=!($2->cval);//hashTable->printTable(output);
				}

		 | factor 
			 {fprintf(output,"%s","unary_expression : factor\n\n");//hashTable->printTable(output);
}
		 ;



	


factor	: variable  {fprintf(output,"%s","factor	: variable\n\n");hashTable->printTable(output);


SymbolInfo* s=hashTable->LookUpTo($1->getName());
	
		if(s->arrSize>-1)
		{
			char *temp= newTemp();
				$$->code+= "mov " + string(temp) + ", [di]\n";
				$$->setName(temp);
		}
			
}

	| LPAREN expression RPAREN  {fprintf(output,"%s","factor	: variable\n\n");
	//$$=$2;
SymbolInfo *s=new SymbolInfo($2); $$=s; $$->vType=$2->vType;//hashTable->printTable(output);
				if($2->vType==1) $$->ival=($2->ival);
				else if($2->vType==2) $$->dval=($2->dval);
				else if($2->vType==3) $$->cval=($2->cval);
}

	| CONST_INT 
		 {fprintf(output,"%s","factor	: CONST_INT\n"); fprintf(output,"%s\n\n",$1->getName());//hashTable->printTable(output);
}

	| CONST_FLOAT
		 {fprintf(output,"%s","factor	: CONST_FLOAT\n"); fprintf(output,"%s\n\n",$1->getName());//hashTable->printTable(output);
}

	| CONST_CHAR
		 {
		fprintf(output,"%s","factor	: CONST_CHAR\n");
		if(strlen($1->getName())==3) {fprintf(output,"%c\n\n",*($1->getName()+1));}
		else if(strlen($1->getName())==4) {fprintf(output,"%c%c\n\n",*($1->getName()+1),*($1->getName()+2));}//hashTable->printTable(output);
		
}
	| variable INCOP  {fprintf(output,"%s","factor	: variable INCOP\n\n");
	$$=new SymbolInfo($1);
		$$->code += "inc " + string($1->getName()) + "\n";
		if($1->vType==2)	  {$1->dval=$1->dval+1;}		
			else if($1->vType==1)  {$1->ival=$1->ival+1;}	
			else if($1->vType==3)  {$1->cval=$1->cval+1;
						int i=(int)$1->cval;
						if(i==0||i==7||i==8||i==9||i==10||i==11||i==12||i==13||i==34||i==92) $1->charType=2;
						else $1->charType=1;}	


	
		//	$$=s;//hashTable->printTable(output);
		}
						
			

	| variable DECOP {
		$$=new SymbolInfo($1);
		fprintf(output,"%s","factor	: variable DECOP\n\n");
		//SymbolInfo* s=hashTable->LookUpTo($1->getName());
		$$->code += "dec " + string($1->getName()) + "\n";
	
			if($1->vType==2)	  {$1->dval=$1->dval-1;}		
			else if($1->vType==1)  {$1->ival=$1->ival-1;}	
			else if($1->vType==3)  {$1->cval=$1->cval-1;
						int i=(int)$1->cval;
						if(i==0||i==7||i==8||i==9||i==10||i==11||i==12||i==13||i==34||i==92) $1->charType=2;
						else $1->charType=1;}	

			//hashTable->printTable(output);
}
	;


%%

main( int argc, char *argv[] )
{
extern FILE *yyin;

if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}

yyin = fin;
//yydebug = 1;
//errors = 0;

fout.open("1305037_code.asm");
yyparse ();
hashTable->printTable(output);
fprintf(output,"%s""%d""%s","Total Lines:",lCount,"\n\n");
fprintf(output,"%s""%d""%s","Total Errors:",errCount,"\n\n");
return 0;
}
