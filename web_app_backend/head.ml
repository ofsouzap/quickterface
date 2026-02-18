open! Core
open! Js_of_ocaml

type t = { title : Dom_html.titleElement Js.t }

let create_title_element document =
  let element = Dom_html.createTitle document in
  element

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

let add_and_await_external_libraries document ~parent =
  (* TODO-someday: Waiting for libraries to load before starting the app could cause
     noticeable start-up delays. Perhaps in future we could use
     the auto-render functionality to allow the app to start running
     before libraries are ready. *)
  let katex_setup_elements =
    Katex_setup.make ~document |> Katex_setup.await_elements
  in
  let bootstrap_setup_elements =
    Bootstrap_setup.make ~document |> Bootstrap_setup.await_elements
  in
  let all_elements = katex_setup_elements @ bootstrap_setup_elements in
  let%lwt () =
    List.map
      ~f:
        (Utils.Await_load_element
         .add_element_as_child_to_parent_and_wait_for_load ~parent)
      all_elements
    |> Lwt.join
  in
  Lwt.return ()

let make ~document () =
  let title = create_title_element document in
  Dom.appendChild document##.head title;
  Dom.appendChild document##.head (create_viewport_meta_element document);
  Dom.appendChild document##.head (create_charset_meta_element document);
  let%lwt () =
    add_and_await_external_libraries document ~parent:document##.head
  in
  Dom.appendChild document##.head (create_stylesheet_element document);

  Lwt.return { title }

let set_title { title; _ } text () =
  title##.innerText := Js.string text;
  Lwt.return ()
