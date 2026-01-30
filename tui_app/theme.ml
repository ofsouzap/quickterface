open! Core
open Notty.A

let text_output = fg white
let text_input_editable = fg white ++ st italic ++ st bold
let text_input_frozen = fg white ++ st italic
