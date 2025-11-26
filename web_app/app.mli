open! Core
open! Js_of_ocaml

type t = { log : Log.t }

val make : unit -> t
val read_text : t -> unit -> string Lwt.t
val print_text : t -> string -> unit -> unit Lwt.t
