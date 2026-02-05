open! Core

type t

val make : ?title:string -> unit -> t

val input_any_key :
  t -> refresh_render:(unit -> unit Lwt.t) -> unit -> unit Lwt.t

val input_text :
  t -> refresh_render:(unit -> unit Lwt.t) -> unit -> string Lwt.t

val input_integer :
  t -> refresh_render:(unit -> unit Lwt.t) -> unit -> int Lwt.t

val input_single_selection :
  t ->
  refresh_render:(unit -> unit Lwt.t) ->
  options:string list ->
  unit ->
  string Lwt.t

val add_log_item : t -> Log_item.t -> unit Lwt.t
val set_title : t -> string -> unit Lwt.t
val render : t Render_function.t
val handle_event : t -> [ Notty.Unescape.event | `Resize of int * int ] -> unit
