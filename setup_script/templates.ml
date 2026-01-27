open! Core

let package_name = "quickterface"
let templates_dir_name = "templates"
let lib_dir_name = "lib"
let executable_template_template_path = Fpath.v "template-executable-directory"
let default_executable_template_name = "my_app"

let get_templates_dir () =
  let open Fpath in
  (* [Findlib.package_directory] returns a path like [<prefix>/lib/quickterface] and we want [<prefix>/share/quickterface] *)
  let package_lib_dir = v (Findlib.package_directory package_name) in

  if not (String.equal (basename package_lib_dir) package_name) then
    raise_s
      [%message
        "Unexpected package directory structure"
          (to_string package_lib_dir : string)];

  let lib_dir = parent package_lib_dir in

  if not (String.equal (basename lib_dir) lib_dir_name) then
    raise_s
      [%message
        "Unexpected package directory structure"
          (to_string package_lib_dir : string)];

  let parent_dir = parent lib_dir in
  let package_share_dir = parent_dir / "share" / package_name in

  package_share_dir / templates_dir_name

let get_template_executable_dir () =
  let templates_dir = get_templates_dir () in
  Fpath.(templates_dir // executable_template_template_path)

let map_rresult_msg_error_to_sexp ~msg_error_message v =
  Result.map_error v ~f:(fun (`Msg error_message) ->
      [%message msg_error_message (error_message : string)])

let or_rresult_msg_error_ok_if_true ~msg_error_message ~false_error v =
  let open Result.Let_syntax in
  map_rresult_msg_error_to_sexp ~msg_error_message v
  >>= Result.ok_if_true ~error:false_error

module Template_file_substitutions = struct
  module Key = struct
    type t = App_name | App_module_name [@@deriving enumerate]

    let to_string = function
      | App_name -> "app_name"
      | App_module_name -> "app_module_name"
  end

  type t = T of (Key.t -> string)

  let perform ~contents (T substitution_function) =
    List.fold Key.all ~init:contents ~f:(fun contents key ->
        let value = substitution_function key in
        let formatted_key = "{" ^ Key.to_string key ^ "}" in
        String.substr_replace_all contents ~pattern:formatted_key ~with_:value)
end

let copy_file () ~substitutions ~from ~to_ =
  let open Result.Let_syntax in
  let open Bos.OS in
  let%bind contents =
    File.read from
    |> map_rresult_msg_error_to_sexp
         ~msg_error_message:"Error reading file contents"
  in
  let contents = Template_file_substitutions.perform ~contents substitutions in
  File.write to_ contents
  |> map_rresult_msg_error_to_sexp
       ~msg_error_message:"Error writing file contents"

let copy_template_file ~substitutions ~template_executable_dir ~target_directory
    (from_rel_path, to_rel_path) () =
  let open Result.Let_syntax in
  let open Bos.OS in
  let from = Fpath.(template_executable_dir / from_rel_path) in
  let%bind () =
    or_rresult_msg_error_ok_if_true
      ~msg_error_message:"Error checking if template file exists"
      ~false_error:
        (let from = Fpath.to_string from in
         [%message "Template file does not exist" from])
      (File.exists from)
  in

  let to_ =
    let substituted_to_rel_path =
      Template_file_substitutions.perform ~contents:to_rel_path substitutions
    in
    Fpath.(target_directory / substituted_to_rel_path)
  in
  let%bind () =
    or_rresult_msg_error_ok_if_true
      ~msg_error_message:"Error checking if target file exists"
      ~false_error:
        (let to_ = Fpath.to_string to_ in
         [%message "Target file already exists" to_])
      (File.exists to_ >>| not)
  in

  copy_file () ~substitutions ~from ~to_

let template_files_to_copy_with_destination_names =
  [
    ("dune", "dune");
    ("app.ml", "{app_name}_app.ml");
    ("terminal_app.ml", "{app_name}_terminal_app.ml");
    ("web_app.ml", "{app_name}_web_app.ml");
    ("index.html", "index.html");
  ]

(** [set_up_template_executable ?project_template_name ~target_parent_dir] will
    set up the directory [<target_parent_dir>/<project_template_name>] with the
    template executables set up in this directory *)
let set_up_template_executable
    ?(executable_name = default_executable_template_name) ~target_parent_dir ()
    =
  let open Result.Let_syntax in
  let template_executable_dir = get_template_executable_dir () in
  let target_directory = Fpath.(target_parent_dir / executable_name) in

  (* Create executable directory *)
  let%bind () =
    Bos.OS.Dir.create target_directory
    |> or_rresult_msg_error_ok_if_true
         ~msg_error_message:"Error creating target directory"
         ~false_error:
           (let target_directory = Fpath.to_string target_directory in
            [%message "Target directory already exists" target_directory])
  in

  (* Set up the substitutions *)
  let substitutions =
    Template_file_substitutions.T
      (function
      | App_name -> executable_name
      | App_module_name -> String.capitalize executable_name)
  in

  (* Copy the template files *)
  let%bind () =
    List.fold_result template_files_to_copy_with_destination_names ~init:()
      ~f:(fun () entry ->
        copy_template_file ~substitutions ~template_executable_dir
          ~target_directory entry ())
  in

  Ok ()
