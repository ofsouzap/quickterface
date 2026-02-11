open! Core

module App (Io : Quickterface.Io.S) = struct
  type empty = |

  let main ~io () =
    let%lwt () = Io.output_text io "message1" () in
    let%lwt () = Io.output_text io "message2" () in
    let%lwt () =
      Io.output_text io
        "retwuogsfdouqheoifefjsernfljsnfglsdnfsdljkfsdljkflsdkflkjsefsdhlfjksdkfjslfjkds"
        ()
    in
    let%lwt () = Io.output_text io "Thingy1\nAnother thing\nmore" () in
    let rec run_looping ?(i = 0) () : empty Lwt.t =
      let i_str = string_of_int i in
      let%lwt () =
        Io.output_title io [%string "String Concatenator App (run %{i_str})"] ()
      in
      let%lwt x = Io.input_text io () in
      let%lwt y = Io.input_text io () in
      let%lwt mode =
        Io.input_single_selection io [ "first first"; "first last" ] ()
      in
      let f =
        match mode with
        | "first first" -> fun x y -> x ^ y
        | "first last" -> fun x y -> y ^ x
        | _ -> assert false
      in
      let%lwt res =
        Io.with_progress_bar io ~label:"Concatenating" ~maximum:10
          ~f:(fun ~increment_progress_bar () ->
            let rec loop n =
              if n = 0 then Lwt.return ()
              else
                let%lwt () = increment_progress_bar () in
                loop (n - 1)
            in
            let%lwt () = loop 10 in
            Lwt.return (f x y))
          ()
      in
      let%lwt () = Io.output_text io res () in
      run_looping ~i:(i + 1) ()
    in
    match%lwt run_looping () with _ -> .
end
