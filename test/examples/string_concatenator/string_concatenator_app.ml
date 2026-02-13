open! Core

module App (Io : Quickterface.Io.S) = struct
  type empty = |

  module Concat_mode = struct
    type t = First_first | First_last

    let all = [ First_first; First_last ]

    let to_string = function
      | First_first -> "first first"
      | First_last -> "first last"
  end

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
        Io.input_single_selection io Concat_mode.all Concat_mode.to_string ()
      in
      let f =
        match mode with
        | First_first -> fun x y -> x ^ y
        | First_last -> fun x y -> y ^ x
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
    match%lwt run_looping () with
    | _ -> .
end
