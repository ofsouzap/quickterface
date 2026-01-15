open! Core

module Input = struct
  type (_, _) t =
    | Text : (unit, string) t
    | Integer : (unit, int) t
    | Single_selection : (string list, string) t
end

module Output = struct
  type (_, _) t =
    | Text : (Output_text_options.t, string) t
    | Math : (Output_text_options.t, Math.t) t
    | Title : (unit, string) t
end

module type S = sig
  type t

  module Http_client : Cohttp_lwt.S.Client

  val input : t -> ('settings, 'a) Input.t -> 'settings -> unit -> 'a Lwt.t
  val input_text : t -> unit -> string Lwt.t
  val input_integer : t -> unit -> int Lwt.t
  val input_single_selection : t -> string list -> unit -> string Lwt.t

  val output :
    ?options:'options ->
    t ->
    ('options, 'a) Output.t ->
    'a ->
    unit ->
    unit Lwt.t

  val output_text :
    ?options:Output_text_options.t -> t -> string -> unit -> unit Lwt.t

  val output_math :
    ?options:Output_text_options.t -> t -> Math.t -> unit -> unit Lwt.t

  val output_title : t -> string -> unit -> unit Lwt.t

  val with_progress_bar :
    ?label:string ->
    t ->
    maximum:int ->
    f:(increment_progress_bar:(unit -> unit Lwt.t) -> unit -> 'a Lwt.t) ->
    unit ->
    'a Lwt.t
end
