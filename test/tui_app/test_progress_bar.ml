open! Core
open Quickterface_tui_app

let bar ?label current_value maximum_value =
  Progress_bar.make ~config:{ label; maximum_value } ~current_value ()

let print ?(screen_height = 20) ?(screen_width = 30) bar =
  Progress_bar.render ~render_info:{ screen_height; screen_width } bar
  |> Notty_unix.output_image

let%expect_test "not enough space for bar" =
  try print ~screen_width:10 (bar 0 8)
  with exn ->
    print_s [%message (exn : exn)];
    [%expect
      {|
      (exn
       ("Not enough room to render progress bar"
        (render_info.Render_info.screen_width 10)))
      |}]

let%expect_test "single cell 0/8" =
  print ~screen_width:17 (bar 0 8);
  [%expect {| [ ] 0/8 (0.0%) |}]

let%expect_test "single cell 1/8" =
  print ~screen_width:18 (bar 1 8);
  [%expect {| [▏] 1/8 (12.5%) |}]

let%expect_test "single cell 2/8" =
  print ~screen_width:18 (bar 2 8);
  [%expect {| [▎] 2/8 (25.0%) |}]

let%expect_test "single cell 3/8" =
  print ~screen_width:18 (bar 3 8);
  [%expect {| [▍] 3/8 (37.5%) |}]

let%expect_test "single cell 4/8" =
  print ~screen_width:18 (bar 4 8);
  [%expect {| [▋] 4/8 (50.0%) |}]

let%expect_test "single cell 5/8" =
  print ~screen_width:18 (bar 5 8);
  [%expect {| [▊] 5/8 (62.5%) |}]

let%expect_test "single cell 6/8" =
  print ~screen_width:18 (bar 6 8);
  [%expect {| [▉] 6/8 (75.0%) |}]

let%expect_test "single cell 7/8" =
  print ~screen_width:18 (bar 7 8);
  [%expect {| [█] 7/8 (87.5%) |}]

let%expect_test "single cell 8/8" =
  print ~screen_width:19 (bar 8 8);
  [%expect {| [█] 8/8 (100.0%) |}]

let%expect_test "bar 0/8" =
  print (bar 0 8);
  [%expect {| [              ] 0/8 (0.0%) |}]

let%expect_test "bar 1/8" =
  print (bar 1 8);
  [%expect {| [█▊           ] 1/8 (12.5%) |}]

let%expect_test "bar 2/8" =
  print (bar 2 8);
  [%expect {| [███▎         ] 2/8 (25.0%) |}]

let%expect_test "bar 3/8" =
  print (bar 3 8);
  [%expect {| [█████        ] 3/8 (37.5%) |}]

let%expect_test "bar 4/8" =
  print (bar 4 8);
  [%expect {| [██████▋      ] 4/8 (50.0%) |}]

let%expect_test "bar 5/8" =
  print (bar 5 8);
  [%expect {| [████████▏    ] 5/8 (62.5%) |}]

let%expect_test "bar 6/8" =
  print (bar 6 8);
  [%expect {| [█████████▉   ] 6/8 (75.0%) |}]

let%expect_test "bar 7/8" =
  print (bar 7 8);
  [%expect {| [███████████▍ ] 7/8 (87.5%) |}]

let%expect_test "bar 8/8" =
  print (bar 8 8);
  [%expect {| [████████████] 8/8 (100.0%) |}]

let%expect_test "bar with label" =
  print (bar ~label:"Loading" 3 8);
  [%expect {|
    Loading
    [█████        ] 3/8 (37.5%)
    |}]

let%expect_test "bar 1/1 edge case" =
  print (bar 1 1);
  [%expect {| [████████████] 1/1 (100.0%) |}]

let%expect_test "bar 50/100" =
  print (bar 50 100);
  [%expect {| [█████     ] 50/100 (50.0%) |}]

let%expect_test "bar 0/100" =
  print (bar 0 100);
  [%expect {| [            ] 0/100 (0.0%) |}]
