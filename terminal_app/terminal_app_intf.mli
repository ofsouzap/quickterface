open! Core

module type S = sig
  val run : unit -> unit Lwt.t
end

module Make : functor (_ : Quickterface.App.S) -> S
