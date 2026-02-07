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
  module I = Notty.I

  type image = Notty.image

  module Horizontally_aligned_image : sig
    type t

    val make : ?top:image -> ?center:image -> ?bottom:image -> unit -> t
    val make_from_single_image : image -> center_line_index:int -> unit -> t
    val to_notty : t -> image
    val hcat : t list -> t
  end = struct
    open I

    type t = { top : image; center : image; bottom : image }
    (** The bottom of top is aligned with the top of center, and the top of
        bottom is aligned with the bottom of center.

        The images are horizontally left-aligned. *)

    let make ?(top = empty) ?(center = void 1 1) ?(bottom = empty) () =
      if not (height center = 1) then
        raise_s [%message "Center image must be single row"];

      { top; center; bottom }

    let make_from_single_image img ~center_line_index () =
      if not (center_line_index < height img) then
        raise_s
          [%message
            "Center line index must be less than image height"
              (center_line_index : int)];
      if not (center_line_index >= 0) then
        raise_s
          [%message
            "Center line index must be non-negative" (center_line_index : int)];

      let top_rows = center_line_index in
      let bottom_rows = height img - top_rows - 1 in

      let top = crop ~b:(bottom_rows + 1) img in
      let center = crop ~t:top_rows ~b:bottom_rows img in
      let bottom = crop ~t:(top_rows + 1) img in

      { top; center; bottom }

    let apply_left_alignment_to_make_parts_equal_width { top; center; bottom } =
      let open I in
      let max_width = max (width top) (max (width center) (width bottom)) in
      let padder img = pad ~r:(max_width - width img) img in
      { top = padder top; center = padder center; bottom = padder bottom }

    let to_notty { top; center; bottom } = top <-> center <-> bottom

    let ( <|> ) img_x img_y =
      let img_x = apply_left_alignment_to_make_parts_equal_width img_x in
      let img_y = apply_left_alignment_to_make_parts_equal_width img_y in
      {
        top = img_x.top <|> img_y.top;
        center = img_x.center <|> img_y.center;
        bottom = img_x.bottom <|> img_y.bottom;
      }

    let hcat = function
      | [] -> make ()
      | h :: ts -> List.fold ts ~init:h ~f:( <|> )
  end

  (* Note to self:
     - Need horizontally-aligned image for list so that things are aligned with their main line
     - Can't use horizontally-aligned image for brackets as bracketed things will be taller than one line
     - Maybe a new implementation of horizontally-aligned image that doesn't require single-row center,
         but instead just can vertically align things
   *)

  let render_math ~render_info:_ attr math =
    let open I in
    let open Horizontally_aligned_image in
    let rec render_math =
      let plain_string s = make ~center:(string attr s) () in
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
      | Quickterface.Math.Literal s -> plain_string s
      | Infinity -> plain_string "∞"
      | Pi -> plain_string "π"
      | E -> plain_string "e"
      | Plus -> plain_string "+"
      | Star -> plain_string "*"
      | C_dot -> plain_string "·"
      | Superscript { base; superscript } ->
          super_sub_script_helper ~base ~script:superscript ~side:`Superscript
      | Subscript { base; subscript } ->
          super_sub_script_helper ~base ~script:subscript ~side:`Subscript
      | Exp -> plain_string "exp"
      | Ln -> plain_string "ln"
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

          make ~top:num_img ~center:line_img ~bottom:denom_img ()
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
      | Integral { lower = _; upper = _ } ->
          failwith "TODO - lower and upper and integral symbol"
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
