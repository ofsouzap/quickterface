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

module Selector = struct
  type t = Body | Button | Input | Class of Class.t [@@deriving enumerate]

  (* TODO - allow for pseudo-classes, so that we can do things like customize the button's disabled styling *)

  let to_css_string = function
    | Body -> "body"
    | Button -> "button"
    | Input -> "input"
    | Class class_ -> Printf.sprintf ".%s" (Class.to_prefixed_string class_)
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
      Style.Entry.
        [
          { name = "min-height"; value = "50px" };
          { name = "margin"; value = "4px 0px" };
          { name = "border-width"; value = "0px" };
          { name = "border-radius"; value = "4px" };
          { name = "padding"; value = "8px 16px" };
          { name = "background-color"; value = "#2563eb" };
          { name = "cursor"; value = "pointer" };
        ]

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

  let class_style =
    let open Style.Entry in
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
          [
            { name = "margin"; value = "4px" };
            { name = "border-radius"; value = "4px" };
            { name = "padding"; value = "2px 6px 2px 6px" };
            { name = "background-color"; value = "#444" };
            { name = "overflow-wrap"; value = "break-word" };
            { name = "word-break"; value = "break-word" };
          ]
    | Input_text_container_form ->
        Style
          [
            { name = "display"; value = "flex" };
            { name = "flex-direction"; value = "row" };
            { name = "gap"; value = "8px" };
            { name = "align-items"; value = "center" };
          ]
    | Input_text_field -> Style [ { name = "flex"; value = "1" } ]
    | Input_text_submit_button ->
        Style
          [
            { name = "flex"; value = "0 0 auto" };
            { name = "padding"; value = "8px 16px" };
            { name = "cursor"; value = "pointer" };
          ]

  let selector_style = function
    | Selector.Body -> body_style
    | Selector.Button -> button_style
    | Selector.Input -> input_style
    | Selector.Class c -> class_style c

  let of_selector selector = { selector; style = selector_style selector }

  let to_css_string { selector; style } =
    [%string
      {|%{Selector.to_css_string selector} {
        %{Style.to_css_string style}
        }|}]
end

let css_string =
  List.map
    ~f:(fun selector -> Entry.to_css_string (Entry.of_selector selector))
    Selector.all
  |> String.concat ~sep:"\n\n"
