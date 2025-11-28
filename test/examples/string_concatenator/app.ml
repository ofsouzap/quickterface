open! Core

module App (Io : Quickterface.Io.S) = struct
  type empty = |

  let main ~io () =
    let%lwt () = Io.print_text io "String Concatenator App" () in
    let%lwt () = Io.print_text io "message1" () in
    let%lwt () = Io.print_text io "message2" () in
    let%lwt () =
      Io.print_text io
        "retwuogsfdouqheoifefjsernfljsnfglsdnfsdljkfsdljkflsdkflkjsefsdhlfjksdkfjslfjkds"
        ()
    in
    let rec run_looping () : empty Lwt.t =
      let%lwt x = Io.read_text io () in
      let%lwt y = Io.read_text io () in
      let%lwt res =
        Io.with_progress_bar io ~label:"Concatenating" ~maximum:1_000_000
          ~f:(fun ~increment_progress_bar () ->
            let rec loop n =
              if n = 0 then Lwt.return ()
              else
                let%lwt () = increment_progress_bar () in
                loop (n - 1)
            in
            let%lwt () = loop 1_000_000 in
            Lwt.return (x ^ y))
          ()
      in
      let%lwt () = Io.print_text io res () in
      run_looping ()
    in
    match%lwt run_looping () with _ -> .
end
