open! Core
open Notty.I

module Dimensions = struct
  type 'a t = { width : 'a; height : 'a }

  let of_image i = { width = width i; height = height i }
  let ( + ) x y = { width = x.width + y.width; height = x.height + y.height }
  let const x = { width = x; height = x }
end

module Sides = struct
  type 'a t = { left : 'a; right : 'a; top : 'a; bottom : 'a }
end

let uchar_box_drawing_light_horizontal = Uchar.of_scalar_exn 0x2500
let uchar_box_drawing_light_vertical = Uchar.of_scalar_exn 0x2502
let uchar_box_drawing_light_down_and_right = Uchar.of_scalar_exn 0x250C
let uchar_box_drawing_light_down_and_left = Uchar.of_scalar_exn 0x2510
let uchar_box_drawing_light_up_and_right = Uchar.of_scalar_exn 0x2514
let uchar_box_drawing_light_up_and_left = Uchar.of_scalar_exn 0x2518

let boxed ?(padding_control = `None) raw_content =
  let content =
    match padding_control with
    | `None -> raw_content
    | `Exact_padding { Sides.left; right; top; bottom } ->
        hpad left right (vpad top bottom raw_content)
  in

  let border_size = Dimensions.(of_image content + const 2) in

  let border =
    let uchar = uchar Theme.log_item_border in

    let horizontal_line =
      uchar uchar_box_drawing_light_horizontal (border_size.width - 2) 1
    in
    let vertical_line =
      uchar uchar_box_drawing_light_vertical 1 (border_size.height - 2)
    in

    let top_row =
      uchar uchar_box_drawing_light_down_and_right 1 1
      <|> horizontal_line
      <|> uchar uchar_box_drawing_light_down_and_left 1 1
    in
    let bottom_row =
      uchar uchar_box_drawing_light_up_and_right 1 1
      <|> horizontal_line
      <|> uchar uchar_box_drawing_light_up_and_left 1 1
    in

    let middle_rows =
      vertical_line
      <|> void (border_size.width - 2) (border_size.height - 2)
      <|> vertical_line
    in
    top_row <-> middle_rows <-> bottom_row
  in

  vpad 1 1 (hpad 1 1 content) </> border
