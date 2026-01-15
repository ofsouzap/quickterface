open! Core
open! Js_of_ocaml

module Input = struct
  module type S = sig
    type t
    type settings
    type result

    val make : settings -> document:Dom_html.document Js.t -> t
    val element : t -> Dom_html.element Js.t
    val wait_for_input : ?auto_focus:bool -> t -> unit -> result Lwt.t
  end
end

module Html_input (Element : sig
  type t
  type settings
  type value

  val append_element_as_child : t -> parent:#Dom.node Js.t -> unit
  val reset : t -> unit -> unit Lwt.t
  val make_readonly : t -> unit -> unit Lwt.t
  val focus : t -> unit -> unit Lwt.t
  val read_value_result : t -> unit -> (value, Error.t) Result.t
  val make : document:Dom_html.document Js.t -> settings:settings -> unit -> t
end) =
struct
  type t = {
    element : Dom_html.element Js.t;
    form : Dom_html.formElement Js.t;
    input_element : Element.t;
    submit_button : Dom_html.buttonElement Js.t;
  }

  let make settings ~document : t =
    let container = Dom_html.createDiv document in

    let form = Dom_html.createForm document in
    Dom.appendChild container form;
    (form##.className := Class.(to_js_string Input_text_container_form));

    let input_element = Element.make ~document ~settings () in
    Element.append_element_as_child input_element ~parent:form;

    let submit_button =
      Dom_html.createButton ~_type:(Js.string "submit") document
    in
    (submit_button##.className := Class.(to_js_string Input_text_submit_button));
    submit_button##.innerText := Js.string "Submit";
    Dom.appendChild form submit_button;

    { element = container; form; input_element; submit_button }

  let element t = t.element

  let set_submit_handler t ~handler () =
    t.form##.onsubmit :=
      Dom.handler (fun event ->
          handler event ();
          Js._false)

  let clear_submit_handler t () =
    t.form##.onsubmit := Dom.handler (Fn.const Js._true)

  let set_to_readonly t () =
    let%lwt () = Element.make_readonly t.input_element () in
    t.submit_button##.disabled := Js._true;
    Lwt.return ()

  let wait_for_input ?(auto_focus = true) t () =
    let get_input () =
      let%lwt () = Element.reset t.input_element () in

      let input_submit_promise, input_submit_handler = Lwt.task () in

      let submit_handler _ () =
        match Element.read_value_result t.input_element () with
        | Ok input_parsed_value ->
            Lwt.wakeup input_submit_handler input_parsed_value
        | Error error ->
            (* TODO-someday: need to have some kind of error reporting that actually
               shows to the user. Currently this will just crash the webapp *)
            failwith
              ([%message "Failed to parse input" (error : Error.t)]
              |> Sexp.to_string_hum)
      in
      set_submit_handler t ~handler:submit_handler ();

      let%lwt () =
        if auto_focus then Element.focus t.input_element () else Lwt.return ()
      in
      input_submit_promise
    in

    let on_input_read () =
      (* Do cleanup once the input has been read *)
      let%lwt () = set_to_readonly t () in
      clear_submit_handler t ();
      Lwt.return ()
    in

    let%lwt input = get_input () in
    let%lwt () = on_input_read () in
    Lwt.return input
end

module Simple_html_input (M : sig
  type t

  val html_input_type : string
  val t_of_string_result : string -> (t, Error.t) Result.t
end) =
Html_input (struct
  type t = Dom_html.inputElement Js.t
  type settings = unit
  type value = M.t

  let append_element_as_child t ~parent = Dom.appendChild parent t

  let reset t () =
    t##.value := Js.string "";
    Lwt.return ()

  let make_readonly t () =
    t##.readOnly := Js._true;
    Lwt.return ()

  let focus t () =
    t##focus;
    Lwt.return ()

  let get_content t () = Js.to_string t##.value

  let read_value_result element () =
    let input_element_content = get_content element () in
    M.t_of_string_result input_element_content

  let make ~document ~settings:() () =
    let input_field_name_string = Js.string "text_input_field" in
    Dom_html.createInput document
      ~_type:(Js.string M.html_input_type)
      ~name:input_field_name_string
end)

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
