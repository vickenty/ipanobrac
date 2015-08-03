open Core.Std

let rec plot_rest ctx = function
  | [] -> ()
  | (x, y) :: ps -> let () = Cairo.line_to ctx x y in plot_rest ctx ps

let plot ctx = function
  | [] -> ()
  | [ x ] -> ()
  | (x, y) :: ps -> let () = Cairo.move_to ctx x y in plot_rest ctx ps

let png_of_surface surf =
  let buf = ref "" in
  let write v = buf := !buf ^ v in
  let () = Cairo.PNG.write_to_stream surf write in
  !buf

let bbox_update (minx, miny, maxx, maxy) (x, y) =
  (min minx x), (min miny y), (max maxx x), (max maxy y)

let bbox = function
  | [] -> failwith "empty data"
  | (x, y) :: xs -> List.fold ~init:(x, y, x, y) ~f:bbox_update xs

let setup ctx (sw: int) (sh: int) (minx, miny, maxx, maxy) =
  let dw = (Float.of_int sw) /. (maxx -. minx) in
  let dh = (Float.of_int sh) /. (maxy -. miny) in
  (* move origin to the bottom-left corner of the surface *)
  let () = Cairo.translate ctx 0. (Float.of_int sh) in
  (* scale viewport to fit around data, flip y axis *)
  let () = Cairo.scale ctx dw (-.dh) in
  (* move to where the data is *)
  let () = Cairo.translate ctx (-.minx) (-.miny) in
  ()

let render ~data ~width ~height =
  let surf = Cairo.Image.create Cairo.Image.RGB24 width height in
  let ctx = Cairo.create surf in
  let () = Cairo.select_font_face ctx "Luculent" in
  let () = Cairo.set_font_size ctx 12.0 in
  let () = Cairo.set_source_rgb ctx 1. 1. 1. in
  (* this save/restore hack is needed to have 1px stroke with translated path.
     from http://article.gmane.org/gmane.comp.graphics.agg/2518 *)
  let () = Cairo.save ctx in
  let () = setup ctx width height (bbox data) in
  let () = plot ctx data in
  let () = Cairo.restore ctx in
  let () = Cairo.set_line_width ctx 1. in
  let () = Cairo.stroke ctx in
  (* add a friendly label to the graph *)
  let () = Cairo.save ctx in
  let () = setup ctx width height (bbox data) in
  let () = Cairo.move_to ctx 1438429260.0 0.020016435130532913 in
  let () = Cairo.restore ctx in
  let () = Cairo.show_text ctx "You are here" in
  png_of_surface surf

let data = render
  ~width:800
  ~height:400
  ~data:[ (1438428900.0, 0.03168462635291601);
          (1438428960.0, 0.01998122802662973);
          (1438429020.0, 0.013343659285420814);
          (1438429080.0, 0.020003119557831593);
          (1438429140.0, 0.013321261590050558);
          (1438429200.0, 0.01333279468804418);
          (1438429260.0, 0.020016435130532913);
          (1438429320.0, 0.02000151447001464);
          (1438429380.0, 0.013322980713048391);
          (1438429440.0, 0.013340502724206747);
          (1438429500.0, 0.01998687263254178);
          (1438429560.0, 0.020000203373116743);
          (1438429620.0, 0.019999769292950366);
          (1438429680.0, 0.01334426540997783);
          (1438429740.0, 0.020000424314600654);
          (1438429800.0, 0.013335053347864995);
          (1438429860.0, 0.019990728942690533);
          (1438429920.0, 0.02000295412458255);
          (1438429980.0, 0.013328405824422946);
          (1438430040.0, 0.01999810252709408);
          (1438430100.0, 0.02000566762317572);
          (1438430160.0, 0.013339721029681138);
          (1438430220.0, 0.01998424746519235);
          (1438430280.0, 0.013343283602867335);
          (1438430340.0, 0.019983738224508) ]

let () = Out_channel.write_all "test.png" data
