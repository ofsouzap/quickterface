open! Core
open! Js_of_ocaml

module Await_load_element : sig
  type +'a t constraint 'a = #Dom_html.element

  val make : make_element:(unit -> (#Dom_html.element as 'a) Js.t) -> 'a t

  val add_element_as_child_to_parent_and_wait_for_load :
    'a t -> parent:#Dom.node Js.t -> unit Lwt.t
end
