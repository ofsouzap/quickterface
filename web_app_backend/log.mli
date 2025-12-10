open! Core
open! Js_of_ocaml

type t = {
  document : Dom_html.document Js.t;
  container : Dom_html.divElement Js.t;
}

val make : document:Dom_html.document Js.t -> main_container:#Dom.node Js.t -> t
val add_output_text : t -> value:string -> unit -> unit Lwt.t
val read_input_text : t -> unit -> string Lwt.t
val add_output_math : t -> value:Quickterface.Math.t -> unit -> unit Lwt.t

val with_progress_bar :
  ?label:string ->
  t ->
  maximum:int ->
  f:(increment_progress_bar:(unit -> unit Lwt.t) -> unit -> 'a Lwt.t) ->
  unit ->
  'a Lwt.t
