open! Core

type t = Default_foreground | Default_background | Red | Green | Blue

let default_foreground = Default_foreground
let default_background = Default_background
let red = Red
let green = Green
let blue = Blue

let ansi_color_code color =
  let ansi_escape = "\x1b[" in
  let color_code =
    (match color with
      | Default_foreground -> 39
      | Default_background -> 49
      | Red -> 31
      | Green -> 32
      | Blue -> 34)
    |> string_of_int
  in
  [%string "%{ansi_escape}%{color_code}m"]

let css_color_string color =
  match color with
  | Default_foreground -> "inherit"
  | Default_background -> "inherit"
  | Red -> "red"
  | Green -> "green"
  | Blue -> "blue"
