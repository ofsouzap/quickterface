open! Core

let package_name = "quickterface"
let lib_dir_name = "lib"
let executable_template_template_path = Fpath.v "template-executable-directory"
let default_executable_template_name = "my_app"
let web_app_index_template_path = Fpath.v "web-app"

let get_share_dir () =
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

  package_share_dir

let get_template_executable_dir () =
  let share_dir = get_share_dir () in
  Fpath.(share_dir // executable_template_template_path)

let map_rresult_msg_error_to_sexp ~msg_error_message v =
  Result.map_error v ~f:(fun (`Msg error_message) ->
      [%message msg_error_message (error_message : string)])

let or_rresult_msg_error_ok_if_true ~msg_error_message ~false_error v =
  let open Result.Let_syntax in
  map_rresult_msg_error_to_sexp ~msg_error_message v
  >>= Result.ok_if_true ~error:false_error

(** [copy_tree ~from ~to_] will create [to_] to be the same as [from], whether
    [from] is a file or directory. [to_] should not already exist *)
let rec copy_tree ~from ~to_ =
  let open Result.Let_syntax in
  let open Bos.OS in
  if%bind
    Dir.exists from
    |> map_rresult_msg_error_to_sexp
         ~msg_error_message:"Error checking if source is directory"
  then
    (* Create the subdirectory *)
    let%bind () =
      Dir.create ~path:false to_
      |> or_rresult_msg_error_ok_if_true
           ~msg_error_message:"Error creating target directory"
           ~false_error:[%message "Target directory already exists"]
    in

    (* Recurse onto each entry in directory *)
    let%bind entries =
      Dir.contents ~rel:true from
      |> map_rresult_msg_error_to_sexp
           ~msg_error_message:"Error reading contents"
    in
    Result.all_unit
      (List.map entries ~f:(fun relative_entry ->
           let new_from = Fpath.(from // relative_entry) in
           let new_to = Fpath.(to_ // relative_entry) in
           copy_tree ~from:new_from ~to_:new_to))
  else if%bind
    File.exists from
    |> map_rresult_msg_error_to_sexp
         ~msg_error_message:"Error checking if source is file"
  then
    let%bind contents =
      File.read from
      |> map_rresult_msg_error_to_sexp
           ~msg_error_message:"Error reading file contents"
    in
    File.write to_ contents
    |> map_rresult_msg_error_to_sexp
         ~msg_error_message:"Error writing file contents"
  else
    let from = Fpath.to_string from in
    Error [%message "Source path is neither file nor directory" (from : string)]

(** [set_up_template_executable ?project_template_name ~target_parent_dir] will
    set up the directory [<target_parent_dir>/<project_template_name>] with the
    template executables set up in this directory *)
let set_up_template_executable
    ?(executable_name = default_executable_template_name) ~target_parent_dir ()
    =
  let open Result.Let_syntax in
  let template_dir = get_template_executable_dir () in
  let target_directory = Fpath.(target_parent_dir / executable_name) in

  let%bind () = copy_tree ~from:template_dir ~to_:target_directory in
  Ok ()

let get_web_app_index_template_path () =
  let share_dir = get_share_dir () in
  Fpath.(share_dir // web_app_index_template_path)

let set_up_web_app_template () =
  ignore get_web_app_index_template_path;
  failwith "TODO"
