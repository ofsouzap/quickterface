open! Core

module Variant = struct
  type _ t = Text : string t

  let attr_text =
    let open Notty.A in
    fg white ++ bg black

  let render : type a. a t -> a -> Notty.image =
   fun t value ->
    let open Notty.I in
    match t with Text -> string attr_text value

  let injest_char : type a. a t -> a -> _ -> a Lwt.t =
   fun t value char ->
    match t with Text -> Lwt.return (value ^ String.of_char char)
end

module Unpacked = struct
  type 'a t = {
    variant : 'a Variant.t;
    current_value : 'a;
    resolver : 'a Lwt.u;
  }
end

type t = Packed : 'a Unpacked.t -> t

let make_text ~resolver () =
  Packed { variant = Text; current_value = ""; resolver }

let render (Packed { variant; current_value; resolver = _ }) =
  Variant.render variant current_value

let injest_key_event (Packed ({ variant; current_value; resolver } as t))
    (key, _mods) =
  match (variant, key) with
  | Text, `ASCII c ->
      let%lwt new_value = Variant.injest_char variant current_value c in
      Lwt.return (`Updated_to (Packed { t with current_value = new_value }))
  | Text, `Enter ->
      (* Set wakeup to be run once the current process yields *)
      Lwt.async (fun () ->
          let%lwt () =
            (* Using a pause means this will not be immediately scheduled *)
            Lwt.pause ()
          in
          Lwt.wakeup resolver current_value;
          Lwt.return ());

      Lwt.return `Ready_to_be_destroyed
  | _ -> Lwt.return (`Updated_to (Packed t))
