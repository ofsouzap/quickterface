open! Core

type t

val output_text : ?options:Quickterface.Output_text_options.t -> string -> t
val render : t -> Notty.I.t
