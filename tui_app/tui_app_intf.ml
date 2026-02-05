open! Core

module Tui_io = struct
  open Quickterface.Io

  type t = { term : Notty_lwt.Term.t; window : Window.t }

  let refresh_render { term; window } () =
    let screen_width, screen_height = Notty_lwt.Term.size term in
    let render_info = { Render_info.screen_width; screen_height } in
    let image = Window.render ~render_info window in
    Notty_lwt.Term.image term image

  module Http_client = Cohttp_lwt_unix.Client

  let input_then_add_to_log ~window_input ~log_item ({ window; _ } as t) () =
    let%lwt res = window_input window ~refresh_render:(refresh_render t) () in
    let%lwt () = Window.add_log_item window (log_item res) in
    Lwt.return res

  let input_any_key ({ window; _ } as t) () =
    Window.input_any_key window ~refresh_render:(refresh_render t) ()

  let input_text t () =
    input_then_add_to_log ~window_input:Window.input_text
      ~log_item:Log_item.input_text t ()

  let input_integer t () =
    input_then_add_to_log ~window_input:Window.input_integer
      ~log_item:(fun n -> Log_item.input_text (string_of_int n))
      t ()

  let input_single_selection t options () =
    input_then_add_to_log
      ~window_input:(Window.input_single_selection ~options)
      ~log_item:Log_item.input_text t ()

  let input_multi_selection t options () =
    input_then_add_to_log
      ~window_input:(Window.input_multi_selection ~options)
      ~log_item:(fun selected_options ->
        (* TODO-someday: perhaps this could be better done by separating them by line? *)
        Log_item.input_text (String.concat ~sep:", " selected_options))
      t ()

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

  let output_math ?options ({ window; _ } as t) math () =
    Window.add_log_item window (Log_item.output_math ?options math)
    |> then_refresh_render ~t

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

    (* Set up the event loop *)
    Lwt.async (fun () ->
        Lwt_stream.iter_s
          (fun event ->
            Window.handle_event t.window event;
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
