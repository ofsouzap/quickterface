open! Core
open! Js_of_ocaml

type t = {
  document : Dom_html.document Js.t;
  container : Dom_html.divElement Js.t;
}

val make : document:Dom_html.document Js.t -> main_container:#Dom.node Js.t -> t
val add_output_text : t -> text:string -> unit -> unit Lwt.t
val read_input_text : t -> unit -> string Lwt.t
