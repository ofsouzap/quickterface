open! Core

module Tui_io = struct
  open Quickterface.Io

  type t = { term : Notty_lwt.Term.t; window : Window.t }

  let refresh_render { term; window } () =
    let image = Window.render window in
    Notty_lwt.Term.image term image

  module Http_client = Cohttp_lwt_unix.Client

  let input_any_key { window; _ } () = Window.input_any_key window ()
  let input_text { window; _ } () = Window.input_text window ()
  let input_integer _ () = failwith "TODO"
  let input_single_selection _ _ () = failwith "TODO"
  let input_multi_selection _ _ () = failwith "TODO"

  let input : type settings a.
      _ -> (settings, a) Input.t -> settings -> unit -> a Lwt.t =
   fun t -> function
    | Text -> fun () -> input_text t
    | Integer -> fun () -> input_integer t
    | Single_selection -> fun options -> input_single_selection t options
    | Multi_selection -> fun options -> input_multi_selection t options

  let then_refresh_render ~t f =
    let%lwt () = f in
    refresh_render t ()

  let output_text ?options ({ window; _ } as t) text () =
    Window.add_log_item window (Log_item.output_text ?options text)
    |> then_refresh_render ~t

  let output_math ?options:_ _ _ () = failwith "TODO"

  let output_title ({ window; _ } as t) text () =
    Window.set_title window text |> then_refresh_render ~t

  let output : type options a.
      ?options:options -> _ -> (options, a) Output.t -> a -> unit -> unit Lwt.t
      =
   fun ?options t -> function
    | Text -> fun x -> output_text ?options t x
    | Math -> fun x -> output_math ?options t x
    | Title -> (
        fun x -> match options with None | Some () -> output_title t x)

  let with_progress_bar ?label:_ _ ~maximum:_ ~f:_ () = failwith "TODO"

  let make () =
    let term =
      Notty_lwt.Term.create ~nosig:false ~mouse:false ~bpaste:false ()
    in
    let window = Window.make () in
    let t = { term; window } in
    (* TODO - render initial window before any events have appeared *)

    (* Set up the event loop *)
    Lwt.async (fun () ->
        Lwt_stream.iter_s
          (fun event ->
            let%lwt () = Window.handle_event t.window event in
            let%lwt () = refresh_render t () in
            Lwt.return ())
          (Notty_lwt.Term.events t.term));

    t
end

module type S = sig
  val run : unit -> unit Lwt.t
end

module Make (App : Quickterface.App.S) : S = struct
  module App = App (Tui_io)

  let run () =
    let io = Tui_io.make () in
    let%lwt () = App.main ~io () in
    let%lwt () = Tui_io.output_text io "[Press any key to exit]" () in
    let%lwt () = Tui_io.input_any_key io () in
    Lwt.return ()
end
