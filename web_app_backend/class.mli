open! Core
module Js = Js_of_ocaml.Js

type t =
  | Main_container
  | Log_container
  | Log_item_default_output_channel
  | Log_item_error_channel
  | Text_prompt_label
  | Input_container_form
  | Input_submit_button
  | Input_multiselect_container
  | Output_math
  | Progress_bar_item
  | Progress_bar_label
  | Progress_bar_bar_container
  | Progress_bar_bar_fill_in_progress
  | Progress_bar_bar_fill_completed
  | Progress_bar_progress_label
[@@deriving enumerate]

val to_prefixed_string : t -> string
val to_js_string : t -> Js.js_string Js.t
