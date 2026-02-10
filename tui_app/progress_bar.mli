open! Core

type t

val make : ?current_value:int -> config:Progress_bar_config.t -> unit -> t
val increment : t -> t
val render : t Render_function.t
