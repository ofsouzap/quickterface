open! Core
open! Js_of_ocaml

module Output = struct
  module type S = sig
    type value
    type t

    val make : document:Dom_html.document Js.t -> value:value -> t Lwt.t
    val element : t -> Dom_html.element Js.t
  end
end

module Text = struct
  type t = { element : Dom_html.element Js.t }

  let make ~document ~value =
    let item_div = Dom_html.createDiv document in
    let newP = (Dom_html.createP document :> Dom_html.element Js.t) in
    newP##.innerText := Js.string value;
    Dom.appendChild item_div newP;
    Lwt.return { element = item_div }

  let element t = t.element
end

module Progress_bar = struct
  type t = {
    element : Dom_html.element Js.t;
    bar_fill : Dom_html.divElement Js.t;
    progress_label : Dom_html.paragraphElement Js.t;
    maximum : int;
  }

  let make ~document ~label ~maximum =
    let item_div = Dom_html.createDiv document in
    (item_div##.className := Class.(to_js_string Progress_bar_item));

    (match label with
    | None -> ()
    | Some label ->
        let label_element = Dom_html.createP document in
        (label_element##.className := Class.(to_js_string Progress_bar_label));
        label_element##.innerText := Js.string label;
        Dom.appendChild item_div label_element);

    let bar_container = Dom_html.createDiv document in
    (bar_container##.className :=
       Class.(to_js_string Progress_bar_bar_container));
    Dom.appendChild item_div bar_container;

    let bar_fill = Dom_html.createDiv document in
    (bar_fill##.className :=
       Class.(to_js_string Progress_bar_bar_fill_in_progress));
    Dom.appendChild bar_container bar_fill;

    let progress_label = Dom_html.createP document in
    (progress_label##.className :=
       Class.(to_js_string Progress_bar_progress_label));
    progress_label##.innerText := Js.string "0%";
    Dom.appendChild item_div progress_label;

    Lwt.return { element = item_div; bar_fill; progress_label; maximum }

  let element t = t.element

  let set_value t value () =
    let percentage_fill = 100 * value / t.maximum in
    t.bar_fill##.style##.width
    := Js.string (Printf.sprintf "%d%%" percentage_fill);

    t.progress_label##.innerText
    := Js.string (Printf.sprintf "%d/%d" value t.maximum);

    Lwt.return ()

  let finish { bar_fill; _ } () =
    (bar_fill##.className :=
       Class.(to_js_string Progress_bar_bar_fill_completed));
    Lwt.return ()
end
