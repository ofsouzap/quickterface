module Terminal_app =
  Quickterface_terminal_app.Terminal_app_intf.Make (Simple_text_io_app_app.App)

let () = Lwt_main.run (Terminal_app.run ())
