open! Core

module type S = sig
  val run : mode:[ `Minimal | `Tui ] -> unit -> unit Lwt.t
  val command : argv:string array -> unit -> unit
end

module Make (App : Quickterface.App.S) : S = struct
  module Minimal_app = App (Minimal_terminal_io)
  module Tui_app = App (Tui_terminal_io)

  let run_minimal_app () =
    let io = Minimal_terminal_io.make () in
    Minimal_app.main ~io ()

  let run_tui_app () =
    let io = Tui_terminal_io.make () in
    let%lwt () = Tui_app.main ~io () in
    let%lwt () = Tui_terminal_io.output_text io "[Press any key to exit]" () in
    let%lwt () = Tui_terminal_io.input_any_key io () in
    Lwt.return ()

  let run ~mode =
    match mode with `Tui -> run_tui_app | `Minimal -> run_minimal_app

  let command ~argv () =
    let open Cmdliner in
    let mode_term =
      let doc = "Mode to run the application in. Can be 'tui' or 'minimal'." in
      Arg.(
        value
        & opt (enum [ ("tui", `Tui); ("minimal", `Minimal) ]) `Tui
        & info [ "m"; "mode" ] ~docv:"MODE" ~doc)
    in

    let run_term =
      Term.(const (fun mode -> Lwt_main.run (run ~mode ())) $ mode_term)
    in

    let cmd =
      let doc = "Run the application" in
      let info = Cmd.info "app" ~doc in
      Cmd.v info run_term
    in

    ignore (Cmd.eval ~argv cmd)
end
