open! Core
open Notty
open Quickterface.Math
open Quickterface_tui_app

include struct
  open Quickterface_tui_app.Log_item.For_testing

  let render_math =
    render_math
      ~render_info:{ Render_info.screen_width = 0; screen_height = 1 }
      A.empty
end

let%expect_test "literal" =
  let img = render_math (Literal "x") in
  Notty_unix.output_image img;
  [%expect {| x |}]

let%expect_test "infinity" =
  let img = render_math Infinity in
  Notty_unix.output_image img;
  [%expect {| ∞ |}]

let%expect_test "pi" =
  let img = render_math Pi in
  Notty_unix.output_image img;
  [%expect {| π |}]

let%expect_test "e" =
  let img = render_math E in
  Notty_unix.output_image img;
  [%expect {| e |}]

let%expect_test "plus" =
  let img = render_math Plus in
  Notty_unix.output_image img;
  [%expect {| + |}]

let%expect_test "star" =
  let img = render_math Star in
  Notty_unix.output_image img;
  [%expect {| * |}]

let%expect_test "cdot" =
  let img = render_math C_dot in
  Notty_unix.output_image img;
  [%expect {| · |}]

let%expect_test "exp" =
  let img = render_math Exp in
  Notty_unix.output_image img;
  [%expect {| exp |}]

let%expect_test "ln" =
  let img = render_math Ln in
  Notty_unix.output_image img;
  [%expect {| ln |}]

let%expect_test "partial" =
  let img = render_math Partial in
  Notty_unix.output_image img;
  [%expect {| ∂ |}]

let%expect_test "superscript" =
  let img = render_math (Superscript { base = Pi; superscript = E }) in
  Notty_unix.output_image img;
  [%expect {|
     e
    π
    |}]

let%expect_test "subscript" =
  let img = render_math (Subscript { base = Pi; subscript = E }) in
  Notty_unix.output_image img;
  [%expect {|
    π
     e
    |}]

let%expect_test "list - flat elements" =
  let img = render_math (List [ Partial; Pi; E ]) in
  Notty_unix.output_image img;
  [%expect {| ∂πe |}]

let%expect_test "list - non-flat elements superscript" =
  let img =
    render_math
      (List [ Pi; Superscript { base = Literal "x"; superscript = E } ])
  in
  Notty_unix.output_image img;
  [%expect {|
      e
    πx
    |}]

let%expect_test "list - non-flat elements subscript" =
  let img =
    render_math (List [ Pi; Subscript { base = Literal "x"; subscript = E } ])
  in
  Notty_unix.output_image img;
  [%expect {|
    πx
      e
    |}]

let%expect_test "list - non-flat elements mixture" =
  let img =
    render_math
      (List
         [
           Pi;
           Superscript { base = Literal "x"; superscript = E };
           Subscript { base = Literal "x"; subscript = E };
         ])
  in
  Notty_unix.output_image img;
  [%expect {|
      e
    πx x
        e
    |}]

let%expect_test "fraction" =
  let img =
    render_math
      (Frac (Literal "x", Superscript { base = Pi; superscript = Literal "2" }))
  in
  Notty_unix.output_image img;
  [%expect {|
     x
    ────
      2
     π
    |}]
