open! Core

type t

val make : text:string -> unit -> t
val render : t Render_function.t
