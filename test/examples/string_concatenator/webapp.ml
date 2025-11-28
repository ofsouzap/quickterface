open! Core
module App = Quickterface_web_app.Web_app_intf.Make (App.App)

let () = Lwt.async App.run
