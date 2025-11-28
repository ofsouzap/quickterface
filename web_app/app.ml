open! Core
open! Js_of_ocaml

type t = { log : Log.t }

let create_stylesheet_element document =
  let style_element = Dom_html.createStyle document in
  let css_string = Stylesheet.css_string in
  style_element##.innerHTML := Js.string css_string;
  style_element

let create_viewport_meta_element document =
  let meta_element = Dom_html.createMeta document in
  meta_element##.name := Js.string "viewport";
  meta_element##.content :=
    Js.string
      "width=device-width, initial-scale=1.0, maximum-scale=1.0, \
       user-scalable=no";
  meta_element

let create_charset_meta_element document =
  let meta_element = Dom_html.createMeta document in
  meta_element##setAttribute (Js.string "charset") (Js.string "UTF-8");
  meta_element

let setup_head ~document () =
  Dom.appendChild document##.head (create_stylesheet_element document);
  Dom.appendChild document##.head (create_viewport_meta_element document);
  Dom.appendChild document##.head (create_charset_meta_element document);
  ()

let make () : t =
  let document = Dom_html.document in
  setup_head ~document ();

  let main_container = Dom_html.createDiv document in
  (main_container##.className := Class.(to_js_string Main_container));

  let log = Log.make ~document ~main_container in
  Dom.appendChild document##.body main_container;

  { log }

let read_text t () = Log.read_input_text t.log ()
let print_text t value () = Log.add_output_text t.log ~value ()
let with_progress_bar ?label { log } = Log.with_progress_bar ?label log
