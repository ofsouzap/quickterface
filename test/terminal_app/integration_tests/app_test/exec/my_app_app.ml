module App : Quickterface.App.S =
functor
  (Io : Quickterface.Io.S)
  ->
  struct
    let main ~io () =
      let%lwt () = Io.output_title io "This is the title" () in
      let%lwt () = Io.output_text io "Input text" () in
      let%lwt input_string = Io.input_text io () in
      let%lwt () =
        Io.output_text io (Printf.sprintf "You gave \"%s\"" input_string) ()
      in
      let%lwt () = Io.output_text io "Input integer" () in
      let%lwt input_number = Io.input_integer io () in
      let%lwt () =
        Io.output_text io (Printf.sprintf "You gave %d" input_number) ()
      in
      let%lwt () = Io.output_text io "Input single selection" () in
      let%lwt single_selection_input =
        Io.input_single_selection io [ "A"; "B"; "C"; "D" ] ()
      in
      let%lwt () =
        Io.output_text io
          (Printf.sprintf "You chose: %s" single_selection_input)
          ()
      in
      let%lwt multi_selection_inputs =
        Io.input_multi_selection io [ "A"; "B"; "C"; "D" ] ()
      in
      let%lwt () =
        Io.output_text io
          (Printf.sprintf "You chose: %s"
             (String.concat ", " multi_selection_inputs))
          ()
      in
      let%lwt () = Io.output_text io "Here is some math" () in
      let%lwt () =
        Io.output_math io
          Quickterface.Math.(
            List
              [
                Superscript { base = E; superscript = List [ Literal "i"; Pi ] };
                Literal "-";
                Literal "1";
                Literal "=";
                Literal "0";
              ])
          ()
      in
      Lwt.return ()
  end
