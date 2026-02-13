open! Core
open! Js_of_ocaml

module Input : sig
  (** Signature for a simple input *)
  module type S = sig
    type t
    type settings
    type result

    val make : settings -> document:Dom_html.document Js.t -> t
    val element : t -> Dom_html.element Js.t
    val wait_for_input : ?auto_focus:bool -> t -> unit -> result Lwt.t
  end

  (** Signature for an input with one type parameter. Should be equivalent to
      [S] but with a type parameter *)
  module type S1 = sig
    type 'a t
    type 'a settings
    type 'a result

    val make : 'a settings -> document:Dom_html.document Js.t -> 'a t
    val element : 'a t -> Dom_html.element Js.t
    val wait_for_input : ?auto_focus:bool -> 'a t -> unit -> 'a result Lwt.t
  end
end

module Text :
  Input.S with type settings := string option and type result := string

module Integer : Input.S with type settings := unit and type result := int

module Single_selection :
  Input.S1
    with type 'a settings := 'a list * ('a -> string)
     and type 'a result := 'a

module Multi_selection :
  Input.S1
    with type 'a settings := 'a list * ('a -> string)
     and type 'a result := 'a list
