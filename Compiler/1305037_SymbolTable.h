#ifndef SymbolTable_H
#define SymbolTable_H

#include<stdio.h>
#include<cstdio>
#include<cstdlib>
#include<cstring>
#include "1305037_SymbolInfo.h"
using namespace std;
extern FILE* output;


class SymbolTable
{

    private:
        int tableSize;
        SymbolInfo **hashTable;

    public:
	
        SymbolTable(int tableSize=30) {
            this->hashTable = new SymbolInfo*[tableSize];

            for(int i=0;i<tableSize;i++)
            {
                hashTable[i]=NULL;
            }
            this->tableSize=tableSize;
	    //log_out.open("1305037_output.txt");
        }



        ~SymbolTable()
	{
        for(int i=0;i<tableSize;i++)
        {
            if(hashTable[i]!=NULL)
            {
                SymbolInfo *prev=NULL,*item=hashTable[i];
                while(item)
                {
                    prev=item;
                    item=item->getNext();
                    delete prev;
                }



            }
        }

        delete[] hashTable;
}
        int hashFunction(char* key)
		{
		    int sum=0;
		    for(int i=0;i<strlen(key);i++) sum+=(int)key[i];
		    //cout<<sum%tableSize<<endl;
		    return sum%tableSize;
		}

        int* Insert(SymbolInfo *s){

        int index=hashFunction(s->getName()),count=0 ;
        static int arr[2];

        int *a=LookUp(s->getName());

	
        if(a[0]!=-1)  {arr[0]=-1;}
        else 
            {

                 arr[0]=index;


        if(hashTable[index]==NULL)
        {

            hashTable[index]=s;

             arr[1]=0;
	
}
        else
        {
            //cout<<"chain ";
            SymbolInfo *item=hashTable[index],*prev;
		if(hashTable[index]) 
			    while(item)
			    {
				prev=item;
				item=item->getNext();
				count++;
			    }
			    arr[1]=count;

			    item=s;
			     //cout<<"kk";
			    item->setNext(NULL);
			    prev->setNext(item);
			}
			    }
		//print();
	
			return arr;
		}


int* Insert(char* name,char* type){

        int index=hashFunction(name),count=0 ;
        static int arr[2];

        int *a=LookUp(name);

	
        if(a[0]!=-1)  {arr[0]=-1;}
        else
            {

                 arr[0]=index;


        if(hashTable[index]==NULL)
        {

            hashTable[index]=new SymbolInfo(name,type);

             arr[1]=0;
	
}
        else
        {
            //cout<<"chain ";
            SymbolInfo *item=hashTable[index],*prev;
		if(hashTable[index]) 
			    while(item)
			    {
				prev=item;
				item=item->getNext();
				count++;
			    }
			    arr[1]=count;

			    item=new SymbolInfo(name,type);
			     //cout<<"kk";
			    item->setNext(NULL);
			    prev->setNext(item);
			}
			    }
		//print();
	
			return arr;
		}

	//int* Insert(char* name,char* type,ofstream &output );


     SymbolInfo* LookUpTo(char* name){
		    int index=hashFunction(name);

		    if(hashTable[index]!=NULL)
		
		    {
			SymbolInfo *item=hashTable[index];
		   

			while(item->getName()!=name && item->getNext()!=NULL)
			{
			    item=item->getNext();
			}

			if(!strcmp(item->getName(),name))
			{

			    return item;
			}
			

		    }

		    return  NULL;
		}

     int* LookUp(char* name){
		    int index=hashFunction(name);
		    //cout<<index<<endl;
		    static int arr[2];
		    int count=0;



		    if(hashTable[index]==NULL)
			{
			    arr[0]=-1; arr[1]=-1;

			}


		    else
		    {
		       // cout<<"ss";
			SymbolInfo *item=hashTable[index];
		       // cout<<item->getName();

			while(item->getName()!=name && item->getNext()!=NULL)
			{
			    item=item->getNext();
			    count++;

			}

			if(!strcmp(item->getName(),name))
			{

			    arr[0]=index;
			    arr[1]=count;

			}
			else
			{

			    arr[0]=-1; arr[1]=-1;

			}


		    }

		    return arr;
		}

    int* Delete(char* key){
		    int *a=LookUp(key);
		    static int arr[2];


		    arr[0]=*a;
		    arr[1]=*(a+1);

		    if(*a==-1) return arr;
		    SymbolInfo *item=hashTable[*a],*prev=item;



		    for (int i=0;i<*(a+1);i++) {prev=item; item=item->getNext();}

		    if(arr[1]==0) { hashTable[arr[0]]=item->getNext(); delete item; }
		    else
		    {

			prev->setNext(item->getNext());
			delete item;


		    }

		    return arr;
		}



        void print(){

        for(int i=0;i<tableSize;i++)
        {

           // cout<< i <<" " <<"->"<< " ";

            SymbolInfo *item=hashTable[i];
printf("%d-> ",i);
            while(item)
            {
printf("<%s ,%s>  ",item->getName(),item->getType());
             //   cout<<"<"<<item->getName()<<" "<<item->getType()<<"> ";
                item=item->getNext();

            }
            //cout<<endl;
printf("\n\n");

        }
}
	void printTable(FILE *output){int flag=0;

        for(int i=0;i<tableSize;i++)
        {
           

            SymbolInfo *item=hashTable[i];
	if(item) fprintf(output,"%d ->   ",i);

            while(item)
            {
		flag=1;
	
		
		fprintf(output,"<%s,%s,",item->getName(),item->getType());
		if(item->arrSize<=0) {
		if(item->vType==1) 	fprintf(output,"%d>",item->ival);
		else if(item->vType==2) fprintf(output,"%f>",item->dval);
		else if(item->vType==3 && item->charType==1) fprintf(output,"%c>",item->cval);
		else if(item->vType==3 && item->charType==2) fprintf(output,"\\%c>",item->cval);}
		else 
		{
			if(item->vType==1) 
			{
				fprintf(output,"{");
				for(int i=0;i<item->arrSize;i++)
				{
				int j=item->siArr[i]->ival;
					fprintf(output,"%d,",j);
				}
				fprintf(output,"}>");
			}	
			else if(item->vType==2) 
			{
				fprintf(output,"{");
				for(int i=0;i<item->arrSize;i++)
				{
				float j=item->siArr[i]->dval;
					fprintf(output,"%f,",j);
				}
				fprintf(output,"}>");
			}
			
			else if(item->vType==3) 
			{
				fprintf(output,"{");
				for(int i=0;i<item->arrSize;i++)
				{
				char j=item->siArr[i]->cval;
					fprintf(output,"%c,",j);
				}
				fprintf(output,"}>");
			}
		//else if(item->vType==3 && item->charType==1) fprintf(output,"%c>",item->cval);
		//else if(item->vType==3 && item->charType==2) fprintf(output,"\\%c>",item->cval);
		}

		//output<< i <<" " <<"->"<< " ";
                //output<<"<"<<item->getName()<<" "<<item->getType()<<"> \n";
                item=item->getNext();

            }
	if(flag) fprintf(output,"\n");
	flag=0;
          
		

        }

fprintf(output,"\n");
}





};


#endif
