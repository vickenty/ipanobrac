type segment =
  | Segment of string
  | List of segment list list

type expr =
  | Call of (string * expr list)
  | Int of int
  | Float of float
  | Str of string
  | Ident of string
  | Path of segment list
