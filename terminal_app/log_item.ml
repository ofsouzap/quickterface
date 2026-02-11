open! Core

type t =
  | Output_text of {
      text : string;
      options : Quickterface.Output_text_options.t;
    }
  | Output_math of {
      math : Quickterface.Math.t;
      options : Quickterface.Output_text_options.t;
    }
  | Input_text of string

let output_text ?(options = Quickterface.Output_text_options.default) text =
  Output_text { text; options }

let output_math ?(options = Quickterface.Output_text_options.default) math =
  Output_math { math; options }

let input_text text = Input_text text

let attr = function
  | Output_text { options; _ } -> Theme.text_output_from_options options
  | Output_math { options; _ } -> Theme.math_output_from_options options
  | Input_text _ -> Theme.text_input_frozen

module Math_renderer = struct
  module I = Notty.I

  type image = Notty.image

  module Horizontally_aligned_image : sig
    type t

    val make_from_single_image : image -> center_line_index:int -> unit -> t

    val make_from_parts :
      ?top:image -> ?center:image -> ?bottom:image -> unit -> t

    val height : t -> int
    val to_notty : t -> image
    val ( <|> ) : t -> t -> t
    val hcat : t list -> t
  end = struct
    open I

    type t = { image : image; center_line_index : int }

    let make ~image ~center_line_index =
      if not (center_line_index < height image) then
        raise_s
          [%message
            "Center line index must be less than image height"
              (center_line_index : int)];
      if not (center_line_index >= 0) then
        raise_s
          [%message
            "Center line index must be non-negative" (center_line_index : int)];

      { image; center_line_index }

    let left_align_parts top center bottom =
      let max_width = max (width top) (max (width center) (width bottom)) in
      let padder img = pad ~r:(max_width - width img) img in
      (padder top, padder center, padder bottom)

    let make_from_single_image image ~center_line_index () =
      make ~image ~center_line_index

    let make_from_parts ?(top = empty) ?(center = void 1 1) ?(bottom = empty) ()
        =
      if not (height center = 1) then
        raise_s [%message "Center image must be single row"];

      let padded_top, padded_center, padded_bottom =
        left_align_parts top center bottom
      in

      make
        ~image:(padded_top <-> padded_center <-> padded_bottom)
        ~center_line_index:(height padded_top)

    let height { image; center_line_index = _ } = height image

    let to_parts { image; center_line_index } =
      let top_height = center_line_index in
      let bottom_height = I.height image - center_line_index - 1 in

      let top = I.crop ~b:(1 + bottom_height) image in
      let center = I.crop ~t:top_height ~b:bottom_height image in
      let bottom = I.crop ~t:(1 + top_height) image in

      (top, center, bottom)

    let to_notty { image; center_line_index = _ } = image

    let ( <|> ) img_x img_y =
      let img_x_top, img_x_center, img_x_bottom = to_parts img_x in
      let img_y_top, img_y_center, img_y_bottom = to_parts img_y in

      make_from_parts ~top:(img_x_top <|> img_y_top)
        ~center:(img_x_center <|> img_y_center)
        ~bottom:(img_x_bottom <|> img_y_bottom)
        ()

    let hcat = function
      | [] -> make_from_parts ()
      | h :: ts -> List.fold ts ~init:h ~f:( <|> )
  end

  let render_math ~render_info:_ attr math =
    let open I in
    let open Horizontally_aligned_image in
    let rec render_math =
      let plain_string s =
        make_from_single_image (string attr s) ~center_line_index:0 ()
      in
      let super_sub_script_helper ~base ~script ~side =
        let base_img = render_math base |> to_notty in
        let script_img = render_math script |> to_notty in

        let script_img_height = I.height script_img in
        let base_img_height = I.height base_img in

        let whole_image =
          match side with
          | `Superscript ->
              I.(pad ~l:(I.width base_img) script_img <-> base_img)
          | `Subscript -> I.(base_img <-> pad ~l:(I.width base_img) script_img)
        in

        let center_line_index =
          match side with
          | `Superscript -> script_img_height + (base_img_height / 2)
          | `Subscript -> base_img_height / 2
        in

        make_from_single_image whole_image ~center_line_index ()
      in
      function
      | Quickterface.Math.Char c -> plain_string (Char.to_string c)
      | Literal s -> plain_string s
      | Infinity -> plain_string "∞"
      | Pi -> plain_string "π"
      | E -> plain_string "e"
      | Equals -> plain_string "="
      | Plus -> plain_string "+"
      | Minus -> plain_string "-"
      | Star -> plain_string "*"
      | C_dot -> plain_string "·"
      | Times -> plain_string "×"
      | Divide -> plain_string "÷"
      | Plus_minus -> plain_string "±"
      | Superscript { base; superscript } ->
          super_sub_script_helper ~base ~script:superscript ~side:`Superscript
      | Subscript { base; subscript } ->
          super_sub_script_helper ~base ~script:subscript ~side:`Subscript
      | Exp -> plain_string "exp"
      | Ln -> plain_string "ln"
      | Sin -> plain_string "sin"
      | Cos -> plain_string "cos"
      | List elements ->
          let element_imgs = List.map elements ~f:render_math in
          hcat element_imgs
      | Frac (num, denom) ->
          let num_img = render_math num |> to_notty |> pad ~l:1 ~r:1 in
          let denom_img = render_math denom |> to_notty |> pad ~l:1 ~r:1 in

          let max_width = max (I.width num_img) (I.width denom_img) in
          let line_img =
            uchar attr Notty_utils.uchar_box_drawing_light_horizontal max_width
              1
          in

          make_from_parts ~top:num_img ~center:line_img ~bottom:denom_img ()
      | Bracketed inner ->
          let inner_img = render_math inner |> to_notty in
          let bracket_height = I.height inner_img in

          let make_bracket_img ~single_line ~top ~mid ~bottom =
            if bracket_height = 1 then string attr single_line
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

          let notty_image =
            I.(left_bracket_img <|> inner_img <|> right_bracket_img)
          in

          make_from_single_image notty_image
            ~center_line_index:(bracket_height / 2) ()
      | Partial -> plain_string "∂"
      | Less_than -> plain_string "<"
      | Less_than_or_equal_to -> plain_string "≤"
      | Greater_than -> plain_string ">"
      | Greater_than_or_equal_to -> plain_string "≥"
      | Not_equal -> plain_string "≠"
      | Approximately_equals -> plain_string "≈"
      | Equivalent_to -> plain_string "≡"
      | Integral { lower; upper; body } ->
          let lower_img_notty_opt =
            Option.(lower >>| render_math >>| to_notty)
          in
          let upper_img_notty_opt =
            Option.(upper >>| render_math >>| to_notty)
          in
          let body_img = render_math body in

          let body_height = height body_img in

          let integral_symbol_img =
            if body_height <= 1 then plain_string "∫"
            else
              let notty_image =
                uchar attr Notty_utils.uchar_paren_top_half_integral 1 1
                <-> uchar attr Notty_utils.uchar_paren_integral_extender 1
                      (body_height - 2)
                <-> uchar attr Notty_utils.uchar_paren_bottom_half_integral 1 1
              in
              make_from_single_image notty_image
                ~center_line_index:(body_height / 2) ()
          in

          let limits_image =
            let upper = Option.value ~default:I.empty upper_img_notty_opt in
            let lower = Option.value ~default:I.empty lower_img_notty_opt in
            let notty_image = I.(upper <-> void 0 1 <-> lower) in

            make_from_single_image notty_image
              ~center_line_index:(I.height upper) ()
          in

          integral_symbol_img <|> limits_image <|> body_img
    in
    render_math math
end

let render_math ~render_info attr img =
  Math_renderer.(
    Horizontally_aligned_image.to_notty (render_math ~render_info attr img))

let render ~render_info t =
  let open Notty.I in
  let t_attr = attr t in
  (match t with
    | Output_text { text; _ } -> string t_attr text
    | Output_math { math; _ } -> render_math ~render_info t_attr math
    | Input_text text -> string t_attr [%string "> %{text}"])
  |> Notty_utils.boxed
       ~padding_control:
         (`To_min_boxed_size
            (Some (render_info.Render_info.screen_width, Right), None))

module For_testing = struct
  let render_math = render_math
end
