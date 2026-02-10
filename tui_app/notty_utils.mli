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

val uchar_box_drawing_light_horizontal : Uchar.t
val uchar_box_drawing_light_vertical : Uchar.t
val uchar_box_drawing_light_down_and_right : Uchar.t
val uchar_box_drawing_light_down_and_left : Uchar.t
val uchar_box_drawing_light_up_and_right : Uchar.t
val uchar_box_drawing_light_up_and_left : Uchar.t
val uchar_paren_drawing_light_top_left : Uchar.t
val uchar_paren_drawing_light_mid_left : Uchar.t
val uchar_paren_drawing_light_bottom_left : Uchar.t
val uchar_paren_drawing_light_top_right : Uchar.t
val uchar_paren_drawing_light_mid_right : Uchar.t
val uchar_paren_drawing_light_bottom_right : Uchar.t
val uchar_paren_top_half_integral : Uchar.t
val uchar_paren_bottom_half_integral : Uchar.t
val uchar_paren_integral_extender : Uchar.t

val boxed :
  ?padding_control:
    [ `None
    | `Exact_padding of int Sides.t
    | `To_min_boxed_size of
      (int * Width_side.t) option * (int * Height_side.t) option ] ->
  img ->
  img
