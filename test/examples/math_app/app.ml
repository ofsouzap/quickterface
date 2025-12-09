open! Core

module App (Io : Quickterface.Io.S) = struct
  let main ~io () =
    let%lwt () = Io.print_text io "Math App" () in
    let%lwt () =
      Io.print_math io
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
    Lwt.return ()
end
