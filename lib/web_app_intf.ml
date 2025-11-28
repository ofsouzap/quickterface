open! Core
open! Js_of_ocaml

module type S = sig
  val run : unit -> unit Lwt.t
end

module Make (App : Quickterface.App.S) : S = struct
  module App = App (Quickterface_web_app_backend.App)

  let run () =
    let io = Quickterface_web_app_backend.App.make () in
    App.main ~io ()
end
