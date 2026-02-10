open! Core
open Quickterface_tui_app

let print_uchar uchar =
  let buf = Buffer.create 4 in
  Uutf.Buffer.add_utf_8 buf uchar;
  print_string (Buffer.contents buf)

let%expect_test "box_drawing_light_horizontal" =
  print_uchar Notty_utils.uchar_box_drawing_light_horizontal;
  [%expect {| ─ |}]

let%expect_test "box_drawing_light_vertical" =
  print_uchar Notty_utils.uchar_box_drawing_light_vertical;
  [%expect {| │ |}]

let%expect_test "box_drawing_light_down_and_right" =
  print_uchar Notty_utils.uchar_box_drawing_light_down_and_right;
  [%expect {| ┌ |}]

let%expect_test "box_drawing_light_down_and_left" =
  print_uchar Notty_utils.uchar_box_drawing_light_down_and_left;
  [%expect {| ┐ |}]

let%expect_test "box_drawing_light_up_and_right" =
  print_uchar Notty_utils.uchar_box_drawing_light_up_and_right;
  [%expect {| └ |}]

let%expect_test "box_drawing_light_up_and_left" =
  print_uchar Notty_utils.uchar_box_drawing_light_up_and_left;
  [%expect {| ┘ |}]

let%expect_test "paren_drawing_light_top_left" =
  print_uchar Notty_utils.uchar_paren_drawing_light_top_left;
  [%expect {| ⎛ |}]

let%expect_test "paren_drawing_light_mid_left" =
  print_uchar Notty_utils.uchar_paren_drawing_light_mid_left;
  [%expect {| ⎜ |}]

let%expect_test "paren_drawing_light_bottom_left" =
  print_uchar Notty_utils.uchar_paren_drawing_light_bottom_left;
  [%expect {| ⎝ |}]

let%expect_test "paren_drawing_light_top_right" =
  print_uchar Notty_utils.uchar_paren_drawing_light_top_right;
  [%expect {| ⎞ |}]

let%expect_test "paren_drawing_light_mid_right" =
  print_uchar Notty_utils.uchar_paren_drawing_light_mid_right;
  [%expect {| ⎟ |}]

let%expect_test "paren_drawing_light_bottom_right" =
  print_uchar Notty_utils.uchar_paren_drawing_light_bottom_right;
  [%expect {| ⎠ |}]

let%expect_test "paren_top_half_integral" =
  print_uchar Notty_utils.uchar_paren_top_half_integral;
  [%expect {| ⌠ |}]

let%expect_test "paren_bottom_half_integral" =
  print_uchar Notty_utils.uchar_paren_bottom_half_integral;
  [%expect {| ⌡ |}]

let%expect_test "paren_integral_extender" =
  print_uchar Notty_utils.uchar_paren_integral_extender;
  [%expect {| ⎮ |}]
