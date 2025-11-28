open! Core

module type S = sig
  type t

  val read_text : t -> unit -> string Lwt.t
  val print_text : t -> string -> unit -> unit Lwt.t

  val with_progress_bar :
    ?label:string ->
    t ->
    maximum:int ->
    f:(increment_progress_bar:(unit -> unit Lwt.t) -> unit -> 'a Lwt.t) ->
    unit ->
    'a Lwt.t
end
