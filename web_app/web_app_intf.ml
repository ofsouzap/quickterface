open! Core
open! Js_of_ocaml

module Web_app_io = struct
  include Quickterface_web_app_backend.App
  module Http_client = Cohttp_lwt_jsoo.Client
end

module type S = sig
  val run : unit -> unit Lwt.t
end

module Make (App : Quickterface.App.S) : S = struct
  module App = App (Web_app_io)

  let run () =
    let%lwt io = Quickterface_web_app_backend.App.make () in
    App.main ~io ()
end
