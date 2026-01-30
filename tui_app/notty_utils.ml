open! Core
open Notty.I

let uchar_box_drawing_light_horizontal = Uchar.of_scalar_exn 0x2500
let uchar_box_drawing_light_vertical = Uchar.of_scalar_exn 0x2502
let uchar_box_drawing_light_down_and_right = Uchar.of_scalar_exn 0x250C
let uchar_box_drawing_light_down_and_left = Uchar.of_scalar_exn 0x2510
let uchar_box_drawing_light_up_and_right = Uchar.of_scalar_exn 0x2514
let uchar_box_drawing_light_up_and_left = Uchar.of_scalar_exn 0x2518

let boxed i =
  (* TODO-someday: can have padding so that border isn't against the content.
                   But then make sure to center content in the border *)
  let i_width = width i in
  let i_height = height i in

  let border_width = i_width + 2 in
  let border_height = i_height + 2 in

  let border =
    let uchar = uchar Theme.log_item_border in

    let horizontal_line =
      uchar uchar_box_drawing_light_horizontal (border_width - 2) 1
    in
    let vertical_line =
      uchar uchar_box_drawing_light_vertical 1 (border_height - 2)
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
      <|> void (border_width - 2) (border_height - 2)
      <|> vertical_line
    in
    top_row <-> middle_rows <-> bottom_row
  in

  let i_padded = i |> vpad 1 1 |> hpad 1 1 in

  i_padded </> border
