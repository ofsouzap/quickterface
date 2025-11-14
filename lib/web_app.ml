open! Core
open Js_of_ocaml

module type S = sig
  val run : unit -> unit Lwt.t
end

module Web_app_io = struct
  type t = {
    document : Dom_html.document Js.t;
    outputs_div : Dom_html.divElement Js.t;
    text_input_field : Dom_html.inputElement Js.t;
    text_input_field_submit_button : Dom_html.buttonElement Js.t;
  }

  let init () : t =
    let document = Dom_html.document in
    let outputs_div = Dom_html.createDiv document in
    Dom.appendChild document##.body outputs_div;
    let text_input_field =
      Dom_html.createInput document ~_type:(Js.string "text")
    in
    Dom.appendChild document##.body text_input_field;
    let text_input_field_submit_button = Dom_html.createButton document in
    text_input_field_submit_button##.innerText := Js.string "Submit";
    Dom.appendChild document##.body text_input_field_submit_button;
    { document; outputs_div; text_input_field; text_input_field_submit_button }

  let add_output_text t ~text () =
    let newP = (Dom_html.createP t.document :> Dom_html.element Js.t) in
    newP##.innerText := Js.string text;
    Dom.appendChild t.outputs_div newP;
    Lwt.return ()

  let reset_text_input_field t () =
    t.text_input_field##.value := Js.string "";
    Lwt.return ()

  let get_text_input_field_content t () =
    Js.to_string t.text_input_field##.value

  let wait_for_text_input t () =
    (* TODO - have previous inputs persist so page looks like a console history *)
    let%lwt () = reset_text_input_field t () in
    let input_submit_promise, input_submit_handler = Lwt.task () in
    let on_button_click _ =
      let text_input_field_context = get_text_input_field_content t () in
      Lwt.wakeup input_submit_handler text_input_field_context;
      Js._true
    in
    t.text_input_field_submit_button##.onclick := Dom.handler on_button_click;
    let%lwt read_text = input_submit_promise in
    t.text_input_field_submit_button##.onclick
    := Dom.handler (fun _ -> Js._false);
    Lwt.return read_text

  let read_text t () = wait_for_text_input t ()
  let print_text t text () = add_output_text t ~text ()
end

module Make (App : App.S) : S = struct
  module App = App (Web_app_io)

  let run () =
    let io = Web_app_io.init () in
    App.main ~io ()
end
