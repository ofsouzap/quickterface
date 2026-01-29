open! Core

type t

val render : t -> Notty.image
val make_any_key : resolver:unit Lwt.u -> unit -> t
val make_text : resolver:string Lwt.u -> unit -> t

val injest_key_event :
  t -> Notty.Unescape.key -> [ `Updated_to of t | `Ready_to_be_destroyed ] Lwt.t
