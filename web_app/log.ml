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
  let log_spacer = Dom_html.createDiv document in
  (log_spacer##.className := Class.(to_js_string Log_spacer));
  Dom.appendChild container log_spacer;
  { document; container }

let add_output_text { document; container } ~text () =
  let%lwt element = Outputs.Text.make ~document ~text in
  Dom.appendChild container element.element;
  Lwt.return ()

let read_input_text { document; container } () =
  let input_text = Inputs.Text.make ~document in
  Dom.appendChild container input_text.element;
  Inputs.Text.wait_for_text_input input_text ()
