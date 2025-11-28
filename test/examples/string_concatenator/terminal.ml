open! Core
module App = Quickterface_terminal_app.Terminal_app_intf.Make (App.App)

let () = Lwt.async App.run
