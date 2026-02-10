open! Core

module type S = sig
  val run : mode:[ `Minimal | `Tui ] -> unit -> unit Lwt.t
  val command : argv:string array -> unit -> unit
end

module Make : functor (_ : Quickterface.App.S) -> S
