open! Core

module Input = struct
  type _ t = Text : string t | Integer : int t
end

module Output = struct
  type _ t = Text : string t | Math : Math.t t
end

module type S = sig
  type t

  module Http_client : Cohttp_lwt.S.Client

  val input : t -> 'a Input.t -> unit -> 'a Lwt.t
  val input_text : t -> unit -> string Lwt.t
  val input_integer : t -> unit -> int Lwt.t

  val output :
    ?options:'a Output_options.t -> t -> 'a Output.t -> 'a -> unit -> unit Lwt.t

  val output_text :
    ?options:Output_text_options.t -> t -> string -> unit -> unit Lwt.t

  val output_math :
    ?options:Output_text_options.t -> t -> Math.t -> unit -> unit Lwt.t

  val with_progress_bar :
    ?label:string ->
    t ->
    maximum:int ->
    f:(increment_progress_bar:(unit -> unit Lwt.t) -> unit -> 'a Lwt.t) ->
    unit ->
    'a Lwt.t
end
