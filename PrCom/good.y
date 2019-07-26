%{
   #include <stdio.h>
   #include <stdlib.h>    
   #include "function.h" 
   int lignes=0;
   int yylex();  
   void yyerror(char*msg);
   int count = 0 ; 
   char tmp1[100];
   char tmp2[100];
   char operateur[100];
   int cond1 = 0 ;
   int cond2 = 0;
   int SauvSpace = 0;
   int SauveElse =  0 ;
   int init = 0 ;
%}
%union {
char *str; 
int ent;
float real;  	
}

%token FIN 
%token IF  
%token space 
%token jump 
%token tiret8  
%token DeuxPoints
%token Equal  
%token Apostrophe 
%token <str>variable
%token PrO 
%token PrF 
%token Int
%token Float
%token Char
%token <str>Entier
%token Real
%token Vargule
%token Character
%token Plus
%token Minus
%token PointExclamation
%token Sup
%token Inf
%token ELSE
%token ELIF
%token Div
%token Mul
%token OR
%token AND
%token Commenter
%token tab
%token ANDC
%token ORC


%start START
%%//automate
START : START_WITH_SPACES START |  { remplire_quadr("" ,"", "" , ""); 
                                                   SauverElif(-10, qc-1);
                                                    SauverQaudr(-10,qc-1);afficher_qdr();propaDeCopie(quad,qc);afficher_qdr();assembler(quad);}

START_WITH_SPACES : SPACESS CODE  jump { if(SauveElse==1){
                                         // SauverElifElse(count,qc);                                      
                                          // SauverElif (count, qc);

                                          SauverQaudr(count,qc); SauveElse=0;}                                         
                                    
                                         else{
                                          SauverElif (count, qc-1);

                                          SauverQaudr(count,qc-1);}                                         
                                    
                                         if(SauvSpace==1){
                                          SauvSpace =0; 
                                          AjouterSAUV(count, qc-1);}                                          
                                          count=0 ;  }JUMPS 

CODE :  AFFECTATION {AjouterTableEspace( "inst" ,count,0);  } | CONDITION_IF_OR_ELIF   | Commenter  | CONDITION_ELSE | DICLARATION {AjouterTableEspace( "inst" ,count,0);}

CONDITION_IF_OR_ELIF : IF_OR_ELIF CONDITION  SPACES      

CONDITION : SPACES PrO SPACES EXPRITION_LOGIQUE PrF  SPACES  DeuxPoints  
   
CONDITION_ELSE : ELSE {AjouterTableEspace( "else" ,count,0);  remplire_quadr("BR" ,"", "" , "");SauveElse=1; SauvSpace=1;}  SPACES DeuxPoints SPACES 

EXPRITION_LOGIQUE    : EXPRITION_LOGIQUE_B  EXPRITION { cond2=TriterInstruction(1); 
                       strcpy(operateur,OPERATEUR(operateur));  
                       SauvSpace=1;                     
                       if(cond2==1){
                       strcpy(tmp2,quad[qc-1].op1); 
                       qc--;}else{
                        strcpy(tmp2,quad[qc-1].res);

                       }
                       cond1=0;
                       cond2=0;                         
                       remplire_quadr(operateur,tmp1 ,tmp2 ,""); }
  
EXPRITION_LOGIQUE_B : EXPRITION_LOGIQUE_A OPERATEUR_COMPARAISON SPACES 

EXPRITION_LOGIQUE_A  : EXPRITION { cond1 =TriterInstruction(1);if(cond1==1){strcpy(tmp1,quad[qc-1].op1);
                                                                            qc--;}else{
                                                                            strcpy(tmp1,quad[qc-1].res);}  }  
       
AFFECTATION   : variable   SPACES Equal SPACES EXPRITION  {TriterInstruction(0); ajour_quad(qc-1, 3, $1) ;}  
 
EXPRITION:VALEUR_OR_VARIABLE SPACES OPIRATEUR SPACES EXPRITION|VALEUR_OR_VARIABLE SPACES|Pro_EXPRITION_PrF_B  PrF  { empiler(")");} | PrO_EXPRITION_PrF_OPIRATEUR_SPACES_EXPRITION_D  OPIRATEUR SPACES EXPRITION

PrO_EXPRITION_PrF_OPIRATEUR_SPACES_EXPRITION_D :  Pro_EXPRITION_PrF_B PrF  { empiler(")");}

Pro_EXPRITION_PrF_B : Pro_EXPRITION_PrF_A EXPRITION

Pro_EXPRITION_PrF_A : PrO   { empiler("(");}

IF_OR_ELIF : IF {AjouterTableEspace( "if" ,count,0); }   | ELIF {AjouterTableEspace( "elif" ,count,0);remplire_quadr("BR" ,"", "" , "elif");
                                                                            AjouterSAUV(count, qc-1);                 
                                                                                               }
 
DICLARATION : TYPE DECLARER 

DECLARER : SPACES_OR_TAB SPACES variable SPACES INISI {if(init ==1){TriterInstruction(0); ajour_quad(qc-1, 3, $3) ; init=0;}}  
                                                      MOR_DECLARATION 
 
MOR_DECLARATION : Vargule SPACES variable SPACES INISI {
                                                       if(init ==1){ TriterInstruction(0); ajour_quad(qc-1, 3, $3) ;
                                                            init= 0;
                                                         }
                                                       }  
                                                     MOR_DECLARATION | 

INISI :  INI { init = 1 ;} | 

INI : Equal SPACES EXPRITION 

//Les Type Exist
TYPE : Int 

VALEUR_OR_VARIABLE : VALEUR | variable {empiler($1);}
 
VALEUR : Entier {empiler($1);}

OPERATEUR_COMPARAISON : PointExclamation Equal {strcpy(operateur,"!=");} | 
Equal Equal {strcpy(operateur,"==");}   | Inf  {strcpy(operateur,"<");}  | 
Sup {strcpy(operateur,">");} | Sup Equal {strcpy(operateur,"<=");} | Inf Equal {strcpy(operateur,">=");} 

OPIRATEUR : Plus { empiler("+");} | Minus { empiler("-");} | Div { empiler("/");} | Mul { empiler("*");}

SPACES_OR_TAB : space | tab

SPACESS : space SPACESS {count++ ;}  | tab SPACESS { count= count+8;  } |

SPACES : space SPACES   | tab SPACES  |

JUMPS : jump JUMPS |
            

%%

void yyerror(char* s){

	printf ("Error line :%d , %s\n",lignes,s);

}

int yywrap(){
    return 1;
}


int main(void){ return yyparse();}
