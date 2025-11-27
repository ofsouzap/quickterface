open! Core
open! Js_of_ocaml

module Input = struct
  module type S = sig
    type t
    type result

    val make : document:Dom_html.document Js.t -> t
    val element : t -> Dom_html.element Js.t
    val wait_for_input : ?auto_focus:bool -> t -> unit -> result Lwt.t
  end
end

module Text = struct
  type t = {
    element : Dom_html.element Js.t;
    form : Dom_html.formElement Js.t;
    text_input_field : Dom_html.inputElement Js.t;
    text_input_field_submit_button : Dom_html.buttonElement Js.t;
  }

  let make ~document : t =
    let container = Dom_html.createDiv document in

    let form = Dom_html.createForm document in
    Dom.appendChild container form;
    (form##.className := Class.(to_js_string Input_text_container_form));

    let text_input_field =
      Dom_html.createInput document ~_type:(Js.string "text")
        ~name:(Js.string "input")
    in
    (text_input_field##.className := Class.(to_js_string Input_text_field));
    text_input_field##setAttribute (Js.string "enterkeyhint") (Js.string "send");
    Dom.appendChild form text_input_field;

    let text_input_field_submit_button =
      Dom_html.createButton ~_type:(Js.string "submit") document
    in
    (text_input_field_submit_button##.className
    := Class.(to_js_string Input_text_submit_button));
    text_input_field_submit_button##.innerText := Js.string "Submit";
    Dom.appendChild form text_input_field_submit_button;

    {
      element = container;
      form;
      text_input_field;
      text_input_field_submit_button;
    }

  let element t = t.element

  let reset_text_input_field t () =
    t.text_input_field##.value := Js.string "";
    Lwt.return ()

  let get_text_input_field_content t () =
    Js.to_string t.text_input_field##.value

  let set_submit_handler t ~handler () =
    t.form##.onsubmit :=
      Dom.handler (fun event ->
          handler event ();
          Js._false)

  let clear_submit_handler t () =
    t.form##.onsubmit := Dom.handler (Fn.const Js._true)

  let set_to_readonly t () =
    t.text_input_field##.readOnly := Js._true;
    t.text_input_field_submit_button##.disabled := Js._true;
    Lwt.return ()

  let wait_for_input ?(auto_focus = true) t () =
    let get_text () =
      (* Wait for the user to enter their text into the input field *)
      let%lwt () = reset_text_input_field t () in
      let input_submit_promise, input_submit_handler = Lwt.task () in
      let submit_handler _ () =
        let text_input_field_context = get_text_input_field_content t () in
        Lwt.wakeup input_submit_handler text_input_field_context
      in
      set_submit_handler t ~handler:submit_handler ();
      if auto_focus then t.text_input_field##focus;
      input_submit_promise
    in

    let on_input_read () =
      (* Do cleanup once the input has been read *)
      let%lwt () = set_to_readonly t () in
      clear_submit_handler t ();
      Lwt.return ()
    in

    let%lwt input_text = get_text () in
    let%lwt () = on_input_read () in
    Lwt.return input_text
end
