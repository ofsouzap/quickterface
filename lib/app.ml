open! Core

module type S = functor (Io : Io.S) -> sig
  val main : io:Io.t -> unit -> unit Lwt.t
end
