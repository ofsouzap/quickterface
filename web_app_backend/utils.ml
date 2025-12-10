open! Core
open! Js_of_ocaml

module Await_load_element = struct
  type +'a t = {
    element : 'a Js.t;
    promise : unit Lwt.t;
  }
    constraint 'a = #Dom_html.element

  let make ~make_element =
    let promise, resolver = Lwt.wait () in

    let element = make_element () in

    let onload_callback _ =
      Lwt.wakeup resolver ();
      Js._false
    in
    let _ =
      Dom_html.addEventListener element Dom_html.Event.load
        (Dom_html.handler onload_callback)
        Js._false
    in

    let onerror_callback _ =
      Lwt.wakeup_exn resolver (Failure "Failed to load element");
      Js._false
    in
    let _ =
      Dom_html.addEventListener element Dom_html.Event.error
        (Dom_html.handler onerror_callback)
        Js._false
    in

    { element; promise }

  let add_element_as_child_to_parent_and_wait_for_load t ~parent =
    Dom.appendChild parent (t.element :> Dom.node Js.t);
    t.promise
end
