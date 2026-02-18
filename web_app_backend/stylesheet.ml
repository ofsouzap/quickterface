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
           { name = "min-height"; value = "40px" };
           { name = "margin"; value = "4px 0px" };
           { name = "border-width"; value = "1px" };
           { name = "border-radius"; value = "0.375rem" };
           { name = "padding"; value = "0.5rem 1rem" };
           { name = "cursor"; value = "pointer" };
           { name = "transition"; value = "all 0.15s ease-in-out" };
         ]
      @ font_style_entries)

  let input_style =
    Style.Style
      (Style.Entry.
         [
           { name = "min-height"; value = "38px" };
           { name = "margin"; value = "4px 0px" };
           { name = "padding"; value = "0.375rem 0.75rem" };
           { name = "border-radius"; value = "0.375rem" };
           { name = "border"; value = "1px solid #ced4da" };
           { name = "transition"; value = "border-color 0.15s ease-in-out" };
         ]
      @ font_style_entries)

  let select_style = input_style

  let class_style =
    let open Style.Entry in
    let log_item_style_items =
      [
        { name = "margin"; value = "0.5rem 0" };
        { name = "border-radius"; value = "0.375rem" };
        { name = "padding"; value = "0.75rem 1rem" };
        { name = "overflow-wrap"; value = "break-word" };
        { name = "word-break"; value = "break-word" };
        { name = "box-shadow"; value = "0 1px 3px rgba(0,0,0,0.12)" };
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
            { name = "background"; value = "linear-gradient(135deg, #667eea 0%, #764ba2 100%)" };
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
            { name = "color"; value = "#212529" };
            { name = "padding"; value = "1rem" };
          ]
    | Text_prompt_label -> Style [ { name = "width"; value = "10px" } ]
    | Log_item ->
        Style
          (log_item_style_items
          @ [
              { name = "background-color"; value = "rgba(255, 255, 255, 0.95)" };
              { name = "backdrop-filter"; value = "blur(10px)" };
            ])
    | Input_container_form ->
        Style
          [
            { name = "display"; value = "flex" };
            { name = "flex-direction"; value = "row" };
            { name = "gap"; value = "0.5rem" };
            { name = "align-items"; value = "center" };
            { name = "background-color"; value = "rgba(255, 255, 255, 0.95)" };
            { name = "padding"; value = "0.75rem" };
            { name = "border-radius"; value = "0.375rem" };
            { name = "backdrop-filter"; value = "blur(10px)" };
          ]
    | Input_submit_button ->
        Style
          [
            { name = "flex"; value = "0 0 auto" };
            { name = "padding"; value = "0.5rem 1rem" };
            { name = "cursor"; value = "pointer" };
            { name = "background-color"; value = "#0d6efd" };
            { name = "color"; value = "#fff" };
            { name = "border"; value = "none" };
            { name = "border-radius"; value = "0.375rem" };
            { name = "transition"; value = "background-color 0.15s ease-in-out" };
          ]
    | Input_multiselect_container ->
        Style
          [
            { name = "display"; value = "flex" };
            { name = "flex-direction"; value = "row" };
            { name = "gap"; value = "1rem" };
          ]
    | Output_math -> Style [ { name = "padding"; value = "0.5rem 0" } ]
    | Progress_bar_item ->
        Style
          [
            { name = "width"; value = "100%" };
            { name = "display"; value = "flex" };
            { name = "flex-direction"; value = "row" };
            { name = "align-items"; value = "center" };
            { name = "gap"; value = "0.75rem" };
          ]
    | Progress_bar_label ->
        Style
          [
            { name = "flex"; value = "20" };
            { name = "font-size"; value = "0.875rem" };
            { name = "font-weight"; value = "500" };
          ]
    | Progress_bar_bar_container ->
        Style
          [
            { name = "flex"; value = "60" };
            { name = "width"; value = "100%" };
            { name = "height"; value = "16px" };
            { name = "border-radius"; value = "0.5rem" };
            { name = "background-color"; value = "#e9ecef" };
            { name = "overflow"; value = "hidden" };
          ]
    | Progress_bar_bar_fill_in_progress ->
        Style
          [
            { name = "width"; value = "0%" };
            { name = "height"; value = "100%" };
            { name = "border-radius"; value = "0.5rem" };
            { name = "background-color"; value = "#0d6efd" };
            { name = "transition"; value = "width 0.3s ease-in-out" };
          ]
    | Progress_bar_bar_fill_completed ->
        Style
          [
            { name = "width"; value = "100%" };
            { name = "height"; value = "100%" };
            { name = "border-radius"; value = "0.5rem" };
            { name = "background-color"; value = "#198754" };
            { name = "transition"; value = "width 0.3s ease-in-out" };
          ]
    | Progress_bar_progress_label ->
        Style
          [
            { name = "flex"; value = "20" };
            { name = "font-size"; value = "0.875rem" };
            { name = "font-weight"; value = "500" };
            { name = "text-align"; value = "right" };
          ]

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
            [
              Style.Entry.{ name = "background-color"; value = "#6c757d" };
              { name = "opacity"; value = "0.65" };
              { name = "cursor"; value = "not-allowed" };
            ] );
        ( Selector.{ atom = Button; pseudo_class = Some "hover" },
          Style.Style
            [ Style.Entry.{ name = "opacity"; value = "0.9" } ] );
        ( Selector.{ atom = Input; pseudo_class = Some "focus" },
          Style.Style
            [
              Style.Entry.
                { name = "border-color"; value = "#86b7fe" };
              { name = "outline"; value = "0" };
              {
                name = "box-shadow";
                value = "0 0 0 0.25rem rgba(13, 110, 253, 0.25)";
              };
            ] );
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
