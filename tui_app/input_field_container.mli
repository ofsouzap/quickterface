open! Core

type t

val make : unit -> t
val render : t Render_function.t
val handle_key_event : t -> Notty.Unescape.key -> unit Lwt.t

val get_input_any_key :
  t ->
  refresh_render:(unit -> unit Lwt.t) ->
  unit ->
  (unit Lwt.t, Error.t) result

val get_input_text :
  t ->
  refresh_render:(unit -> unit Lwt.t) ->
  unit ->
  (string Lwt.t, Error.t) result

val get_input_integer :
  t ->
  refresh_render:(unit -> unit Lwt.t) ->
  unit ->
  (int Lwt.t, Error.t) result
