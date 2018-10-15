#ifndef SYMBOLINFO_H
#define SYMBOLINFO_H
#define IVAL 1
#define DVAL 2
#define CVAL 3

#include<string.h>
#include<string>
#include <bits/stdc++.h>
//#include<cstring>
using namespace std;

/*class Value 
{
     public:
	int ival;
	double dval;
	char cval;
	char* sval;
	int *iarrval;
	double *darrval;
	
   
	Value(int ival) {this->ival=ival;}
	Value(double dval) {this->dval=dval;}
	Value(char cval) {this->cval=cval;}
	Value(char* sval) {this->sval=sval;}
	Value(int *iarrval,int n) {this->iarrval=new int[n];}
	Value(double *darrval,int n) {this->darrval=new double[n];}
	
	
};*/


class SymbolInfo
{
    private:
        char* name;
        char* type;

        SymbolInfo *next;
	


    public: 
    char *q;
    	string code;
	int vType;
	int arrSize;
	
	int ival;
	double dval;
	char cval;
	int charType;
	

	SymbolInfo **siArr;
	
SymbolInfo()  {

                this->name=0;
                this->type=0;
                this->next=0;
                this->code="a";
                q="1";
                printf("b%s",this->q);
		this->arrSize=-1;
		

}
SymbolInfo(char* name,char* type)  {
                this->name=name;
                this->type=type;
                this->next=0;
                 this->code="";
		this->arrSize=-1;
		

}

  SymbolInfo(const SymbolInfo *sym){
         	this->name=NULL;
            if(sym->name!=NULL){
                this->name=new char[strlen(sym->name)+1];
                strcpy(this->name,sym->name);

            }

			this->type=NULL;
			if(sym->type!=NULL){
                this->type= new char[strlen(sym->type)+1];
                strcpy(this->type,sym->type);
            }
			
            this->code=sym->code;
            this->vType=sym->vType;
            this->next=NULL;
			//this->arrayLength=sym->arrayLength;
            this->arrSize=sym->arrSize;
            ///this->arrIndexHolder=sym->arrIndexHolder;
        }

void iniArr(char *name,char *type)
{
	siArr=new SymbolInfo*[arrSize];
	for(int i=0;i<arrSize;i++) {siArr[i]=new SymbolInfo(name,type);
	 
	 siArr[i]->name=name;
	 siArr[i]->type=type;
					siArr[i]->vType=vType;
					siArr[i]->ival=0;
					siArr[i]->cval='\0';
					siArr[i]->dval=0.0;
					siArr[i]->code="";}
}


SymbolInfo* getNext(){return this->next;}
void setNext(SymbolInfo *item){this->next=item;}
void setVType(int i) {vType=i;}
void setArrSize(int i) {arrSize=i;}
void setIVal(int i) {ival=i;}
void setCVal(char c) {cval=c;}
void setDVal(double d) {dval=d;}
char* getName() {return this->name;}
void setName(char* name) {this->name=name;}
char* getType()  {return this->type;}




};



#endif
