open! Core
open! Js_of_ocaml

module Text : sig
  type t

  val make : document:Dom_html.document Js.t -> t
  val element : t -> Dom_html.element Js.t
  val wait_for_text_input : ?auto_focus:bool -> t -> unit -> string Lwt.t
end
