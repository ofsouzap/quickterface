open! Core
open! Js_of_ocaml

type t

val make : document:Dom_html.document Js.t -> t
val await_elements : t -> Dom_html.element Utils.Await_load_element.t list
