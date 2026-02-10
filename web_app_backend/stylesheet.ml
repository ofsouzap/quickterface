open! Core

module Style = struct
  module Entry = struct
    type t = { name : string; value : string }

    let to_css_string { name; value } = Printf.sprintf "%s: %s" name value
  end

  type t = Style of Entry.t list

  let to_css_string (Style entries) =
    String.concat ~sep:";" (List.map entries ~f:Entry.to_css_string)
end

module Selector_atom = struct
  type t = Body | Button | Input | Select | Class of Class.t
  [@@deriving enumerate]

  let to_css_string = function
    | Body -> "body"
    | Button -> "button"
    | Input -> "input"
    | Select -> "select"
    | Class class_ -> Printf.sprintf ".%s" (Class.to_prefixed_string class_)
end

module Selector = struct
  type t = { atom : Selector_atom.t; pseudo_class : string option }

  let of_atom atom = { atom; pseudo_class = None }

  let to_css_string { atom; pseudo_class } =
    Printf.sprintf "%s%s"
      (Selector_atom.to_css_string atom)
      (Option.value_map pseudo_class ~default:"" ~f:(fun pseudo_class ->
           Printf.sprintf ":%s" pseudo_class))
end

module Entry = struct
  type t = { selector : Selector.t; style : Style.t }

  let font_style_entries =
    Style.Entry.
      [
        { name = "font-size"; value = "16px" };
        {
          name = "font-family";
          value = "\"Fira Code\", Menlo, Consolas, monospace";
        };
      ]

  let body_style =
    Style.Style
      (Style.Entry.
         [
           { name = "background-color"; value = "#0b1d40ff" };
           { name = "width"; value = "100vw" };
           { name = "height"; value = "100vh" };
           { name = "max-width"; value = "100vw" };
           { name = "max-height"; value = "100vh" };
           { name = "margin"; value = "0" };
           { name = "padding-bottom"; value = "env(safe-area-inset-bottom)" };
           { name = "overflow-x"; value = "hidden" };
           { name = "box-sizing"; value = "border-box" };
           { name = "touch-action"; value = "manipulation" };
         ]
      @ font_style_entries)

  let button_style =
    Style.Style
      (Style.Entry.
         [
           { name = "min-height"; value = "50px" };
           { name = "margin"; value = "4px 0px" };
           { name = "border-width"; value = "0px" };
           { name = "border-radius"; value = "4px" };
           { name = "padding"; value = "8px 16px" };
           { name = "background-color"; value = "#2563eb" };
           { name = "cursor"; value = "pointer" };
         ]
      @ font_style_entries)

  let input_style =
    Style.Style
      (Style.Entry.
         [
           { name = "min-height"; value = "35px" };
           { name = "margin"; value = "4px 0px" };
           { name = "padding"; value = "2px 4px" };
           { name = "border-radius"; value = "4px" };
         ]
      @ font_style_entries)

  let select_style = input_style

  let class_style =
    let open Style.Entry in
    let log_item_style_items =
      [
        { name = "margin"; value = "4px" };
        { name = "border-radius"; value = "4px" };
        { name = "padding"; value = "2px 6px 2px 6px" };
        { name = "overflow-wrap"; value = "break-word" };
        { name = "word-break"; value = "break-word" };
      ]
    in
    function
    | Class.Main_container ->
        Style.Style
          [
            { name = "position"; value = "fixed" };
            { name = "inset"; value = "0" };
            { name = "width"; value = "100%" };
            { name = "height"; value = "100%" };
            { name = "max-width"; value = "100vw" };
            { name = "max-height"; value = "100vh" };
            { name = "display"; value = "flex" };
            { name = "flex-direction"; value = "column" };
          ]
    | Log_container ->
        Style
          [
            { name = "height"; value = "100vh" };
            { name = "max-width"; value = "100%" };
            { name = "display"; value = "flex" };
            { name = "flex-direction"; value = "column" };
            { name = "overflow-y"; value = "auto" };
            { name = "justify-content"; value = "flex-end" };
            { name = "color"; value = "#eee" };
            { name = "padding"; value = "8px" };
          ]
    | Text_prompt_label -> Style [ { name = "width"; value = "10px" } ]
    | Log_item ->
        Style
          (log_item_style_items
          @ [ { name = "background-color"; value = "#444" } ])
    | Input_container_form ->
        Style
          [
            { name = "display"; value = "flex" };
            { name = "flex-direction"; value = "row" };
            { name = "gap"; value = "8px" };
            { name = "align-items"; value = "center" };
          ]
    | Input_submit_button ->
        Style
          [
            { name = "flex"; value = "0 0 auto" };
            { name = "padding"; value = "8px 16px" };
            { name = "cursor"; value = "pointer" };
          ]
    | Input_multiselect_container ->
        Style
          [
            { name = "display"; value = "flex" };
            { name = "flex-direction"; value = "row" };
            { name = "gap"; value = "16px" };
          ]
    | Output_math -> Style [ { name = "padding"; value = "4px 0px" } ]
    | Progress_bar_item ->
        Style
          [
            { name = "width"; value = "100%" };
            { name = "display"; value = "flex" };
            { name = "flex-direction"; value = "row" };
            { name = "align-items"; value = "center" };
            { name = "gap"; value = "8px" };
          ]
    | Progress_bar_label ->
        Style
          [
            { name = "flex"; value = "20" };
            { name = "font-size"; value = "12px" };
          ]
    | Progress_bar_bar_container ->
        Style
          [
            { name = "flex"; value = "60" };
            { name = "width"; value = "100%" };
            { name = "height"; value = "14px" };
            { name = "border-radius"; value = "4px" };
            { name = "background-color"; value = "#222" };
          ]
    | Progress_bar_bar_fill_in_progress ->
        Style
          [
            { name = "width"; value = "0%" };
            { name = "height"; value = "100%" };
            { name = "border-radius"; value = "4px" };
            { name = "background-color"; value = "#2196f3" };
          ]
    | Progress_bar_bar_fill_completed ->
        Style
          [
            { name = "width"; value = "100%" };
            { name = "height"; value = "100%" };
            { name = "border-radius"; value = "4px" };
            { name = "background-color"; value = "#4caf50" };
          ]
    | Progress_bar_progress_label -> Style [ { name = "flex"; value = "20" } ]

  let selector_atom_style = function
    | Selector_atom.Body -> body_style
    | Button -> button_style
    | Input -> input_style
    | Select -> select_style
    | Class c -> class_style c

  let of_selector_atom selector_atom =
    {
      selector = Selector.of_atom selector_atom;
      style = selector_atom_style selector_atom;
    }

  let to_css_string { selector; style } =
    [%string
      {|%{Selector.to_css_string selector} {
        %{Style.to_css_string style}
        }|}]

  let custom_entries =
    List.map
      ~f:(fun (selector, style) -> { selector; style })
      [
        ( Selector.{ atom = Button; pseudo_class = Some "disabled" },
          Style.Style
            [ Style.Entry.{ name = "background-color"; value = "#888" } ] );
      ]
end

let css_string =
  let atom_entries =
    List.map
      ~f:(fun selector -> Entry.of_selector_atom selector)
      Selector_atom.all
  in
  let custom_entries = Entry.custom_entries in
  let all_entries = atom_entries @ custom_entries in
  List.map all_entries ~f:Entry.to_css_string |> String.concat ~sep:"\n\n"
