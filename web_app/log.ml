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

let add_output_text ({ document; container = _ } as t) ~value () =
  let%lwt output_text = Outputs.Text.make ~document ~value in
  let%lwt () = add_item t ~item_element:(Outputs.Text.element output_text) () in
  Lwt.return ()

let read_input_text ({ document; container = _ } as t) () =
  let input_text = Inputs.Text.make ~document in
  let%lwt () = add_item t ~item_element:(Inputs.Text.element input_text) () in
  Inputs.Text.wait_for_input input_text ()

let with_progress_bar ?label ({ document; container = _ } as t) ~maximum ~f () =
  let%lwt progress_bar = Outputs.Progress_bar.make ~document ~label ~maximum in
  let%lwt () =
    add_item t ~item_element:(Outputs.Progress_bar.element progress_bar) ()
  in

  let curr_value = ref 0 in
  let increment_progress_bar () =
    curr_value := !curr_value + 1;
    Outputs.Progress_bar.set_value progress_bar !curr_value ()
  in
  let%lwt result = f ~increment_progress_bar () in

  let%lwt () = Outputs.Progress_bar.finish progress_bar () in
  Lwt.return result
