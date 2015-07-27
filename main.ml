open Core.Std
open Async.Std
open Cohttp
open Cohttp_async

let backend_uri = Uri.of_string "http://localhost:8080"

let send_request uri =
  Client.get uri
  >>= fun (code, body) -> Body.to_string body
  >>= fun body -> return body

let make_request path query =
  Uri.with_query (Uri.with_path backend_uri path) query

let handler_metrics_find uri meth headers body =
  let req = make_request "/metrics/find/" (Uri.query uri) in
  send_request req >>= fun resp -> return (`OK, resp)

let handler_render uri meth headers body =
  let req = make_request "/render/" (Uri.query uri) in
  send_request req >>= fun resp -> return (`OK, resp)

let handler_not_found uri meth headers body =
  IO.return (`Not_found, "Bad luck: " ^ (Uri.path uri) ^ "\n")

let dispatch uri =
  match Uri.path uri with
  | "/metrics/find/" -> Some handler_metrics_find
  | "/render/" -> Some handler_render
  | _ -> None

let make_response uri meth headers body =
  match dispatch uri with
  | Some handler -> handler uri meth headers body
  | None -> handler_not_found uri meth headers body

let callback ~body _addr req =
  let uri = Request.uri req in
  let meth = Request.meth req in
  let headers = Request.headers req in
  Body.to_string body
  >>= fun body -> make_response uri meth headers body
  >>= fun (code, body) -> Server.respond_with_string ~code body

let server = Server.create (Tcp.on_port 8085) callback

let () = never_returns (Scheduler.go ())
