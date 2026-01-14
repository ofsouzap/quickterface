open! Core

module App (Io : Quickterface.Io.S) = struct
  let main ~io () =
    let%lwt () = Io.output_text io "Math App" () in
    let%lwt () =
      Io.output_math io
        (let open Quickterface.Math in
         List
           [
             Pi;
             C_dot;
             Integral { lower = Some (Literal "0"); upper = Some Infinity };
             Frac
               (Literal "x", Bracketed (List [ Literal "1"; Plus; Literal "x" ]));
             Literal "dx";
           ])
        ()
    in
    let%lwt _ =
      Io.output_text
        ~options:
          Quickterface.
            {
              Output_text_options.channel_options =
                Output_channel_options.Error_channel;
            }
        io "error message??" ()
    in
    let%lwt () =
      Io.output_math
        ~options:
          Quickterface.
            {
              Output_text_options.channel_options =
                Default_output_channel { color = Quickterface.Color.blue };
            }
        io
        (let open Quickterface.Math in
         List
           [
             E;
             Superscript (List [ Literal "i"; Frac (Literal "π", Literal "2") ]);
           ])
        ()
    in
    let%lwt () =
      Io.output_math io
        (let open Quickterface.Math in
         E)
        ()
    in
    let%lwt x = Io.input_integer io () in
    let%lwt () =
      Io.output_math io
        (let open Quickterface.Math in
         List [ E; Superscript (Literal (string_of_int x)) ])
        ()
    in
    Lwt.return ()
end
