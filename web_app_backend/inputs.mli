open! Core
open! Js_of_ocaml

module Input : sig
  module type S = sig
    type t
    type settings
    type result

    val make : settings -> document:Dom_html.document Js.t -> t
    val element : t -> Dom_html.element Js.t
    val wait_for_input : ?auto_focus:bool -> t -> unit -> result Lwt.t
  end
end

module Text : Input.S with type settings := unit and type result := string
module Integer : Input.S with type settings := unit and type result := int

module Single_selection :
  Input.S with type settings := string list and type result := string
