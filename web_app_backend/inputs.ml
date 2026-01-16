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
    (form##.className := Class.(to_js_string Input_container_form));

    let input_element = Element.make ~document ~settings () in
    Element.append_element_as_child input_element ~parent:form;

    let submit_button =
      Dom_html.createButton ~_type:(Js.string "submit") document
    in
    (submit_button##.className := Class.(to_js_string Input_submit_button));
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

module Single_selection = Html_input (struct
  type t = {
    element : Dom_html.selectElement Js.t;
    options : string list;
    default : string;
  }

  type settings = string list
  type value = string

  let append_element_as_child { element; _ } ~parent =
    Dom.appendChild parent element

  let reset { element; options = _; default } () =
    element##.value := Js.string default;
    Lwt.return ()

  let make_readonly { element; _ } () =
    element##.disabled := Js._true;
    Lwt.return ()

  let focus { element; _ } () =
    element##focus;
    Lwt.return ()

  let read_value_result { element; options; default = _ } () =
    let input = Js.to_string element##.value in
    if List.mem options input ~equal:String.equal then Ok input
    else Error (Error.of_string "Input value is not one of allowed options")

  let make ~document ~settings:options () =
    match options with
    | [] -> failwith "No options provided"
    | default :: _ ->
        let input_field_name_string = Js.string "select_input" in
        let element =
          Dom_html.createSelect document ~name:input_field_name_string
        in
        List.iter options ~f:(fun option ->
            let option_element = Dom_html.createOption document in
            option_element##.innerText := Js.string option;
            Dom.appendChild element option_element);
        { element; options; default }
end)

module Multi_selection = Html_input (struct
  module Checkbox = struct
    type t = {
      element : Dom_html.element Js.t;
      checkbox : Dom_html.inputElement Js.t;
      value_name : string;
    }

    let append_element_as_child { element; _ } ~parent =
      Dom.appendChild parent element

    let reset { checkbox; _ } () = checkbox##.checked := Js._false
    let make_readonly { checkbox; _ } () = checkbox##.disabled := Js._true
    let is_checked { checkbox; _ } () = Js.to_bool checkbox##.checked
    let value_name { value_name; _ } = value_name

    let make ~document ~value_name ~input_name () =
      (* TODO - make this formatted much nicer *)
      let label_container = Dom_html.createLabel document in
      (label_container##.className
      := Class.(to_js_string Input_multiselect_container));

      let checkbox =
        Dom_html.createInput document ~_type:(Js.string "checkbox")
          ~name:(Js.string input_name)
      in
      Dom.appendChild label_container checkbox;

      let value_node = Dom_html.createP document in
      value_node##.innerText := Js.string value_name;
      Dom.appendChild label_container value_node;

      {
        element = (label_container :> Dom_html.element Js.t);
        checkbox;
        value_name;
      }
  end

  type t = {
    element : Dom_html.fieldSetElement Js.t;
    checkboxes : Checkbox.t list;
    options : string list;
  }

  type settings = string list
  type value = string list

  let append_element_as_child { element; _ } ~parent =
    Dom.appendChild parent element

  let reset { checkboxes; _ } () =
    List.iter checkboxes ~f:(fun checkbox -> Checkbox.reset checkbox ());
    Lwt.return ()

  let make_readonly { checkboxes; _ } () =
    List.iter checkboxes ~f:(fun checkbox -> Checkbox.make_readonly checkbox ());
    Lwt.return ()

  let focus { checkboxes; _ } () =
    (match checkboxes with
    | [] -> ()
    | first_checkbox :: _ -> first_checkbox.element##focus);
    Lwt.return ()

  let read_value_result { element = _; checkboxes; options } () =
    List.fold_result checkboxes ~init:[] ~f:(fun acc checkbox ->
        if Checkbox.is_checked checkbox () then
          let value = Checkbox.value_name checkbox in
          if List.mem options value ~equal:String.equal then
            (* Add on the checked, correct value *)
            Ok (value :: acc)
          else
            Error
              (Error.of_string
                 [%string
                   "Checkbox value \"${value}\" is not one of allowed options"])
        else
          (* Don't add as not checked *)
          Ok acc)

  let make ~document ~settings:options () =
    let fieldset = Dom_html.createFieldset document in

    let checkboxes =
      List.map options ~f:(fun option ->
          let checkbox_name =
            "input_checkboxes[]"
            (* The "[]" signs to browsers that this is a list, needed because the name will be reused *)
          in
          let checkbox =
            Checkbox.make ~document ~value_name:option ~input_name:checkbox_name
              ()
          in
          Checkbox.append_element_as_child ~parent:fieldset checkbox;
          checkbox)
    in

    { element = fieldset; checkboxes; options }
end)
