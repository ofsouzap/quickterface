open! Core

(* TODO-soon - add output channel [`Output | `Error] as another option *)
type t = { color : Color.t }

let default = { color = Color.default_foreground }
