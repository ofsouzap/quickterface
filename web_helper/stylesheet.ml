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
  type t = Body | Class of Class.t [@@deriving enumerate]

  let to_css_string = function
    | Body -> "body"
    | Class class_ -> Printf.sprintf ".%s" (Class.to_prefixed_string class_)
end

module Entry = struct
  type t = { selector : Selector.t; style : Style.t }

  let body_style =
    Style.Style
      Style.Entry.
        [
          { name = "background-color"; value = "#0b1d40ff" };
          { name = "width"; value = "100%" };
          { name = "height"; value = "100%" };
          { name = "margin"; value = "0" };
        ]

  let class_style =
    let open Style.Entry in
    function
    | Class.Main_container ->
        Style.Style
          [
            { name = "position"; value = "fixed" };
            { name = "top"; value = "0" };
            { name = "bottom"; value = "0" };
            { name = "left"; value = "0" };
            { name = "right"; value = "0" };
            { name = "display"; value = "flex" };
            { name = "flex-direction"; value = "column" };
            { name = "height"; value = "100%" };
            { name = "width"; value = "100%" };
          ]
    | Log_container ->
        Style
          [
            { name = "height"; value = "100%" };
            { name = "display"; value = "flex" };
            { name = "flex-direction"; value = "column" };
            { name = "overflow-y"; value = "auto" };
            { name = "color"; value = "#eee" };
            { name = "padding"; value = "8px" };
            { name = "font-size"; value = "14px" };
            {
              name = "font-family";
              value = "\"Fira Code\", Menlo, Consolas, monospace";
            };
          ]
    | Log_spacer -> Style [ { name = "flex-grow"; value = "1" } ]
    | Log_item -> Style [ { name = "margin"; value = "1px 1px 1px 1px" } ]
    | Input_text -> Style [ { name = "min-height"; value = "100px" } ]

  let selector_style = function
    | Selector.Body -> body_style
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
