open! Core
open Notty.A

let title_background = bg black
let title_text = title_background ++ fg lightgreen ++ st bold ++ st underline
let log_item_border = fg lightblack
let text_output_default_color = fg white

let text_output_from_options { Quickterface.Output_text_options.color } =
  match color with
  | `Default -> text_output_default_color
  | `Custom color ->
      fg
        (let r, g, b = Quickterface.Color.to_rgb color in
         rgb_888 ~r ~g ~b)

let math_output_from_options = text_output_from_options
let text_input_editable = fg white ++ st italic ++ st bold
let text_input_frozen = fg white ++ st italic
let integer_input_editable = text_input_editable
let single_selection_input_option_not_selected = fg white ++ st italic

let single_selection_input_option_selected =
  single_selection_input_option_not_selected ++ bg yellow ++ st bold

let multi_selection_input_option_not_hovered =
  single_selection_input_option_not_selected

let multi_selection_input_option_hovered =
  single_selection_input_option_selected

let loading_bar_title = fg white ++ st bold
let loading_bar_text = fg white
let loading_bar_bar_cells = fg white ++ bg lightblue
let loading_bar_bar_edges = loading_bar_bar_cells
