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

let output_channel_options_class
    Quickterface.
      { Output_text_options.channel_options = output_channel_options } =
  match output_channel_options with
  | Quickterface.Output_channel_options.Default_output_channel _ ->
      Class.Log_item_default_output_channel
  | Error_channel -> Class.Log_item_error_channel

let add_item ?(log_item_class = Class.Log_item_default_output_channel)
    { document; container } ~item_element () =
  let container_div = Dom_html.createDiv document in
  container_div##.className := Class.to_js_string log_item_class;
  Dom.appendChild container_div item_element;

  Dom.appendChild container container_div;
  Lwt.return ()

let input_text ({ document; container = _ } as t) () =
  let input_text = Inputs.Text.make () ~document in
  let%lwt () = add_item t ~item_element:(Inputs.Text.element input_text) () in
  Inputs.Text.wait_for_input input_text ()

let input_integer ({ document; container = _ } as t) () =
  let input = Inputs.Integer.make () ~document in
  let%lwt () = add_item t ~item_element:(Inputs.Integer.element input) () in
  Inputs.Integer.wait_for_input input ()

let input_single_selection ({ document; container = _ } as t) options () =
  let input = Inputs.Single_selection.make options ~document in
  let%lwt () =
    add_item t ~item_element:(Inputs.Single_selection.element input) ()
  in
  Inputs.Single_selection.wait_for_input input ()

let input_multi_selection ({ document; container = _ } as t) options () =
  let input = Inputs.Multi_selection.make options ~document in
  let%lwt () =
    add_item t ~item_element:(Inputs.Multi_selection.element input) ()
  in
  Inputs.Multi_selection.wait_for_input input ()

let add_output_text ?(options = Quickterface.Output_text_options.default)
    ({ document; container = _ } as t) ~value () =
  let%lwt output_text = Outputs.Text.make ~document ~options ~value in
  let%lwt () =
    add_item t
      ~item_element:(Outputs.Text.element output_text)
      ~log_item_class:(output_channel_options_class options)
      ()
  in
  Lwt.return ()

let add_output_math ?(options = Quickterface.Output_text_options.default)
    ({ document; container = _ } as t) ~value () =
  let%lwt output_math = Outputs.Math.make ~document ~options ~value in
  let%lwt () =
    add_item t
      ~item_element:(Outputs.Math.element output_math)
      ~log_item_class:(output_channel_options_class options)
      ()
  in
  Lwt.return ()

let add_output_title ({ document; container = _ } as t) ~value () =
  let%lwt output_title = Outputs.Title.make ~document ~options:() ~value in
  let%lwt () =
    add_item t
      ~item_element:(Outputs.Title.element output_title)
      ~log_item_class:Class.Log_item_default_output_channel ()
  in
  Lwt.return ()

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
