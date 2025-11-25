open! Core
open! Js_of_ocaml
open Web_app

module type S = sig
  val run : unit -> unit Lwt.t
end

module Web_app_io = struct
  type t = { log : Web_app.Log.t }

  let create_stylesheet_element document =
    let style_element = Dom_html.createStyle document in
    let css_string = Stylesheet.css_string in
    style_element##.innerHTML := Js.string css_string;
    style_element

  let make () : t =
    let document = Dom_html.document in
    Dom.appendChild Dom_html.document##.head
      (create_stylesheet_element document);
    let main_container = Dom_html.createDiv document in
    (main_container##.className := Class.(to_js_string Main_container));
    let log = Log.make ~document ~main_container in
    Dom.appendChild document##.body main_container;
    { log }

  let read_text t () = Log.read_input_text t.log ()
  let print_text t text () = Log.add_output_text t.log ~text ()
end

module Make (App : App.S) : S = struct
  module App = App (Web_app_io)

  let run () =
    let io = Web_app_io.make () in
    App.main ~io ()
end
