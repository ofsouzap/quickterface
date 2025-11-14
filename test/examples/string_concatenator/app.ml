open! Core

module App (Io : Quickterface.Io.S) = struct
  let main ~io () =
    let%lwt x = Io.read_text io () in
    let%lwt y = Io.read_text io () in
    let%lwt () = Io.print_text io (x ^ y) () in
    Lwt.return ()
end
