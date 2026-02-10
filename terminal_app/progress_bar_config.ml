open! Core

type t = { label : string option; maximum_value : int } [@@deriving sexp]
