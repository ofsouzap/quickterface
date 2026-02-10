open! Core

type 'a t = render_info:Render_info.t -> 'a -> Notty.image
