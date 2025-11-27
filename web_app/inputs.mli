open! Core
open! Js_of_ocaml

module Input : sig
  module type S = sig
    type t
    type result

    val make : document:Dom_html.document Js.t -> t
    val element : t -> Dom_html.element Js.t
    val wait_for_input : ?auto_focus:bool -> t -> unit -> result Lwt.t
  end
end

module Text : Input.S with type result := string
