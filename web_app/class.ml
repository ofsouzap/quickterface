open! Core
module Js = Js_of_ocaml.Js

type t =
  | Main_container
  | Log_container
  | Log_item
  | Text_prompt_label
  | Input_text_container_form
  | Input_text_field
  | Input_text_submit_button
  | Progress_bar_item
  | Progress_bar_label
  | Progress_bar_bar_container
  | Progress_bar_bar_fill
  | Progress_bar_progress_label
[@@deriving to_string, enumerate]

let to_prefixed_string t =
  Printf.sprintf "quickterface__%s" (String.lowercase (to_string t))

let to_js_string t = Js.string (to_prefixed_string t)
