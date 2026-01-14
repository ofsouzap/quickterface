open! Core

type _ t =
  | Text : Output_text_options.t -> string t
  | Math : Output_text_options.t -> Math.t t
