open! Core
open! Js_of_ocaml

type t = {
  link_await : Dom_html.linkElement Utils.Await_load_element.t;
  script_await : Dom_html.scriptElement Utils.Await_load_element.t;
}

let make ~document =
  let link_await =
    Utils.Await_load_element.make ~make_element:(fun () ->
        let link = Dom_html.createLink document in
        link##.rel := Js.string "stylesheet";
        link##.href :=
          Js.string
            "https://cdn.jsdelivr.net/npm/katex@0.16.27/dist/katex.min.css";
        link##setAttribute (Js.string "integrity")
          (Js.string
             "sha384-Pu5+C18nP5dwykLJOhd2U4Xen7rjScHN/qusop27hdd2drI+lL5KvX7YntvT8yew");
        link##setAttribute (Js.string "crossorigin") (Js.string "anonymous");
        link)
  in

  let script_await =
    Utils.Await_load_element.make ~make_element:(fun () ->
        let script = Dom_html.createScript document in
        script##.src :=
          Js.string
            "https://cdn.jsdelivr.net/npm/katex@0.16.27/dist/katex.min.js";
        script##setAttribute (Js.string "integrity")
          (Js.string
             "sha384-2B8pfmZZ6JlVoScJm/5hQfNS2TI/6hPqDZInzzPc8oHpN5SgeNOf4LzREO6p5YtZ");
        script##setAttribute (Js.string "crossorigin") (Js.string "anonymous");
        script)
  in

  { link_await; script_await }

let await_elements { link_await; script_await } =
  [
    (link_await :> Dom_html.element Utils.Await_load_element.t);
    (script_await :> Dom_html.element Utils.Await_load_element.t);
  ]
