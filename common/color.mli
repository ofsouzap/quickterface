open! Core

type t

val green : t
val red : t
val blue : t
val css_color_string : t -> string
val to_rgb : t -> int * int * int
