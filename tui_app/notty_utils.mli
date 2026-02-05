open! Core

type img := Notty.I.t

module Dimensions : sig
  type 'a t = { width : 'a; height : 'a }

  val const : 'a -> 'a t
end

module Sides : sig
  type 'a t = { left : 'a; right : 'a; top : 'a; bottom : 'a }
end

module Width_side : sig
  type t = Left | Right
end

module Height_side : sig
  type t = Top | Bottom
end

val boxed :
  ?padding_control:
    [ `None
    | `Exact_padding of int Sides.t
    | `To_min_boxed_size of
      (int * Width_side.t) option * (int * Height_side.t) option ] ->
  img ->
  img
