open Core.Std
open Async.Std
open Cohttp
open Cohttp_async

let make_response uri meth headers body =
  Printf.sprintf "URI: %s\nMethod: %s\nHeaders: %s\nBody: %s\n" uri meth headers body

let server =
  let callback ~body _addr req =
    let uri = req |> Request.uri |> Uri.to_string in
    let meth = req |> Request.meth |> Code.string_of_method in
    let headers = req |> Request.headers |> Header.to_string in
    let resp_body = body |> Body.to_string >>=
        (fun body -> return (make_response uri meth headers body)) in
    resp_body >>= (fun body -> Server.respond_with_string body)
  in
  Server.create (Tcp.on_port 8085) callback

let () = never_returns (Scheduler.go ())
