%{
  open Expr
%}
%token <int> INT
%token <float> FLOAT
%token <string> IDENT
%token <string> STRING
%token LPAREN
%token RPAREN
%token LBRACE
%token RBRACE
%token DOT
%token COMMA
%token EOF
%start expr
%type <Expr.expr> expr
%%

expr:
   | INT { Int $1 }
   | FLOAT { Float $1 }
   | STRING { Str $1 }
   | IDENT LPAREN args RPAREN { Call ($1, $3) }
   | path { Path $1 }
  ;

  path:
   | IDENT { [ Segment $1 ] }
   | IDENT DOT path { (Segment $1) :: $3 }
   | LBRACE path_list RBRACE { [ List $2 ] }
   | LBRACE path_list RBRACE DOT path { (List $2) :: $5 }
  ;

  path_list:
   | path { [ $1 ] }
   | path COMMA path_list { $1 :: $3 }
  ;

  args:
   | expr { [ $1 ] }
   | expr COMMA args { $1 :: $3 }
  ;
