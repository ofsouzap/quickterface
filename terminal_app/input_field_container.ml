open! Core

type t = { mutable input_field : Input_field.t option }

let make () = { input_field = None }

let render ~render_info { input_field } =
  match input_field with
  | Some input_field -> Input_field.render ~render_info input_field
  | None -> Notty.I.empty

let handle_key_event t key_event =
  match t.input_field with
  | Some input_field -> (
      match Input_field.injest_key_event input_field key_event with
      | `Updated_to new_input_field -> t.input_field <- Some new_input_field
      | `Ready_to_be_destroyed -> t.input_field <- None)
  | None -> ()

let get_input ({ input_field } as t) ~refresh_render ~input_field_maker =
  match input_field with
  | Some _ -> Error (Error.create_s [%message "Input field is already active"])
  | None ->
      let promise, resolver = Lwt.wait () in
      let new_input_field = input_field_maker ~resolver () in
      t.input_field <- Some new_input_field;
      Ok
        (let%lwt () =
           (* Before waiting for the result, refresh the render to show the input box *)
           refresh_render ()
         in
         promise)

let get_input_any_key t ~refresh_render () =
  get_input t ~refresh_render ~input_field_maker:Input_field.make_any_key

let get_input_text t ~refresh_render () =
  get_input t ~refresh_render ~input_field_maker:Input_field.make_text

let get_input_integer t ~refresh_render () =
  get_input t ~refresh_render ~input_field_maker:Input_field.make_integer

let get_input_single_selection t ~refresh_render ~options ~option_to_string () =
  get_input t ~refresh_render
    ~input_field_maker:
      (Input_field.make_single_selection ~options ~option_to_string)

let get_input_multi_selection t ~refresh_render ~options ~option_to_string () =
  get_input t ~refresh_render
    ~input_field_maker:
      (Input_field.make_multi_selection ~options ~option_to_string)
