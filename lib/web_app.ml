open! Core
open Js_of_ocaml

module type S = sig
  val run : unit -> unit Lwt.t
end

module Web_app_io = struct
  module Log = struct
    module Output_text = struct
      type t = { element : Dom_html.element Js.t }

      let make ~document ~text =
        let item_div = Dom_html.createDiv document in
        item_div##.className := Js.string "quickterface__log-item";
        let newP = (Dom_html.createP document :> Dom_html.element Js.t) in
        newP##.innerText := Js.string text;
        Dom.appendChild item_div newP;
        Lwt.return { element = item_div }
    end

    module Input_text = struct
      type t = {
        element : Dom_html.element Js.t;
        text_input_field : Dom_html.inputElement Js.t;
        text_input_field_submit_button : Dom_html.buttonElement Js.t;
      }

      let make ~document : t =
        let container = Dom_html.createDiv document in
        container##.className := Js.string "quickterface__inputs-container";
        let text_input_field =
          Dom_html.createInput document ~_type:(Js.string "text")
        in
        Dom.appendChild container text_input_field;
        let text_input_field_submit_button = Dom_html.createButton document in
        text_input_field_submit_button##.innerText := Js.string "Submit";
        Dom.appendChild container text_input_field_submit_button;
        {
          element = container;
          text_input_field;
          text_input_field_submit_button;
        }

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

    type t = {
      document : Dom_html.document Js.t;
      container : Dom_html.divElement Js.t;
    }

    let make ~document ~main_container : t =
      let container = Dom_html.createDiv document in
      container##.className := Js.string "quickterface__log-container";
      Dom.appendChild main_container container;
      let log_spacer = Dom_html.createDiv document in
      log_spacer##.className := Js.string "quickterface__log-spacer";
      Dom.appendChild container log_spacer;
      { document; container }

    let add_output_text { document; container } ~text () =
      let%lwt element = Output_text.make ~document ~text in
      Dom.appendChild container element.element;
      Lwt.return ()

    let read_input_text { document; container } () =
      let input_text = Input_text.make ~document in
      Dom.appendChild container input_text.element;
      Input_text.wait_for_text_input input_text ()
  end

  type t = { log : Log.t }

  let create_stylesheet_element document =
    let style_element = Dom_html.createStyle document in
    let css =
      {|
body {
    background-color: #0b1d40ff;
    width: 100%;
    height: 100%;
    margin: 0;
}

.quickterface__main-container {
    position: fixed;
    top: 0;
    bottom: 0;
    left: 0;
    right: 0;
    display: flex;
    flex-direction: column;
    height: 100%;
    width: 100%;
}

.quickterface__inputs-container {
    min-height: 100px;
}

.quickterface__log-container {
    height: 100%;
    display: flex;
    flex-direction: column;
    overflow-y: auto;
    color: #eee;
    padding: 8px;
    font-size: 14px;
    font-family: "Fira Code", Menlo, Consolas, monospace;
}

.quickterface__log-spacer {
    flex-grow: 1;
}

.quickterface__log-item {
    margin: 1px 1px 1px 1px;
}
|}
    in
    style_element##.innerHTML := Js.string css;
    style_element

  let make () : t =
    let document = Dom_html.document in
    Dom.appendChild Dom_html.document##.head
      (create_stylesheet_element document);
    let main_container = Dom_html.createDiv document in
    main_container##.className := Js.string "quickterface__main-container";
    let log = Log.make ~document ~main_container in
    Dom.appendChild document##.body main_container;
    { log }

  let read_text t () = Log.read_input_text t.log ()
  let print_text t text () = Log.add_output_text t.log ~text ()
end

module Make (App : App.S) : S = struct
  module App = App (Web_app_io)

  let run () =
    let io = Web_app_io.make () in
    App.main ~io ()
end
