open! Core

module Variant = struct
  module Text_state = struct
    type t = { prompt : string; value : string }

    let make ~prompt () = { prompt; value = "" }
    let set_value t value = { t with value }
  end

  module Int_as_string = struct
    type t = Empty | Just_minus | Positive of string | Negative of string

    let make () = Empty

    let injest_char c t =
      match (t, c) with
      | Empty, '-' -> Just_minus
      | Empty, c when Char.is_digit c -> Positive (String.of_char c)
      | Just_minus, '-' -> Empty
      | Just_minus, c when Char.is_digit c -> Negative (String.of_char c)
      | Positive string, c when Char.is_digit c ->
          Positive (string ^ String.of_char c)
      | Negative string, c when Char.is_digit c ->
          Negative (string ^ String.of_char c)
      | _, _ -> t

    let injest_backspace = function
      | Empty -> Empty
      | Just_minus -> Empty
      | Positive string ->
          let new_string =
            if String.is_empty string then string
            else String.sub ~pos:0 ~len:(String.length string - 1) string
          in
          if String.is_empty new_string then Empty else Positive new_string
      | Negative string ->
          let new_string =
            if String.is_empty string then string
            else String.sub ~pos:0 ~len:(String.length string - 1) string
          in
          if String.is_empty new_string then Just_minus else Negative new_string

    let to_string = function
      | Empty -> ""
      | Just_minus -> "-"
      | Positive string -> string
      | Negative string -> [%string "-%{string}"]

    let to_int = function
      | Empty -> 0
      | Just_minus -> 0
      | Positive string -> Int.of_string string
      | Negative string -> -Int.of_string string
  end

  module Single_selection_state = struct
    type 'a t = {
      options : 'a list;
      option_to_string : 'a -> string;
      selected_index : int;
    }

    let make ~options ~option_to_string =
      { options; option_to_string; selected_index = 0 }

    let maximum_index { options; _ } = List.length options - 1

    let incr_selected_index t =
      { t with selected_index = min (t.selected_index + 1) (maximum_index t) }

    let decr_selected_index t =
      { t with selected_index = max (t.selected_index - 1) 0 }
  end

  module Multi_selection_state = struct
    type 'a t = {
      options : 'a list;
      option_to_string : 'a -> string;
      selected_option_indexes : Int.Set.t;
      hovered_index : int;
    }

    let make ~options ~option_to_string =
      {
        options;
        option_to_string;
        selected_option_indexes = Int.Set.empty;
        hovered_index = 0;
      }

    let maximum_index { options; _ } = List.length options - 1

    let incr_hovered_index t =
      { t with hovered_index = min (t.hovered_index + 1) (maximum_index t) }

    let decr_hovered_index t =
      { t with hovered_index = max (t.hovered_index - 1) 0 }

    let toggle_current_index
        ({
           options = _;
           option_to_string = _;
           selected_option_indexes;
           hovered_index;
         } as t) =
      if Set.mem selected_option_indexes hovered_index then
        {
          t with
          selected_option_indexes =
            Set.remove selected_option_indexes hovered_index;
        }
      else
        {
          t with
          selected_option_indexes =
            Set.add selected_option_indexes hovered_index;
        }
  end

  (** [('a, 'b) t] is a variant which uses type ['a] for state and resolves with
      a value of type ['b] *)
  type (_, _) t =
    | Any_key : (unit, unit) t
    | Text : (Text_state.t, string) t
    | Integer : (Int_as_string.t, int) t
    | Single_selection : ('a Single_selection_state.t, 'a) t
    | Multi_selection : ('a Multi_selection_state.t, 'a list) t

  let render : type a b. render_info:_ -> (a, b) t -> a -> Notty.image =
   fun ~render_info t state ->
    let open Notty.I in
    let boxed_to_screen_width =
      Notty_utils.boxed
        ~padding_control:
          (`To_min_boxed_size
             (Some (render_info.Render_info.screen_width, Right), None))
    in

    match t with
    | Any_key -> empty
    | Text ->
        string Theme.text_input_editable
          [%string "%{state.prompt}%{state.value}"]
        |> boxed_to_screen_width
    | Integer ->
        let as_string = Int_as_string.to_string state in
        string Theme.integer_input_editable [%string "> %{as_string}"]
        |> boxed_to_screen_width
    | Single_selection ->
        let { Single_selection_state.options; option_to_string; selected_index }
            =
          state
        in
        List.mapi options ~f:(fun index option ->
            let is_selected = index = selected_index in
            let attr =
              if is_selected then Theme.single_selection_input_option_selected
              else Theme.single_selection_input_option_not_selected
            in
            let text =
              (if is_selected then "> " else "  ") ^ option_to_string option
            in
            string attr text)
        |>
        (* Display the options starting at the bottom and growing upwards, as the index increases *)
        List.rev |> vcat
    | Multi_selection ->
        let {
          Multi_selection_state.options;
          option_to_string;
          selected_option_indexes;
          hovered_index;
        } =
          state
        in
        List.mapi options ~f:(fun index option ->
            let is_selected = Set.mem selected_option_indexes index in
            let is_hovered = index = hovered_index in
            let attr =
              if is_hovered then Theme.multi_selection_input_option_hovered
              else Theme.multi_selection_input_option_not_hovered
            in
            let text =
              (if is_selected then "[X]" else "[ ]") ^ option_to_string option
            in
            string attr text)
        |>
        (* Display the options starting at the bottom and growing upwards, as the index increases *)
        List.rev |> vcat

  let injest_char : type a b. (a, b) t -> a -> _ -> a =
   fun t state char ->
    match (t, char) with
    | Text, char ->
        Text_state.set_value state (state.value ^ String.of_char char)
    | Integer, char -> Int_as_string.injest_char char state
    | Multi_selection, ' ' -> Multi_selection_state.toggle_current_index state
    | (Any_key | Single_selection | Multi_selection), _ -> state

  let injest_backspace : type a b. (a, b) t -> a -> a =
   fun t state ->
    match t with
    | Any_key | Single_selection | Multi_selection -> state
    | Text ->
        let value = state.value in
        if String.is_empty value then state
        else
          Text_state.set_value state
            (String.sub ~pos:0 ~len:(String.length value - 1) value)
    | Integer -> Int_as_string.injest_backspace state

  let injest_arrow_key : type a b. (a, b) t -> a -> _ -> a =
   fun t state direction ->
    match t with
    | Any_key | Text | Integer ->
        (* TODO-someday: allow arrow keys to move the position being edited *)
        state
    | Single_selection -> (
        match direction with
        | `Left | `Right -> state
        | `Up -> Single_selection_state.incr_selected_index state
        | `Down -> Single_selection_state.decr_selected_index state)
    | Multi_selection -> (
        match direction with
        | `Left | `Right -> state
        | `Up -> Multi_selection_state.incr_hovered_index state
        | `Down -> Multi_selection_state.decr_hovered_index state)

  let to_resolvable_value : type a b. (a, b) t -> a -> b =
   fun t state ->
    match t with
    | Any_key -> ()
    | Text -> state.value
    | Integer -> Int_as_string.to_int state
    | Single_selection ->
        let {
          Single_selection_state.options;
          option_to_string = _;
          selected_index;
        } =
          state
        in
        List.nth_exn options selected_index
    | Multi_selection ->
        let {
          Multi_selection_state.options;
          option_to_string = _;
          selected_option_indexes;
          hovered_index = _;
        } =
          state
        in
        Set.to_list selected_option_indexes
        |> List.map ~f:(List.nth_exn options)
end

module Unpacked = struct
  type ('a, 'b) t = {
    variant : ('a, 'b) Variant.t;
    current_value : 'a;
    resolver : 'b Lwt.u;
  }
end

type t = Packed : ('a, 'b) Unpacked.t -> t

let make_any_key ~resolver () =
  Packed { variant = Any_key; current_value = (); resolver }

let make_text ~prompt ~resolver () =
  Packed
    {
      variant = Text;
      current_value = Variant.Text_state.make ~prompt ();
      resolver;
    }

let make_integer ~resolver () =
  Packed
    {
      variant = Integer;
      current_value = Variant.Int_as_string.make ();
      resolver;
    }

let make_single_selection ~resolver ~options ~option_to_string () =
  (if List.is_empty options then
     let options_as_strings = List.map options ~f:option_to_string in
     raise_s
       [%message
         "Options for single selection cannot be empty"
           (options_as_strings : string list)]);
  Packed
    {
      variant = Single_selection;
      current_value =
        Variant.Single_selection_state.make ~options ~option_to_string;
      resolver;
    }

let make_multi_selection ~resolver ~options ~option_to_string () =
  (if List.is_empty options then
     let options_as_strings = List.map options ~f:option_to_string in
     raise_s
       [%message
         "Options for multi selection cannot be empty"
           (options_as_strings : string list)]);
  Packed
    {
      variant = Multi_selection;
      current_value =
        Variant.Multi_selection_state.make ~options ~option_to_string;
      resolver;
    }

let render ~render_info (Packed { variant; current_value; resolver = _ }) =
  Variant.render ~render_info variant current_value

let injest_key_event (Packed ({ variant; current_value; resolver } as t))
    (key, _mods) =
  let set_up_resolver_wakeup_for_later resolver value () =
    Lwt.async (fun () ->
        let%lwt () =
          (* Using a pause means this will not be immediately scheduled *)
          Lwt.pause ()
        in
        Lwt.wakeup resolver value;
        Lwt.return ())
  in

  match (variant, key) with
  | Any_key, _ ->
      set_up_resolver_wakeup_for_later resolver () ();
      `Ready_to_be_destroyed
  | (Text | Integer | Single_selection | Multi_selection), `ASCII c ->
      let new_value = Variant.injest_char variant current_value c in
      `Updated_to (Packed { t with current_value = new_value })
  | (Text | Integer | Single_selection | Multi_selection), `Backspace ->
      let new_value = Variant.injest_backspace variant current_value in
      `Updated_to (Packed { t with current_value = new_value })
  | (Text | Integer | Single_selection | Multi_selection), `Arrow direction ->
      let new_value =
        Variant.injest_arrow_key variant current_value direction
      in
      `Updated_to (Packed { t with current_value = new_value })
  | (Text | Integer | Single_selection | Multi_selection), `Enter ->
      (* Set wakeup to be run once the current process yields *)
      set_up_resolver_wakeup_for_later resolver
        (Variant.to_resolvable_value variant current_value)
        ();
      `Ready_to_be_destroyed
  | (Text | Integer | Single_selection | Multi_selection), _ ->
      `Updated_to (Packed t)
