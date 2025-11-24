open! Core

module App (Io : Quickterface.Io.S) = struct
  type empty = |

  let main ~io () =
    let%lwt () = Io.print_text io "String Concatenator App" () in
    let%lwt () = Io.print_text io "message1" () in
    let%lwt () = Io.print_text io "message2" () in
    let%lwt () = Io.print_text io "retwuogsfdouqheoifeds" () in
    let rec run_looping () : empty Lwt.t =
      let%lwt x = Io.read_text io () in
      let%lwt y = Io.read_text io () in
      let%lwt () = Io.print_text io (x ^ y) () in
      run_looping ()
    in
    match%lwt run_looping () with _ -> .
end
