module Web_app = Quickterface_web_app.Web_app_intf.Make ({app_module_name}_app.App)

let () = Lwt.async Web_app.run
