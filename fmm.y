%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

extern FILE* yyin;
int yylex();
void yyerror(const char *s){ fprintf(stderr, "❌ Error: %s\n", s); }

/* دوائر المشغل الفوري (الـ DOM الافتراضي والذاكرة) */
void execute_state(char* id, char* val) {
    printf("[ذاكرة المشغل]: تم حجز المتغير التفاعلي (%s) بالقيمة: %s\n", id, val);
}

void execute_render_tag(char* tag, char* attrs) {
    printf("[محرك الرسوميات الأصلي]: رسم عنصر واجهة -> Tag: %s | Attrs: %s\n", tag, attrs);
}

char* mapTag(char* t){
  if(strcmp(t,"column")==0) return "flex-direction-column";
  if(strcmp(t,"row")==0) return "flex-direction-row";
  if(strcmp(t,"btn")==0) return "button";
  return t;
}

char* concat(char* a, char* b){
  if(!a || strlen(a)==0) return b ? b : strdup("");
  if(!b || strlen(b)==0) return a;
  char* r = malloc(strlen(a)+strlen(b)+2);
  sprintf(r, "%s %s", a, b);
  return r;
}
%}

%union { char* str; int num; }

%token IMPORT STATE DEF FOR IN IF ELSE RETURN RUN RENDER
%token <str> ID TAG STRING FLOAT BRACED_ID
%token <num> INT
%token V_NULL V_TRUE V_FALSE
%token COLONCOLON DOTDOT ARROW EQEQ NEQ GTE LTE AND OR
%token EQ PLUS MINUS STAR SLASH MOD LT GT NOT LBRACE RBRACE LPAREN RPAREN LBRACK RBRACK COMMA DOT COLON

%type <str> value expr attr attr_list import_path func_params param_list jsx_content ui_element ui_element_list ui_root

%left OR
%left AND
%left EQEQ NEQ
%left LT GT LTE GTE
%left PLUS MINUS
%left STAR SLASH MOD
%right NOT

%%

start: {
    printf("🚀 بدء تشغيل محرك الويب المستقر FMM Runtime...\n\n");
  } statement_list {
    printf("\n🏁 تم إنهاء تنفيذ البرنامج بنجاح وبدون وسائط الخارجية.\n");
  };

statement_list: | statement_list statement ;

statement: import_stmt | state_stmt | def_stmt | for_stmt | if_stmt | return_stmt | run_stmt | render_block ;

import_stmt: IMPORT ID COLONCOLON ID { printf("[المشغل]: جلب الحزمة الرقمية %s من مكتبة %s\n", $2, $4); }
  | IMPORT ID import_path { printf("[المشغل]: جلب ملف %s من المسار %s\n", $2, $3); }
  | IMPORT ID { printf("[المشغل]: جلب المكتبة المدمجة الأصيلة: %s\n", $2); }
  ;

import_path: ID { $$ = $1; } | STRING { $$ = $1; } ;

state_stmt: STATE ID EQ expr {
    execute_state($2, $4);
};

def_stmt: DEF ID LPAREN func_params RPAREN LBRACE {
    printf("[ذاكرة المشغل]: تسجيل المهمة التفاعلية (task %s) مع المعاملات [%s]\n", $2, $4);
  } statement_list RBRACE
  | DEF ID LPAREN RPAREN LBRACE {
    printf("[ذاكرة المشغل]: تسجيل المهمة التفاعلية (task %s) بدون معاملات\n", $2);
  } statement_list RBRACE
  ;

func_params: { $$ = strdup(""); } | param_list { $$ = $1; } ;
param_list: ID { $$ = $1; }
  | param_list COMMA ID { 
    char* r = malloc(strlen($1)+strlen($3)+3); 
    sprintf(r, "%s, %s", $1, $3); 
    $$ = r; 
  }
  ;

if_stmt: IF LPAREN expr RPAREN LBRACE {
    printf("[فحص الشرط check]: إذا تحقق (%s) نفذ:\n", $3);
  } statement_list RBRACE 
  | IF LPAREN expr RPAREN LBRACE {
    printf("[فحص الشرط check]: إذا تحقق (%s) نفذ:\n", $3);
  } statement_list RBRACE ELSE LBRACE {
    printf("[مسار بديل otherwise]: في حال عدم تحقق الشرط:\n");
  } statement_list RBRACE
  ;

for_stmt: FOR ID IN INT DOTDOT INT LBRACE {
    printf("[التكرار loop]: العداد %s يتحرك من %d إلى %d\n", $2, $4, $6);
  } statement_list RBRACE
  | FOR ID IN ID LBRACE {
    printf("[التكرار loop]: فحص وتكرار المكون %s داخل الحزمة %s\n", $2, $4);
  } statement_list RBRACE
  ;

return_stmt: RETURN expr { printf("[المشغل]: إرجاع النتيجة الحسابية الفورية -> %s\n", $2); };

run_stmt: RUN ID LPAREN RPAREN { printf("[انطلاق start]: تنفيذ المهمة التفاعلية %s()\n", $2); }
  | RUN ID LPAREN param_list RPAREN { printf("[انطلاق start]: تنفيذ المهمة التفاعلية %s(%s)\n", $2, $4); }
  ;

render_block: RENDER {
    printf("\n🎨 [محرك الرسوميات]: تفعيل شاشة العرض (show:)...\n");
  } ui_root {
    printf("✨ [محرك الرسوميات]: تمت محاكاة وإسقاط الواجهات التفاعلية بنجاح داخل بيئة المتصفح الأصلي!\n");
  };

ui_root: ui_element { $$ = $1; } | ui_element_list { $$ = $1; } ;
ui_element_list: ui_element { $$ = $1; } | ui_element_list ui_element { $$ = concat($1, $2); } ;

ui_element: LT TAG attr_list SLASH GT {
    execute_render_tag(mapTag($2), $3);
    $$ = $2;
  }
  | LT TAG attr_list GT {
    execute_render_tag(mapTag($2), $3);
  } jsx_content LT SLASH TAG GT {
    $$ = $2;
  }
  ;

jsx_content: { $$ = strdup(""); }
  | jsx_content ui_element { $$ = concat($1, $2); }
  | jsx_content STRING { printf("   📝 [نص واجهة أصيل]: \"%s\"\n", $2); $$ = concat($1, $2); }
  | jsx_content BRACED_ID { printf("   🔗 [ربط متغير ديناميكي]: %s\n", $2); $$ = concat($1, $2); }
  ;

attr_list: { $$ = strdup(""); } | attr_list attr { $$ = concat($1, $2); } ;

attr: ID EQ STRING { char* tmp = malloc(strlen($1)+strlen($3)+10); sprintf(tmp, "%s=\"%s\"", $1, $3); $$ = tmp; }
  | ID EQ BRACED_ID { char* tmp = malloc(strlen($1)+strlen($3)+10); sprintf(tmp, "%s=%s", $1, $3); $$ = tmp; }
  | ID EQ ID { char* tmp = malloc(strlen($1)+strlen($3)+10); sprintf(tmp, "%s=%s", $1, $3); $$ = tmp; }
  ;

expr: expr PLUS expr { char* r=malloc(strlen($1)+strlen($3)+5); sprintf(r, "%s + %s", $1, $3); $$=r; }
  | expr MINUS expr { char* r=malloc(strlen($1)+strlen($3)+5); sprintf(r, "%s - %s", $1, $3); $$=r; }
  | expr STAR expr { char* r=malloc(strlen($1)+strlen($3)+5); sprintf(r, "%s * %s", $1, $3); $$=r; }
  | expr SLASH expr { char* r=malloc(strlen($1)+strlen($3)+5); sprintf(r, "%s / %s", $1, $3); $$=r; }
  | expr EQEQ expr { char* r=malloc(strlen($1)+strlen($3)+5); sprintf(r, "%s == %s", $1, $3); $$=r; }
  | expr NEQ expr { char* r=malloc(strlen($1)+strlen($3)+5); sprintf(r, "%s != %s", $1, $3); $$=r; }
  | expr LT expr { char* r=malloc(strlen($1)+strlen($3)+5); sprintf(r, "%s < %s", $1, $3); $$=r; }
  | expr GT expr { char* r=malloc(strlen($1)+strlen($3)+5); sprintf(r, "%s > %s", $1, $3); $$=r; }
  | LPAREN expr RPAREN { char* r=malloc(strlen($2)+3); sprintf(r, "(%s)", $2); $$=r; }
  | ID { $$=$1; }
  | INT { char* b=malloc(20); sprintf(b,"%d",$1); $$=b; }
  | FLOAT { $$=$1; }
  | STRING { $$=$1; }
  | V_NULL { $$=strdup("empty"); }
  | V_TRUE { $$=strdup("yes"); }
  | V_FALSE { $$=strdup("no"); }
  | ID LPAREN RPAREN { char* r=malloc(strlen($1)+5); sprintf(r, "%s()", $1); $$=r; }
  | ID LPAREN param_list RPAREN { char* r=malloc(strlen($1)+strlen($3)+5); sprintf(r, "%s(%s)", $1, $3); $$=r; }
  ;

value: expr { $$=$1; } ;
%%

int main(int argc, char** argv){
    printf("⚡ [FMM Engine v3.0 - مشغل الويب المستقل الخارق]\n");
    if(argc > 1){ 
        FILE* f = fopen(argv[1], "r"); 
        if(!f){ perror(argv[1]); return 1; } 
        yyin = f; 
    }
    yyparse();
    return 0;
}
