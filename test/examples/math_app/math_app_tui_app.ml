module Tui_app = Quickterface_tui_app.Tui_app_intf.Make (Math_app_app.App)

let () = Lwt_main.run (Tui_app.run ())
