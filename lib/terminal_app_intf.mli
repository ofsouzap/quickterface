open! Core

module type S = sig
  val run : unit -> unit Lwt.t
end

module Make : functor (_ : App.S) -> S
