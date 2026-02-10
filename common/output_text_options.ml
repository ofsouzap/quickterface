open! Core

type t = { color : [ `Default | `Custom of Color.t ] }

let default = { color = `Default }
