open! Core

module Variant = struct
  type _ t = Any_key : unit t | Text : string t

  let render : type a. a t -> a -> Notty.image =
   fun t value ->
    let open Notty.I in
    match t with
    | Any_key -> empty
    | Text -> string Theme.text_input_editable value

  let injest_char : type a. a t -> a -> _ -> a Lwt.t =
   fun t value char ->
    match t with
    | Any_key -> Lwt.return ()
    | Text -> Lwt.return (value ^ String.of_char char)

  let injest_backspace : type a. a t -> a -> a Lwt.t =
   fun t value ->
    match t with
    | Any_key -> Lwt.return ()
    | Text ->
        Lwt.return
          (if String.is_empty value then value
           else String.sub ~pos:0 ~len:(String.length value - 1) value)
end

module Unpacked = struct
  type 'a t = {
    variant : 'a Variant.t;
    current_value : 'a;
    resolver : 'a Lwt.u;
  }
end

type t = Packed : 'a Unpacked.t -> t

let make_any_key ~resolver () =
  Packed { variant = Any_key; current_value = (); resolver }

let make_text ~resolver () =
  Packed { variant = Text; current_value = ""; resolver }

let render ~render_info:_ (Packed { variant; current_value; resolver = _ }) =
  Variant.render variant current_value

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
  | Text, `ASCII c ->
      let%lwt new_value = Variant.injest_char variant current_value c in
      Lwt.return (`Updated_to (Packed { t with current_value = new_value }))
  | Text, `Backspace ->
      let%lwt new_value = Variant.injest_backspace variant current_value in
      Lwt.return (`Updated_to (Packed { t with current_value = new_value }))
  | Text, `Enter ->
      (* Set wakeup to be run once the current process yields *)
      set_up_resolver_wakeup_for_later resolver current_value ();
      Lwt.return `Ready_to_be_destroyed
  | Text, _ -> Lwt.return (`Updated_to (Packed t))
