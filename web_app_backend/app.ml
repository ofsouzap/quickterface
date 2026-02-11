open! Core
open! Js_of_ocaml
open Quickterface.Io

type t = { head : Head.t; log : Log.t }

let make () =
  let document = Dom_html.document in
  let%lwt head = Head.make ~document () in

  let main_container = Dom_html.createDiv document in
  (main_container##.className := Class.(to_js_string Main_container));

  let log = Log.make ~document ~main_container in
  Dom.appendChild document##.body main_container;

  Lwt.return { head; log }

let input_text t () = Log.input_text t.log ()
let input_integer t () = Log.input_integer t.log ()
let input_single_selection t = Log.input_single_selection t.log

let input_single_selection_string t options =
  Log.input_single_selection t.log options Fn.id

let input_multi_selection t = Log.input_multi_selection t.log

let input_multi_selection_string t options =
  Log.input_multi_selection t.log options Fn.id

let input : type settings a.
    _ -> (settings, a) Input.t -> settings -> unit -> a Lwt.t =
 fun t -> function
  | Text -> fun () -> input_text t
  | Integer -> fun () -> input_integer t
  | Single_selection ->
      fun (options, option_to_string) ->
        input_single_selection t options option_to_string
  | Multi_selection ->
      fun (options, option_to_string) ->
        input_multi_selection t options option_to_string

let output_text ?options t value () =
  Log.add_output_text ?options t.log ~value ()

let output_math ?options t value () =
  Log.add_output_math ?options t.log ~value ()

let output_title t value () =
  let%lwt () = Log.add_output_title t.log ~value () in
  let%lwt () = Head.set_title t.head value () in
  Lwt.return ()

let output : type options a.
    ?options:options -> _ -> (options, a) Output.t -> a -> unit -> unit Lwt.t =
 fun ?options t -> function
  | Text -> fun x -> output_text ?options t x
  | Math -> fun x -> output_math ?options t x
  | Title -> ( fun x -> match options with None | Some () -> output_title t x)

let with_progress_bar ?label { head = _; log } =
  Log.with_progress_bar ?label log

let console_log_error message () =
  Js_of_ocaml.Console.console##error (Js.string message);
  Lwt.return ()
