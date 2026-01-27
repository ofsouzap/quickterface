open! Core

module App (Io : Quickterface.Io.S) = struct
  type empty = |

  let main ~io () =
    let rec run_looping () : empty Lwt.t =
      let%lwt selections =
        Io.input_multi_selection io [ "A"; "B"; "C"; "D" ] ()
      in
      let%lwt () =
        Io.output_text io ("Output: " ^ String.concat ~sep:"; " selections) ()
      in
      run_looping ()
    in
    match%lwt run_looping () with _ -> .
end
