open! Core

module App (Io : Quickterface.Io.S) = struct
  type empty = |
  type selection = A | B | C | D

  let selection_to_string = function
    | A -> "A"
    | B -> "B"
    | C -> "C"
    | D -> "D"

  let main ~io () =
    let rec run_looping () : empty Lwt.t =
      let%lwt selections =
        Io.input_multi_selection io [ A; B; C; D ] selection_to_string ()
      in
      let%lwt () =
        Io.output_text io
          ("Output: "
          ^ String.concat ~sep:"; " (List.map ~f:selection_to_string selections)
          )
          ()
      in
      run_looping ()
    in
    match%lwt run_looping () with
    | _ -> .
end
