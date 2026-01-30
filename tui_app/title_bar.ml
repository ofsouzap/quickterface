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

let render { text } =
  ignore text;
  failwith "TODO"
