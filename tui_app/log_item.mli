open! Core

type t

val output_text : ?options:Quickterface.Output_text_options.t -> string -> t

val output_math :
  ?options:Quickterface.Output_text_options.t -> Quickterface.Math.t -> t

val input_text : string -> t
val render : t Render_function.t

module For_testing : sig
  val render_math :
    render_info:Render_info.t ->
    Notty.attr ->
    Quickterface.Math.t ->
    Notty.image
end
