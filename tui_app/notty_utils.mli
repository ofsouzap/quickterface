open! Core

type img := Notty.I.t

module Sides : sig
  type 'a t = { left : 'a; right : 'a; top : 'a; bottom : 'a }
end

val boxed :
  ?padding_control:[ `None | `Exact_padding of int Sides.t ] -> img -> img
