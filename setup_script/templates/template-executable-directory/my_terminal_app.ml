module Terminal_app =
  Quickterface_terminal_app.Terminal_app_intf.Make (My_app.App.App)

let () = Lwt_main.run (Terminal_app.run ())
