open! Core

module type S = sig
  type t

  val read_text : t -> unit -> string Lwt.t
  val print_text : t -> string -> unit -> unit Lwt.t
end
