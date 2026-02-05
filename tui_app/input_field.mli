open! Core

type t

val render : t Render_function.t
val make_any_key : resolver:unit Lwt.u -> unit -> t
val make_text : resolver:string Lwt.u -> unit -> t
val make_integer : resolver:int Lwt.u -> unit -> t

val make_single_selection :
  resolver:string Lwt.u -> options:string list -> unit -> t

val injest_key_event :
  t -> Notty.Unescape.key -> [ `Updated_to of t | `Ready_to_be_destroyed ]
