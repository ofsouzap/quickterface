module Terminal_app =
  Quickterface_terminal_app.Terminal_app_intf.Make ({app_module_name}_app.App)

let () = Terminal_app.command ~argv:Sys.argv ()
