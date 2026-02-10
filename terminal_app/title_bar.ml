open! Core

type t = { text : string }

let make ~text () =
  let filtered_text =
    let open String in
    text
    |> substr_replace_all ~pattern:"\r" ~with_:""
    |> substr_replace_all ~pattern:"\n" ~with_:""
  in
  { text = filtered_text }

let render ~render_info:{ Render_info.screen_width; _ } { text } =
  let open Notty.I in
  if String.is_empty text then empty
  else
    let padding_top = 1 in
    let padding_bottom = 1 in
    let padding_left = 1 in
    let text_img = string Theme.title_text text in
    let background =
      char Theme.title_background ' ' screen_width
        (height text_img + padding_top + padding_bottom)
    in
    pad ~l:padding_left ~t:padding_top text_img </> background
