open Core.Std
open Expr

let buf = Lexing.from_string "{carbon,nobrac}.{cpu,then.{mem,disk}}"

let prs = Expr_parser.expr Expr_lexer.token buf

let rec merge_seg acc = function
  | Segment s -> (match acc with
    | [] -> [ s ]
    | _ -> List.map ~f:(fun p -> p ^ "." ^ s) acc)
  | List l -> List.concat (List.map ~f:(fun p -> merge_path acc p) l)
and merge_path acc = function
  | [] -> acc
  | [ x ] -> merge_seg acc x
  | x :: xs -> merge_path (merge_seg acc x) xs

let () =
  let Path path = prs in
  List.fold ~init:() ~f:(fun () path -> Printf.printf "%s\n" path) (merge_path [] path)

let rec dump_args = function
  | [] -> ""
  | [ x ] -> dump x
  | x :: xs -> (dump x) ^ ", " ^ (dump_args xs)
and dump_path_list (pl : segment list list) = match pl with
  | [] -> ""
  | [ x ] -> dump_path x
  | x :: xs -> (dump_path x) ^ ", " ^ (dump_path_list xs)
and dump_segment (seg: segment) = match seg with
  | Segment s -> s
  | List l -> "{ " ^ (dump_path_list l) ^ " }"
and dump_path (path: segment list) = match path with
  | [] -> "<empty>"
  | [ x ] -> dump_segment x
  | x :: xs -> (dump_segment x) ^ "." ^ (dump_path xs)
and dump = function
  | Ident id -> id
  | Int v -> Int.to_string v
  | Float v -> Float.to_string v
  | Call (i, a) -> i ^ "(" ^ (dump_args a) ^ ")"
  | Str v -> "\"" ^ v ^ "\""
  | Path v -> dump_path v

let () = Printf.printf "%s\n" (dump prs)
