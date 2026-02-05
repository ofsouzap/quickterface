open! Core

type t = {
  mutable title_bar : Title_bar.t;
  mutable log : Log.t;
  input_field_container : Input_field_container.t;
}

let make ?(title = "") () =
  let title_bar = Title_bar.make ~text:title () in
  let log = Log.make () in
  let input_field_container = Input_field_container.make () in
  { title_bar; log; input_field_container }

let ok_or_raise = function Ok v -> v | Error e -> Error.raise e

let input_any_key { input_field_container; _ } ~refresh_render () =
  Input_field_container.get_input_any_key input_field_container ~refresh_render
    ()
  |> ok_or_raise

let input_text { input_field_container; _ } ~refresh_render () =
  let%lwt text =
    Input_field_container.get_input_text input_field_container ~refresh_render
      ()
    |> ok_or_raise
  in
  ignore "TODO - add input text to log";
  Lwt.return text

let add_log_item t item =
  let new_log = Log.add_log_item t.log item in
  t.log <- new_log;
  Lwt.return ()

let set_title t title_text =
  let new_title_bar = Title_bar.make ~text:title_text () in
  t.title_bar <- new_title_bar;
  Lwt.return ()

let render ~render_info { title_bar; log; input_field_container } =
  let open Notty.I in
  let title_bar_image =
    (* TODO - render title bar *)
    ignore title_bar;
    empty
  in
  let log_image = Log.render ~render_info log in
  let input_field_image =
    Input_field_container.render ~render_info input_field_container
  in
  title_bar_image <-> log_image <-> input_field_image

let handle_event { title_bar = _; log = _; input_field_container } = function
  | `Key key_event ->
      Input_field_container.handle_key_event input_field_container key_event
  | _ -> Lwt.return ()
