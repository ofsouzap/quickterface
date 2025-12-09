open! Core

type t =
  | Literal of string
  | Infinity
  | Pi
  | E
  | Plus
  | Star
  | C_dot
  | List of t list
  | Frac of t * t
  | Bracketed of t
  | Integral of { lower : t option; upper : t option }
