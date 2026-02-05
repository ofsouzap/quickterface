open! Core

module Variant = struct
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

  type (_, _) t =
    | Any_key : (unit, unit) t
    | Text : (string, string) t
    | Integer : (Int_as_string.t, int) t

  let render : type a b. render_info:_ -> (a, b) t -> a -> Notty.image =
   fun ~render_info t value ->
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
        string Theme.text_input_editable [%string "> %{value}"]
        |> boxed_to_screen_width
    | Integer ->
        let as_string = Int_as_string.to_string value in
        string Theme.integer_input_editable [%string "> %{as_string}"]
        |> boxed_to_screen_width

  let injest_char : type a b. (a, b) t -> a -> _ -> a Lwt.t =
   fun t value char ->
    match t with
    | Any_key -> Lwt.return ()
    | Text -> Lwt.return (value ^ String.of_char char)
    | Integer -> Lwt.return (Int_as_string.injest_char char value)

  let injest_backspace : type a b. (a, b) t -> a -> a Lwt.t =
   fun t value ->
    match t with
    | Any_key -> Lwt.return ()
    | Text ->
        Lwt.return
          (if String.is_empty value then value
           else String.sub ~pos:0 ~len:(String.length value - 1) value)
    | Integer -> Lwt.return (Int_as_string.injest_backspace value)

  let to_resolvable_value : type a b. (a, b) t -> a -> b =
   fun t value ->
    match t with
    | Any_key -> ()
    | Text -> value
    | Integer -> Int_as_string.to_int value
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

let make_text ~resolver () =
  Packed { variant = Text; current_value = ""; resolver }

let make_integer ~resolver () =
  Packed
    {
      variant = Integer;
      current_value = Variant.Int_as_string.make ();
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
      Lwt.return `Ready_to_be_destroyed
  | (Text | Integer), `ASCII c ->
      let%lwt new_value = Variant.injest_char variant current_value c in
      Lwt.return (`Updated_to (Packed { t with current_value = new_value }))
  | (Text | Integer), `Backspace ->
      let%lwt new_value = Variant.injest_backspace variant current_value in
      Lwt.return (`Updated_to (Packed { t with current_value = new_value }))
  | (Text | Integer), `Enter ->
      (* Set wakeup to be run once the current process yields *)
      set_up_resolver_wakeup_for_later resolver
        (Variant.to_resolvable_value variant current_value)
        ();
      Lwt.return `Ready_to_be_destroyed
  | (Text | Integer), _ -> Lwt.return (`Updated_to (Packed t))
