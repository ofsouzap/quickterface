open! Core

module type S = sig
  type t

  module Http_client : Cohttp_lwt.S.Client

  val read_text : t -> unit -> string Lwt.t

  val print_text :
    ?options:Output_text_options.t -> t -> string -> unit -> unit Lwt.t

  val print_math :
    ?options:Output_text_options.t -> t -> Math.t -> unit -> unit Lwt.t

  val with_progress_bar :
    ?label:string ->
    t ->
    maximum:int ->
    f:(increment_progress_bar:(unit -> unit Lwt.t) -> unit -> 'a Lwt.t) ->
    unit ->
    'a Lwt.t
end
