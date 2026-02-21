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

  module type S1 = sig
    type 'a t
    type 'a settings
    type 'a result

    val make : 'a settings -> document:Dom_html.document Js.t -> 'a t
    val element : 'a t -> Dom_html.element Js.t
    val wait_for_input : ?auto_focus:bool -> 'a t -> unit -> 'a result Lwt.t
  end
end

module Html_input1 (Element : sig
  type 'a t
  type 'a settings
  type 'a value

  val append_element_as_child : 'a t -> parent:#Dom.node Js.t -> unit
  val reset : 'a t -> unit -> unit Lwt.t
  val make_readonly : 'a t -> unit -> unit Lwt.t
  val focus : 'a t -> unit -> unit Lwt.t
  val read_value_result : 'a t -> unit -> ('a value, Error.t) Result.t

  val make :
    document:Dom_html.document Js.t -> settings:'a settings -> unit -> 'a t
end) =
struct
  type 'a t = {
    element : Dom_html.element Js.t;
    form : Dom_html.formElement Js.t;
    input_element : 'a Element.t;
    submit_button : Dom_html.buttonElement Js.t;
  }

  let make settings ~document : 'a t =
    let container = Dom_html.createDiv document in

    let form = Dom_html.createForm document in
    Dom.appendChild container form;

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
    Dom.removeChild t.form t.submit_button;
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
            (* TODO-someday: since this is in the handler code given to the
            submit event, and not part of the Lwt computation, this error isn't
            caught by the error-handling logic and instead crashes the webapp.
            It would be nice to fix this sometime *)
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

(** This should be just the same as [Html_input1] but ignoring the type
    parameters. It's inconvenient I need to write the code like this but I can't
    think of another way *)
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
  module M = Html_input1 (struct
    include Element

    type _ t = Element.t
    type _ settings = Element.settings
    type _ value = Element.value
  end)

  include M

  (* Since I know that type parameter is ignored, I just give the empty type to it to make the signature work out *)
  type empty = |
  type t = empty M.t
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

module Text = Html_input (struct
  type t = {
    container : Dom_html.divElement Js.t;
    input : Dom_html.inputElement Js.t;
  }

  type settings = string option
  type value = string

  let append_element_as_child { container; _ } ~parent =
    Dom.appendChild parent container

  let reset { input; _ } () =
    input##.value := Js.string "";
    Lwt.return ()

  let make_readonly { input; _ } () =
    input##.readOnly := Js._true;
    Lwt.return ()

  let focus { input; _ } () =
    input##focus;
    Lwt.return ()

  let read_value_result { input; _ } () = Ok (Js.to_string input##.value)

  let make ~document ~settings:prompt () =
    let container = Dom_html.createDiv document in
    let input_field_name_string = Js.string "text_input_field" in
    let input =
      Dom_html.createInput document ~_type:(Js.string "text")
        ~name:input_field_name_string
    in

    (match prompt with
    | None -> ()
    | Some prompt ->
        let label = Dom_html.createSpan document in
        (label##.className := Class.(to_js_string Text_prompt_label));
        label##.innerText := Js.string prompt;
        Dom.appendChild container label);

    Dom.appendChild container input;

    { container; input }
end)

module Integer = Simple_html_input (struct
  type t = int

  let html_input_type = "number"

  let t_of_string_result s =
    match Int.of_string_opt s with
    | Some x -> Ok x
    | None -> Error (Error.of_string "Unable to parse string as int")
end)

module Single_selection = Html_input1 (struct
  type 'a t = {
    element : Dom_html.selectElement Js.t;
    options : 'a list;
    option_to_string : 'a -> string;
  }

  type 'a settings = 'a list * ('a -> string)
  type 'a value = 'a

  let append_element_as_child { element; _ } ~parent =
    Dom.appendChild parent element

  let reset { element; options; option_to_string } () =
    element##.value := Js.string (option_to_string (List.hd_exn options));
    Lwt.return ()

  let make_readonly { element; _ } () =
    element##.disabled := Js._true;
    Lwt.return ()

  let focus { element; _ } () =
    element##focus;
    Lwt.return ()

  let read_value_result { element; options; option_to_string = _ } () =
    let open Result.Let_syntax in
    let%bind input_index =
      Js.to_string element##.value
      |> Int.of_string_opt
      |> Result.of_option ~error:(Error.of_string "Input value was not integer")
    in
    List.nth options input_index
    |> Result.of_option ~error:(Error.of_string "Input index out of range")

  let make ~document ~settings:(options, option_to_string) () =
    match options with
    | [] -> failwith "No options provided"
    | _ :: _ ->
        let input_field_name_string = Js.string "select_input" in
        let element =
          Dom_html.createSelect document ~name:input_field_name_string
        in
        List.iteri options ~f:(fun i option ->
            let option_element = Dom_html.createOption document in
            option_element##.innerText := Js.string (option_to_string option);
            option_element##.value := Js.string (string_of_int i);
            Dom.appendChild element option_element);
        { element; options; option_to_string }
end)

module Multi_selection = Html_input1 (struct
  module Checkbox = struct
    type t = {
      element : Dom_html.element Js.t;
      checkbox : Dom_html.inputElement Js.t;
      value_index : int;
    }

    let append_element_as_child { element; _ } ~parent =
      Dom.appendChild parent element

    let reset { checkbox; _ } () = checkbox##.checked := Js._false
    let make_readonly { checkbox; _ } () = checkbox##.disabled := Js._true
    let is_checked { checkbox; _ } () = Js.to_bool checkbox##.checked
    let value_index { value_index; _ } = value_index

    let make ~document ~value_name ~input_name ~value_index () =
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
        value_index;
      }
  end

  type 'a t = {
    element : Dom_html.fieldSetElement Js.t;
    checkboxes : Checkbox.t list;
    options : 'a list;
    option_to_string : 'a -> string;
  }

  type 'a settings = 'a list * ('a -> string)
  type 'a value = 'a list

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

  let read_value_result
      { element = _; checkboxes; options; option_to_string = _ } () =
    List.fold_result checkboxes ~init:[] ~f:(fun acc checkbox ->
        if Checkbox.is_checked checkbox () then
          let value_index = Checkbox.value_index checkbox in
          let%bind.Result option =
            List.nth options value_index
            |> Result.of_option
                 ~error:
                   (Error.of_string
                      (sprintf "Checkbox index %d is not in range" value_index))
          in
          Ok (option :: acc)
        else
          (* Don't add as not checked *)
          Ok acc)
    |> Result.map ~f:List.rev

  let make ~document ~settings:(options, option_to_string) () =
    let fieldset = Dom_html.createFieldset document in

    let checkboxes =
      List.mapi options ~f:(fun i option ->
          let checkbox_name =
            "input_checkboxes[]"
            (* The "[]" signs to browsers that this is a list, needed because the name will be reused *)
          in
          let checkbox =
            Checkbox.make ~document ~value_name:(option_to_string option)
              ~input_name:checkbox_name ~value_index:i ()
          in
          Checkbox.append_element_as_child ~parent:fieldset checkbox;
          checkbox)
    in

    { element = fieldset; checkboxes; options; option_to_string }
end)
