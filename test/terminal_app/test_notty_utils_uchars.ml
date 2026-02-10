open! Core
open Quickterface_terminal_app

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

let%expect_test "left_block_one_eighth" =
  print_uchar Notty_utils.uchar_left_block_one_eighth;
  [%expect {| ▏ |}]

let%expect_test "left_block_one_quarter" =
  print_uchar Notty_utils.uchar_left_block_one_quarter;
  [%expect {| ▎ |}]

let%expect_test "left_block_three_eighths" =
  print_uchar Notty_utils.uchar_left_block_three_eighths;
  [%expect {| ▍ |}]

let%expect_test "left_block_half" =
  print_uchar Notty_utils.uchar_left_block_half;
  [%expect {| ▌ |}]

let%expect_test "left_block_five_eighths" =
  print_uchar Notty_utils.uchar_left_block_five_eighths;
  [%expect {| ▋ |}]

let%expect_test "left_block_three_quarters" =
  print_uchar Notty_utils.uchar_left_block_three_quarters;
  [%expect {| ▊ |}]

let%expect_test "left_block_seven_eighths" =
  print_uchar Notty_utils.uchar_left_block_seven_eighths;
  [%expect {| ▉ |}]

let%expect_test "left_block_full" =
  print_uchar Notty_utils.uchar_left_block_full;
  [%expect {| █ |}]
