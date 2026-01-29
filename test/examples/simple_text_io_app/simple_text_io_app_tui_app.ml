module Tui_app =
  Quickterface_tui_app.Tui_app_intf.Make (Simple_text_io_app_app.App)

let () = Lwt_main.run (Tui_app.run ())
