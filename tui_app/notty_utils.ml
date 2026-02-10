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

  let pad { left; right; top; bottom } = pad ~l:left ~r:right ~t:top ~b:bottom
end

module Width_side = struct
  type t = Left | Right
end

module Height_side = struct
  type t = Top | Bottom
end

let uchar_box_drawing_light_horizontal = Uchar.of_scalar_exn 0x2500
let uchar_box_drawing_light_vertical = Uchar.of_scalar_exn 0x2502
let uchar_box_drawing_light_down_and_right = Uchar.of_scalar_exn 0x250C
let uchar_box_drawing_light_down_and_left = Uchar.of_scalar_exn 0x2510
let uchar_box_drawing_light_up_and_right = Uchar.of_scalar_exn 0x2514
let uchar_box_drawing_light_up_and_left = Uchar.of_scalar_exn 0x2518
let uchar_paren_drawing_light_top_left = Uchar.of_scalar_exn 0x239B
let uchar_paren_drawing_light_mid_left = Uchar.of_scalar_exn 0x239C
let uchar_paren_drawing_light_bottom_left = Uchar.of_scalar_exn 0x239D
let uchar_paren_drawing_light_top_right = Uchar.of_scalar_exn 0x239E
let uchar_paren_drawing_light_mid_right = Uchar.of_scalar_exn 0x239F
let uchar_paren_drawing_light_bottom_right = Uchar.of_scalar_exn 0x23A0
let uchar_paren_top_half_integral = Uchar.of_scalar_exn 0x2320
let uchar_paren_bottom_half_integral = Uchar.of_scalar_exn 0x2321
let uchar_paren_integral_extender = Uchar.of_scalar_exn 0x23AE
let uchar_left_block_one_eighth = Uchar.of_scalar_exn 0x258F
let uchar_left_block_one_quarter = Uchar.of_scalar_exn 0x258E
let uchar_left_block_three_eighths = Uchar.of_scalar_exn 0x258D
let uchar_left_block_half = Uchar.of_scalar_exn 0x258C
let uchar_left_block_five_eighths = Uchar.of_scalar_exn 0x258B
let uchar_left_block_three_quarters = Uchar.of_scalar_exn 0x258A
let uchar_left_block_seven_eighths = Uchar.of_scalar_exn 0x2589
let uchar_left_block_full = Uchar.of_scalar_exn 0x2588

let boxed ?(padding_control = `None) raw_content =
  let content =
    match padding_control with
    | `None -> raw_content
    | `Exact_padding padding -> Sides.pad padding raw_content
    | `To_min_boxed_size (width_options, height_options) ->
        let raw_size_with_border =
          Dimensions.(of_image raw_content + const 2)
        in
        let hpadder =
          match width_options with
          | None -> Fn.id
          | Some (min_width, expand_width_on) ->
              let width_to_add =
                max 0 (min_width - raw_size_with_border.width)
              in
              let left, right =
                match expand_width_on with
                | Width_side.Left -> (width_to_add, 0)
                | Right -> (0, width_to_add)
              in
              hpad left right
        in
        let vpadder =
          match height_options with
          | None -> Fn.id
          | Some (min_height, expand_height_on) ->
              let height_to_add =
                max 0 (min_height - raw_size_with_border.height)
              in
              let top, bottom =
                match expand_height_on with
                | Height_side.Top -> (height_to_add, 0)
                | Bottom -> (0, height_to_add)
              in
              vpad top bottom
        in
        vpadder (hpadder raw_content)
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

  pad ~l:1 ~r:1 ~t:1 ~b:1 content </> border
