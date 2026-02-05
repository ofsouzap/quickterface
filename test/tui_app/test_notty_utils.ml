open! Core
open Notty
open Notty.I
open Quickterface_tui_app

let no_attr = A.empty
let img1 = string no_attr "Hello, World!"
let img2 = (string no_attr) "top" <-> (string no_attr) "bottom"
let img3 = (string no_attr) "left" <|> void 2 0 <|> (string no_attr) "right"

let%expect_test "img1" =
  Notty_unix.output_image img1;
  [%expect {| Hello, World! |}]

let%expect_test "img2" =
  Notty_unix.output_image img2;
  [%expect {|
    top
    bottom |}]

let%expect_test "img3" =
  Notty_unix.output_image img3;
  [%expect {| left  right |}]

let%expect_test "default box img1" =
  let boxed_img = Notty_utils.boxed img1 in
  Notty_unix.output_image boxed_img;
  [%expect
    {|
    ┌─────────────┐
    │Hello, World!│
    └─────────────┘
    |}]

let%expect_test "default box img2" =
  let boxed_img = Notty_utils.boxed img2 in
  Notty_unix.output_image boxed_img;
  [%expect {|
    ┌──────┐
    │top   │
    │bottom│
    └──────┘
    |}]

let%expect_test "default box img3" =
  let boxed_img = Notty_utils.boxed img3 in
  Notty_unix.output_image boxed_img;
  [%expect {|
    ┌───────────┐
    │left  right│
    └───────────┘
    |}]

let%expect_test "exact padding box img1" =
  let boxed_img =
    Notty_utils.boxed
      ~padding_control:
        (`Exact_padding { left = 1; right = 2; top = 3; bottom = 4 })
      img1
  in
  Notty_unix.output_image boxed_img;
  [%expect
    {|
    ┌────────────────┐
    │                │
    │                │
    │                │
    │ Hello, World!  │
    │                │
    │                │
    │                │
    │                │
    └────────────────┘
    |}]

let%expect_test "default box img2" =
  let boxed_img =
    Notty_utils.boxed
      ~padding_control:
        (`Exact_padding { left = 1; right = 2; top = 3; bottom = 4 })
      img2
  in
  Notty_unix.output_image boxed_img;
  [%expect {|
    ┌─────────┐
    │         │
    │         │
    │         │
    │ top     │
    │ bottom  │
    │         │
    │         │
    │         │
    │         │
    └─────────┘
    |}]

let%expect_test "default box img3" =
  let boxed_img =
    Notty_utils.boxed
      ~padding_control:
        (`Exact_padding { left = 1; right = 2; top = 3; bottom = 4 })
      img3
  in
  Notty_unix.output_image boxed_img;
  [%expect {|
    ┌──────────────┐
    │              │
    │              │
    │              │
    │ left  right  │
    │              │
    │              │
    │              │
    │              │
    └──────────────┘
    |}]
