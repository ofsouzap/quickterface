open! Core
module App = Quickterface.Web_app_intf.Make (App.App)

let () = Lwt.async App.run
