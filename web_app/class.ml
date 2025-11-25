open! Core
module Js = Js_of_ocaml.Js

type t = Main_container | Log_container | Log_spacer | Log_item | Input_text
[@@deriving to_string, enumerate]

let to_prefixed_string t =
  Printf.sprintf "quickterface__%s" (String.lowercase (to_string t))

let to_js_string t = Js.string (to_prefixed_string t)
