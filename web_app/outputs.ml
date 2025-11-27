open! Core
open! Js_of_ocaml

module Text = struct
  type t = { element : Dom_html.element Js.t }

  let make ~document ~text =
    let item_div = Dom_html.createDiv document in
    let newP = (Dom_html.createP document :> Dom_html.element Js.t) in
    newP##.innerText := Js.string text;
    Dom.appendChild item_div newP;
    Lwt.return { element = item_div }

  let element t = t.element
end
