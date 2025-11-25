open! Core
open! Js_of_ocaml

module Text = struct
  type t = {
    element : Dom_html.element Js.t;
    text_input_field : Dom_html.inputElement Js.t;
    text_input_field_submit_button : Dom_html.buttonElement Js.t;
  }

  let make ~document : t =
    let container = Dom_html.createDiv document in
    (container##.className := Class.(to_js_string Input_text));
    let text_input_field =
      Dom_html.createInput document ~_type:(Js.string "text")
    in
    Dom.appendChild container text_input_field;
    let text_input_field_submit_button = Dom_html.createButton document in
    text_input_field_submit_button##.innerText := Js.string "Submit";
    Dom.appendChild container text_input_field_submit_button;
    { element = container; text_input_field; text_input_field_submit_button }

  let reset_text_input_field t () =
    t.text_input_field##.value := Js.string "";
    Lwt.return ()

  let get_text_input_field_content t () =
    Js.to_string t.text_input_field##.value

  let set_submit_button_onclick t ~handler () =
    t.text_input_field_submit_button##.onclick
    := Dom.handler (fun event ->
           handler event ();
           Js._false)

  let clear_submit_button_onclick t () =
    t.text_input_field_submit_button##.onclick
    := Dom.handler (Fn.const Js._true)

  let set_to_readonly t () =
    t.text_input_field##.readOnly := Js._true;
    t.text_input_field_submit_button##.disabled := Js._true;
    Lwt.return ()

  let wait_for_text_input t () =
    let get_text () =
      (* Wait for the user to enter their text into the input field *)
      let%lwt () = reset_text_input_field t () in
      let input_submit_promise, input_submit_handler = Lwt.task () in
      let submit_handler _ () =
        let text_input_field_context = get_text_input_field_content t () in
        Lwt.wakeup input_submit_handler text_input_field_context
      in
      set_submit_button_onclick t ~handler:submit_handler ();
      input_submit_promise
    in

    let on_input_read () =
      (* Do cleanup once the input has been read *)
      let%lwt () = set_to_readonly t () in
      clear_submit_button_onclick t ();
      Lwt.return ()
    in

    let%lwt input_text = get_text () in
    let%lwt () = on_input_read () in
    Lwt.return input_text
end
