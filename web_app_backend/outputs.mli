open! Core
open! Js_of_ocaml

module Output : sig
  module type S = sig
    type options
    type value
    type t

    val make :
      document:Dom_html.document Js.t ->
      options:options ->
      value:value ->
      t Lwt.t

    val element : t -> Dom_html.element Js.t
  end
end

module Text :
  Output.S
    with type value := string
     and type options := Quickterface.Output_text_options.t

module Math :
  Output.S
    with type value := Quickterface.Math.t
     and type options := Quickterface.Output_text_options.t

module Title : Output.S with type value := string and type options := unit

module Progress_bar : sig
  type t

  val make :
    document:Dom_html.document Js.t ->
    label:string option ->
    maximum:int ->
    t Lwt.t

  val element : t -> Dom_html.element Js.t
  val set_value : t -> int -> unit -> unit Lwt.t
  val finish : t -> unit -> unit Lwt.t
end
