%option noyywrap

%{ 
#include<stdio.h>
#include<cstdio>
#include<cstdlib>
#include<cstring>
#include<string>

#include "1305037_SymbolTable.h"
#include "1305037_SymbolInfo.h"
#include "y.tab.h"

using namespace std;
void yyerror(char*);

int lCount=0,errCount=0;
int *arr,temp; 
char* str;


%}
WHITESPACE[ \t\v\f\r]+
NEWLINE [\n]

LETTER [_a-zA-Z]
CHAR [ -~]{-}[']
CHARS {CHAR}+

CHARACTER '({CHAR})'
SPECIAL_CHAR '\\[tvar"afb0n]'|'\\'
ILL_CHAR ('({CHARS}|['])*')
UNRE_CHAR ('{CHAR}*[^'\n]?)


STRING\"(([\\][\n])|[^\"\n])*\"
UNFINISHED_STRING \"(([\\][\n])|[^\"\n])*$


SINGLELINE_COMMENT "//"{CHARS}*$ 


MULTILINE_COMMENT_START "/*"
MULTILINE_COMMENT_END "*/"
ANYTHING_EXCEPT_STAR [^*]
STAR_NOT_FOLLOWED_BY_SLASH "*"[^/]


COMMENT ({MULTILINE_COMMENT_START}({ANYTHING_EXCEPT_STAR}|{STAR_NOT_FOLLOWED_BY_SLASH})*{MULTILINE_COMMENT_END})
UNFINISHED_COMMENT ({MULTILINE_COMMENT_START}[^"*/"]*)

DIGIT [0-9]
DIGITS {DIGIT}+
DECP (\.)*


INTEGER {DIGITS}
FLOATING_POINT {DIGITS}*(\.{DIGITS})(E[+-]?{DIGITS})?

TOO_DEC {DIGITS}*((\.)+{DIGITS}+)+(E{DECP}[+-]?{DECP}{DIGITS})?{DECP}{DIGITS}*
ILL_NUM (({DIGITS}|{FLOATING_POINT})[E]*{FLOATING_POINT}*{DIGITS}*)|{DIGITS}\.

IDENTIFIER {LETTER}({LETTER}|{DIGIT})*
NOT_ID {DIGIT}({LETTER}|{DIGIT})*
%%


{WHITESPACE}    {}
{NEWLINE}  	{lCount++;}

{INTEGER}     		 {
				SymbolInfo *s= new  SymbolInfo(strdup(yytext), (char *)"CONST_INT");
				s->vType=1;s->ival=atoi((char*)(strdup(yytext)));
				yylval = (YYSTYPE)s;
				return CONST_INT;
			}
{FLOATING_POINT} 	{	
				SymbolInfo *s= new  SymbolInfo(strdup(yytext), (char *)"CONST_FLOAT");
				s->vType=2; s->dval=atof((char*)(strdup(yytext)));
				yylval = (YYSTYPE)s;
				return CONST_FLOAT; 
			}
 
{TOO_DEC} 	{errCount++;}
{ILL_NUM} 	{errCount++; }

{CHARACTER}	{	
				SymbolInfo *s= new  SymbolInfo(strdup(yytext), (char *)"CONST_CHAR");
				s->vType=3; s->cval=*(strdup(yytext)+1);s->charType=1; //???
				yylval = (YYSTYPE)s;
				return CONST_CHAR; 
			}
{SPECIAL_CHAR}  {
	SymbolInfo *s= new  SymbolInfo(strdup(yytext), (char *)"CONST_CHAR");
				yylval = (YYSTYPE)s;
				s->charType=2;
				s->vType=3; s->cval=*(strdup(yytext)+2);
				return CONST_CHAR; }

{ILL_CHAR} 	{errCount++; }
{UNRE_CHAR}     {errCount++; }


{SINGLELINE_COMMENT}	{}
{COMMENT}	 {}
{UNFINISHED_COMMENT} {errCount++; }


{STRING}	 { return STRING;}
{UNFINISHED_STRING} { errCount++;}

"if" 	   { return IF;}
"for" 	   { return FOR;}
"do"	   { return DO;}
"int" 	   { return INT;}
"float"    { return FLOAT;}
"switch"   { return SWITCH;}
"default"  { return DEFAULT;}
"else"     { return ELSE;}
"while"    { return WHILE;}
"break"    { return BREAK;}
"char"     { return CHAR;}
"double"   { return DOUBLE;}
"return"   { return RETURN;}
"case"     { return CASE;}
"continue" { return CONTINUE;}
"main"	   { return MAIN;}
"println"  { return PRINTLN;}


("++")      	 {return INCOP;}
("--")      	 {return DECOP;}

("+"|"-")       { 
			SymbolInfo *s= new  SymbolInfo(strdup(yytext), (char *)"ADDOP");
			yylval = (YYSTYPE)s;
			return ADDOP;

		}

("*"|"/"|"%") 	{ 
			SymbolInfo *s= new  SymbolInfo(strdup(yytext), (char *)"MULOP");
			yylval = (YYSTYPE)s;
			return MULOP;

		} 

("<="|">="|"==") { 
			SymbolInfo *s= new  SymbolInfo(strdup(yytext), (char *)"RELOP");
			yylval = (YYSTYPE)s;
			return RELOP;

		}


"!"              {return NOT;}

("<"|">")	 { 
			SymbolInfo *s= new  SymbolInfo(strdup(yytext), (char *)"RELOP");
			yylval = (YYSTYPE)s;
			return RELOP;

		}


("=")		{ 
			SymbolInfo *s= new  SymbolInfo(strdup(yytext), (char *)"ASSIGNOP");
			yylval = (YYSTYPE)s;
			return ASSIGNOP;

		}

("&&"|"||")  { 
			SymbolInfo *s= new  SymbolInfo(strdup(yytext), (char *)"LOGICOP");
			yylval = (YYSTYPE)s;
			return LOGICOP;

		}

"(" 		 {return LPAREN;}
")" 		 {return RPAREN;}

"{" 		 {return LCURL;}
"}" 		 {return RCURL;}

"["		 {return LTHIRD;}
"]" 		 {return RTHIRD;}

(";") 		 {return SEMICOLON;}
(",")            {return COMMA;}


{IDENTIFIER} 	{	 
				
								
				SymbolInfo *s= new SymbolInfo(strdup(yytext), (char *)"ID");
				yylval = (YYSTYPE)s;
			
							
				return ID;
			}
{NOT_ID}         {errCount++; }


%%


