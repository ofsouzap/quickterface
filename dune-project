(lang dune 3.20)

(name quickterface)

(generate_opam_files true)

(source
 (github ofsouzap/quickterface))

(authors "Ofsouzap <ofsouzap@gmail.com>")

(maintainers "Ofsouzap <ofsouzap@gmail.com>")

(license MIT)

(package
 (name quickterface)
 (version 0.1.0)
 (synopsis "Quick-to-program app interfaces in OCaml for terminal and web")
 (depends
  (ocaml
   (>= 5.1.0))
  core
  js_of_ocaml
  js_of_ocaml-ppx
  lwt
  lwt_ppx
  cohttp-lwt
  cohttp-lwt-unix
  cohttp-lwt-jsoo
  fpath
  bos
  (notty
   (>= 0.2.3))))
