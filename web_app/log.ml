open! Core
open! Js_of_ocaml

type t = {
  document : Dom_html.document Js.t;
  container : Dom_html.divElement Js.t;
}

let make ~document ~main_container : t =
  let container = Dom_html.createDiv document in
  (container##.className := Class.(to_js_string Log_container));
  Dom.appendChild main_container container;

  { document; container }

let add_item { document; container } ~item_element () =
  let container_div = Dom_html.createDiv document in
  (container_div##.className := Class.(to_js_string Log_item));
  Dom.appendChild container_div item_element;

  Dom.appendChild container container_div;
  Lwt.return ()

let add_output_text ({ document; container = _ } as t) ~text () =
  let%lwt output_text = Outputs.Text.make ~document ~text in
  let%lwt () = add_item t ~item_element:(Outputs.Text.element output_text) () in
  Lwt.return ()

let read_input_text ({ document; container = _ } as t) () =
  let input_text = Inputs.Text.make ~document in
  let%lwt () = add_item t ~item_element:(Inputs.Text.element input_text) () in
  Inputs.Text.wait_for_input input_text ()
