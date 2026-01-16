open! Core

module App =
  Quickterface_terminal_app.Terminal_app_intf.Make
    (Example_multiselect_app.App.App)

let () = Lwt_main.run (App.run ())
