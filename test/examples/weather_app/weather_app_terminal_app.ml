module Terminal_app =
  Quickterface_terminal_app.Terminal_app_intf.Make (Weather_app_app.App)

let () = Lwt_main.run (Terminal_app.run ())
