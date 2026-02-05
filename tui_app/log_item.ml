open! Core

type t = Output_text of string | Input_text of string

let output_text ?options:_ text = (* TODO - use options *) Output_text text

let attr = function
  | Output_text _ -> Theme.text_output
  | Input_text _ -> Theme.text_input_frozen

let render ~render_info t =
  let open Notty.I in
  let t_attr = attr t in
  (match t with
    | Output_text text -> string t_attr text
    | Input_text text -> string t_attr text)
  |> Notty_utils.boxed
       ~padding_control:
         (`To_min_boxed_size
            (Some (render_info.Render_info.screen_width, Right), None))

(* TODO - remove these *)
let () = ignore (Input_text "")
