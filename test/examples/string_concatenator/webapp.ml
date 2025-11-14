open! Core
module App = Quickterface.Web_app.Make (App.App)

let () = Lwt.async App.run
