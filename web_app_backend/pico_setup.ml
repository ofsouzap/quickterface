open! Core
open! Js_of_ocaml

type t = { link_await : Dom_html.linkElement Utils.Await_load_element.t }

let make ~document =
  let link_await =
    Utils.Await_load_element.make ~make_element:(fun () ->
        let link = Dom_html.createLink document in
        link##.rel := Js.string "stylesheet";
        link##.href :=
          Js.string
            "https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css";
        link##setAttribute (Js.string "crossorigin") (Js.string "anonymous");
        link)
  in
  { link_await }

let await_elements { link_await } =
  [ (link_await :> Dom_html.element Utils.Await_load_element.t) ]
