open! Core

type t

val make : unit -> t
val render : t Render_function.t
val add_log_item : t -> Log_item.t -> t
