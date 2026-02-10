open! Core

type t = {
  mutable title_bar : Title_bar.t;
  mutable log : Log.t;
  input_field_container : Input_field_container.t;
  mutable progress_bar : Progress_bar.t option;
}

let make ?(title = "") () =
  let title_bar = Title_bar.make ~text:title () in
  let log = Log.make () in
  let input_field_container = Input_field_container.make () in
  { title_bar; log; input_field_container; progress_bar = None }

let ok_or_raise = function Ok v -> v | Error e -> Error.raise e

let input_any_key { input_field_container; _ } ~refresh_render () =
  Input_field_container.get_input_any_key input_field_container ~refresh_render
    ()
  |> ok_or_raise

let input_text { input_field_container; _ } ~refresh_render () =
  Input_field_container.get_input_text input_field_container ~refresh_render ()
  |> ok_or_raise

let input_integer { input_field_container; _ } ~refresh_render () =
  Input_field_container.get_input_integer input_field_container ~refresh_render
    ()
  |> ok_or_raise

let input_single_selection { input_field_container; _ } ~refresh_render ~options
    () =
  Input_field_container.get_input_single_selection input_field_container
    ~refresh_render ~options ()
  |> ok_or_raise

let input_multi_selection { input_field_container; _ } ~refresh_render ~options
    () =
  Input_field_container.get_input_multi_selection input_field_container
    ~refresh_render ~options ()
  |> ok_or_raise

let add_log_item t item =
  let new_log = Log.add_log_item t.log item in
  t.log <- new_log;
  Lwt.return ()

let set_title t title_text =
  let new_title_bar = Title_bar.make ~text:title_text () in
  t.title_bar <- new_title_bar;
  Lwt.return ()

let render ~render_info:({ Render_info.screen_height; _ } as render_info)
    { title_bar; log; input_field_container; progress_bar } =
  let open Notty.I in
  let title_bar_image = Title_bar.render ~render_info title_bar in
  let log_image = Log.render ~render_info log in
  let input_field_image =
    Input_field_container.render ~render_info input_field_container
  in
  let progress_bar_image =
    Option.value_map progress_bar ~default:empty
      ~f:(Progress_bar.render ~render_info)
  in

  let title_bar_height = height title_bar_image in
  let input_field_height = height input_field_image in
  let progress_bar_height = height progress_bar_image in
  let log_height =
    screen_height - title_bar_height - input_field_height - progress_bar_height
  in
  let log_height_to_crop_off = max 0 (height log_image - log_height) in

  title_bar_image
  <-> vcrop log_height_to_crop_off 0 log_image
  <-> input_field_image <-> progress_bar_image

let handle_event
    { title_bar = _; log = _; input_field_container; progress_bar = _ } =
  function
  | `Key key_event ->
      Input_field_container.handle_key_event input_field_container key_event
  | _ -> ()

let with_progress_bar t ~config ~refresh_render ~f =
  match t.progress_bar with
  | Some _ -> raise_s [%message "Cannot show multiple progress bars at once"]
  | None ->
      t.progress_bar <- Some (Progress_bar.make ~config ());
      let increment_progress_bar () =
        let do_increment () =
          match t.progress_bar with
          | None -> raise_s [%message "Progress bar no longer exists"]
          | Some progress_bar ->
              t.progress_bar <- Some (Progress_bar.increment progress_bar)
        in
        do_increment ();
        refresh_render ()
      in
      f ~increment_progress_bar ()
