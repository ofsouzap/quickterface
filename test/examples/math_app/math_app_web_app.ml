module Web_app = Quickterface_web_app.Web_app_intf.Make (Math_app_app.App)

let () = Lwt.async Web_app.run
