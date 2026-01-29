open! Core

type t

val make : unit -> t
val render : t -> Notty.image
val add_log_item : t -> Log_item.t -> t
