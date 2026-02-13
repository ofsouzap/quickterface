open! Core

type t

val render : t Render_function.t
val make_any_key : resolver:unit Lwt.u -> unit -> t
val make_text : prompt:string -> resolver:string Lwt.u -> unit -> t
val make_integer : resolver:int Lwt.u -> unit -> t

val make_single_selection :
  resolver:'a Lwt.u ->
  options:'a list ->
  option_to_string:('a -> string) ->
  unit ->
  t

val make_multi_selection :
  resolver:'a list Lwt.u ->
  options:'a list ->
  option_to_string:('a -> string) ->
  unit ->
  t

val injest_key_event :
  t -> Notty.Unescape.key -> [ `Updated_to of t | `Ready_to_be_destroyed ]
