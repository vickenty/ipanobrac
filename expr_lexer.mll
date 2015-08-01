{
  open Core.Std
  open Expr_parser
}

let alpha = ['a' - 'z' 'A' - 'Z' ]
let num = [ '0' - '9' ]
let sign = '+' | '-'
let int = sign? num+
let float = sign? num+ ('.' num+)? (['e' 'E'] sign? num+)?
let ws = [ ' ' '\t' ]
let ident = alpha (alpha | num | '*')+

rule token = parse
    | '(' { LPAREN }
    | ')' { RPAREN }
    | '{' { LBRACE }
    | '}' { RBRACE }
    | '.' { DOT }
    | ',' { COMMA }
    | ws+
        { token lexbuf }

    | '"' ( ( '\\' '"' | [^ '"'] )* as str ) '"'
        { STRING str }

    | int as v
        { INT (Int.of_string v) }

    | float  as v
        { FLOAT (Float.of_string v) }

    | ident as ident
        { IDENT ident }

    | _ as c { failwith "Bad input" }

    | eof { EOF }
