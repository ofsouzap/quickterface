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

let attr = Notty.A.(fg lightwhite ++ bg blue ++ st bold)

let render { text } =
  ignore text;
  ignore attr;
  failwith "TODO"
