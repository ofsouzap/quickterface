open! Core

type t =
  | Output_text of string
  | Output_math of Quickterface.Math.t
  | Input_text of string

let output_text ?options:_ text =
  (* TODO-soon - don't need to use options as I intend to change this system very soon *)
  Output_text text

let output_math ?options:_ text = Output_math text
let input_text text = Input_text text

let attr = function
  | Output_text _ -> Theme.text_output
  | Output_math _ -> Theme.math_output
  | Input_text _ -> Theme.text_input_frozen

module Math_renderer = struct
  let render_math ~render_info:_ attr math =
    let open Notty.I in
    let rec render_math =
      let plain_string s = string attr s in
      function
      | Quickterface.Math.Literal s -> plain_string s
      | Infinity -> plain_string "∞"
      | Pi -> plain_string "π"
      | E -> plain_string "e"
      | Plus -> plain_string "+"
      | Star -> plain_string "*"
      | C_dot -> plain_string "·"
      | Superscript _inner -> failwith "TODO"
      | Subscript _inner -> failwith "TODO"
      | Exp -> plain_string "exp"
      | Ln -> plain_string "ln"
      | List elements ->
          let element_imgs = List.map elements ~f:render_math in
          hcat (Notty_utils.align_vert_center element_imgs)
      | Frac (num, denom) ->
          let num_img = render_math num in
          let denom_img = render_math denom in

          let max_width = max (width num_img) (width denom_img) in
          let line_img =
            uchar attr Notty_utils.uchar_box_drawing_light_horizontal max_width
              1
          in

          num_img <-> line_img <-> denom_img
      | Bracketed inner ->
          let inner_img = render_math inner in
          let bracket_height = height inner_img in

          let make_bracket_img ~single_line ~top ~mid ~bottom =
            if bracket_height = 1 then plain_string single_line
            else
              uchar attr top 1 1
              <-> uchar attr mid 1 (bracket_height - 2)
              <-> uchar attr bottom 1 1
          in
          let left_bracket_img =
            make_bracket_img ~single_line:"("
              ~top:Notty_utils.uchar_paren_drawing_light_top_left
              ~mid:Notty_utils.uchar_paren_drawing_light_mid_left
              ~bottom:Notty_utils.uchar_paren_drawing_light_bottom_left
          in
          let right_bracket_img =
            make_bracket_img ~single_line:")"
              ~top:Notty_utils.uchar_paren_drawing_light_top_right
              ~mid:Notty_utils.uchar_paren_drawing_light_mid_right
              ~bottom:Notty_utils.uchar_paren_drawing_light_bottom_right
          in

          left_bracket_img <|> inner_img <|> right_bracket_img
      | Partial -> plain_string "∂"
      | Integral { lower = _; upper = _ } ->
          failwith "TODO - lower and upper and integral symbol"
    in
    render_math math
end

let render_math = Math_renderer.render_math

let render ~render_info t =
  let open Notty.I in
  let t_attr = attr t in
  (match t with
    | Output_text text -> string t_attr text
    | Output_math math -> render_math ~render_info t_attr math
    | Input_text text -> string t_attr [%string "> %{text}"])
  |> Notty_utils.boxed
       ~padding_control:
         (`To_min_boxed_size
            (Some (render_info.Render_info.screen_width, Right), None))

module For_testing = struct
  let render_math = render_math
end
