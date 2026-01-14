open! Core
open! Js_of_ocaml

type t = { log : Log.t }

val make : unit -> t Lwt.t
val input : t -> 'a Quickterface.Io.Input.t -> unit -> 'a Lwt.t
val input_text : t -> unit -> string Lwt.t
val input_integer : t -> unit -> int Lwt.t

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

val with_progress_bar :
  ?label:string ->
  t ->
  maximum:int ->
  f:(increment_progress_bar:(unit -> unit Lwt.t) -> unit -> 'a Lwt.t) ->
  unit ->
  'a Lwt.t
