open! Core
module Js = Js_of_ocaml.Js

type t = Main_container | Log_container | Log_item | Input_text
[@@deriving enumerate]

val to_prefixed_string : t -> string
val to_js_string : t -> Js.js_string Js.t
