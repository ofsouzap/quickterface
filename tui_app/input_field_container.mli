open! Core

type t

val make : unit -> t
val render : t -> Notty.image
val handle_key_event : t -> Notty.Unescape.key -> unit Lwt.t
val get_input_text : t -> unit -> (string Lwt.t, Error.t) result
