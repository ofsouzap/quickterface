open! Core

type t

val make : ?title:string -> unit -> t
val input_any_key : t -> unit -> unit Lwt.t
val input_text : t -> unit -> string Lwt.t
val add_log_item : t -> Log_item.t -> unit Lwt.t
val set_title : t -> string -> unit Lwt.t
val render : t -> Notty.image

val handle_event :
  t -> [ Notty.Unescape.event | `Resize of int * int ] -> unit Lwt.t
