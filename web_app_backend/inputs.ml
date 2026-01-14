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

module Simple_html_input (M : sig
  type t

  val html_input_type : string
  val t_of_string_result : string -> (t, Error.t) Result.t
end) =
struct
  type t = {
    element : Dom_html.element Js.t;
    form : Dom_html.formElement Js.t;
    text_input_field : Dom_html.inputElement Js.t;
    text_input_field_submit_button : Dom_html.buttonElement Js.t;
  }

  let make ~document : t =
    let container = Dom_html.createDiv document in

    let input_field_name_string = Js.string "text_input_field" in

    let form = Dom_html.createForm document in
    Dom.appendChild container form;
    (form##.className := Class.(to_js_string Input_text_container_form));

    let input_text_prompt_label = Dom_html.createLabel document in
    (input_text_prompt_label##.className
    := Class.(to_js_string Text_prompt_label));
    input_text_prompt_label##.innerText := Js.string ">";
    input_text_prompt_label##.htmlFor := input_field_name_string;
    Dom.appendChild form input_text_prompt_label;

    let text_input_field =
      Dom_html.createInput document
        ~_type:(Js.string M.html_input_type)
        ~name:input_field_name_string
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
        let text_input_field_content = get_text_input_field_content t () in
        match M.t_of_string_result text_input_field_content with
        | Ok input_parsed_value ->
            Lwt.wakeup input_submit_handler input_parsed_value
        | Error error ->
            failwith
              ([%message "Failed to parse input" (error : Error.t)]
              |> Sexp.to_string_hum)
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

module Text = Simple_html_input (struct
  type t = string

  let html_input_type = "text"
  let t_of_string_result s = Ok s
end)

module Integer = Simple_html_input (struct
  type t = int

  let html_input_type = "number"

  let t_of_string_result s =
    match Int.of_string_opt s with
    | Some x -> Ok x
    | None -> Error (Error.of_string "Unable to parse string as int")
end)
