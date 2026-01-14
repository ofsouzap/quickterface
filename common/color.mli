open! Core

type t

val default_foreground : t
val default_background : t
val green : t
val red : t
val blue : t
val ansi_color_code : t -> string
val css_color_string : t -> string
