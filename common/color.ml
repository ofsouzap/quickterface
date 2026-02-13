open! Core

type t = Red | Green | Blue

let red = Red
let green = Green
let blue = Blue

let css_color_string color =
  match color with
  | Red -> "red"
  | Green -> "green"
  | Blue -> "blue"

let to_rgb color =
  match color with
  | Red -> (255, 0, 0)
  | Green -> (0, 255, 0)
  | Blue -> (0, 0, 255)
