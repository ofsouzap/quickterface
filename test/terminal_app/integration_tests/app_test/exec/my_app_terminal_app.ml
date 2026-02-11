module Terminal_app =
  Quickterface_terminal_app.Terminal_app_intf.Make (My_app_app.App)

let () = Terminal_app.command ~argv:Sys.argv ()
