open! Core

let setup_cmd =
  let open Cmdliner in
  let executable_name =
    let doc = "Name of the executable to create." in
    Arg.(
      value
      & opt (some string) None
      & info [ "executable-name" ] ~docv:"NAME" ~doc)
  in
  let target_parent_path =
    let doc = "Path to the directory where the executable should be added." in
    let default = Fpath.v "." in
    Arg.(
      value
      & opt (conv Fpath.(of_string, pp)) default
      & info [ "target-parent-path" ] ~docv:"PATH" ~doc)
  in
  let info =
    Cmd.info "setup" ~doc:"Set up a new executable in an existing dune project"
      ~man:
        [
          `S Manpage.s_description;
          `P
            "Creates a new executable with template code and files in an \
             existing dune project.";
        ]
  in
  let run executable_name target_parent_dir =
    match
      Templates.set_up_template_executable ?executable_name ~target_parent_dir
        ()
    with
    | Ok () -> 0
    | Error err -> raise_s err
  in
  Cmd.v info Term.(const run $ executable_name $ target_parent_path)

let () = exit (Cmdliner.Cmd.eval' setup_cmd)
