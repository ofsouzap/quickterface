open! Core
module App = Quickterface.Terminal_app_intf.Make (App.App)

let () = Lwt.async App.run
