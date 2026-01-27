open! Core

val set_up_template_executable :
  ?executable_name:string ->
  target_parent_dir:Fpath.t ->
  unit ->
  (unit, Sexp.t) Result.t
