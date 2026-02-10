open! Core

type t

val green : t
val red : t
val blue : t
val ansi_color_code : t -> int
val css_color_string : t -> string
val to_rgb : t -> int * int * int
