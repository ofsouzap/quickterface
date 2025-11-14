open! Core
module App = Quickterface.Terminal_app.Make (App.App)

let () = Lwt.async App.run
