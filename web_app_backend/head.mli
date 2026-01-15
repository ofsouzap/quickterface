open! Core
open! Js_of_ocaml

type t

val make : document:Dom_html.document Js.t -> unit -> t Lwt.t
val set_title : t -> string -> unit -> unit Lwt.t
