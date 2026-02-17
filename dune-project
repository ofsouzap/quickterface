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
  (js_of_ocaml
   (>= 6.0.0))
  js_of_ocaml-ppx
  (js_of_ocaml-compiler
   (>= 6.2.0))
  lwt
  lwt_ppx
  cohttp-lwt
  cohttp-lwt-unix
  cohttp-lwt-jsoo
  fpath
  bos
  (notty
   (>= 0.2.3))
  (cmdliner
   (>= 2.1.0))
  (ocamlfind
   (>= 1.9.8))
  (ppx_jane
   (>= v0.17.0))
  (ocamlformat
   (and
    :with-dev-setup
    (= 0.28.1)))
  (bigstringaf
   (>= 0.6.1))))

(package
 (name quickterface-setup-script-tests)
 (allow_empty)
 (version 0.1.0)
 (synopsis
  "Tests for quickterface setup script (requires quickterface installed)")
 (depends
  (ocaml
   (>= 5.1.0))
  (quickterface
   (= 0.1.0))))
