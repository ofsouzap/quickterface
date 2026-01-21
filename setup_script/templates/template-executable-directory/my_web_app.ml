module Web_app = Quickterface_web_app.Web_app_intf.Make (My_app.App.App)

let () = Lwt.async Web_app.run
