open! Core
open! Js_of_ocaml

module Text : sig
  type t

  val make : document:Dom_html.document Js.t -> text:string -> t Lwt.t
  val element : t -> Dom_html.element Js.t
end
