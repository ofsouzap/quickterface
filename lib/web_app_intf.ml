open! Core
open! Js_of_ocaml

module type S = sig
  val run : unit -> unit Lwt.t
end

module Make (App : App.S) : S = struct
  module App = App (Web_app.App)

  let run () =
    let io = Web_app.App.make () in
    App.main ~io ()
end
