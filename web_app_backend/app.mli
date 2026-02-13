open! Core
open! Js_of_ocaml

type t

val make : unit -> t Lwt.t

val input :
  t -> ('settings, 'a) Quickterface.Io.Input.t -> 'settings -> unit -> 'a Lwt.t

val input_text : ?prompt:string -> t -> unit -> string Lwt.t
val input_integer : t -> unit -> int Lwt.t
val input_single_selection : t -> 'a list -> ('a -> string) -> unit -> 'a Lwt.t
val input_single_selection_string : t -> string list -> unit -> string Lwt.t

val input_multi_selection :
  t -> 'a list -> ('a -> string) -> unit -> 'a list Lwt.t

val input_multi_selection_string : t -> string list -> unit -> string list Lwt.t

val output :
  ?options:'options ->
  t ->
  ('options, 'a) Quickterface.Io.Output.t ->
  'a ->
  unit ->
  unit Lwt.t

val output_text :
  ?options:Quickterface.Output_text_options.t ->
  t ->
  string ->
  unit ->
  unit Lwt.t

val output_math :
  ?options:Quickterface.Output_text_options.t ->
  t ->
  Quickterface.Math.t ->
  unit ->
  unit Lwt.t

val output_title : t -> string -> unit -> unit Lwt.t

val with_progress_bar :
  ?label:string ->
  t ->
  maximum:int ->
  f:(increment_progress_bar:(unit -> unit Lwt.t) -> unit -> 'a Lwt.t) ->
  unit ->
  'a Lwt.t

val console_log_error : string -> unit -> unit Lwt.t
