%{
#include "fmm.tab.h"
#include <string.h>
#include <stdlib.h>

char* stripQuotes(char* s){
  int len = strlen(s);
  char* r = malloc(len-1);
  strncpy(r, s+1, len-2);
  r[len-2]='\0';
  return r;
}
%}

%%
"//".*                 ;
"/*"([^*]|\*+[^*/])*\*+"/"  ;

"load"        { return IMPORT; }
"create"      { return STATE; }
"task"        { return DEF; }
"loop"        { return FOR; }
"in"          { return IN; }
"check"       { return IF; }
"otherwise"   { return ELSE; }
"give"        { return RETURN; }
"start"       { return RUN; }
"show:"       { return RENDER; }

"yes"         { return V_TRUE; }
"no"          { return V_FALSE; }
"empty"       { return V_NULL; }

"=="          { return EQEQ; }
"!="          { return NEQ; }
">="          { return GTE; }
"<="          { return LTE; }
"and"         { return AND; }
"or"          { return OR; }
"::"          { return COLONCOLON; }
".."          { return DOTDOT; }
"=>"          { return ARROW; }

"="           { return EQ; }
"+"           { return PLUS; }
"-"           { return MINUS; }
"*"           { return STAR; }
"/"           { return SLASH; }
"%"           { return MOD; }
"<"           { return LT; }
">"           { return GT; }
"not"         { return NOT; }
"{"           { return LBRACE; }
"}"           { return RBRACE; }
"("           { return LPAREN; }
")"           { return RPAREN; }
"["           { return LBRACK; }
"]"           { return RBRACK; }
","           { return COMMA; }
"."           { return DOT; }
":"           { return COLON; }

\"[^\"\n]*\"    { yylval.str = stripQuotes(yytext); return STRING; }
\'[^\'\n]*\'    { yylval.str = stripQuotes(yytext); return STRING; }
[0-9]+\.[0-9]+  { yylval.str = strdup(yytext); return FLOAT; }
[0-9]+        { yylval.num = atoi(yytext); return INT; }

[a-zA-Z_][a-zA-Z0-9_]* {
                yylval.str = strdup(yytext);
                const char* tags[] = {"column","row","text","btn","input","image","list","card","container",NULL};
                for(int i=0; tags[i]; i++) if(strcmp(yytext,tags[i])==0) return TAG;
                return ID;
              }

\{[ \t]*[a-zA-Z_][a-zA-Z0-9_]*[ \t]*\} {
                yylval.str = strdup(yytext);
                return BRACED_ID;
              }

[ \t\n\r]+    ;
.             { return yytext[0]; }
%%
int yywrap(){ return 1; }

