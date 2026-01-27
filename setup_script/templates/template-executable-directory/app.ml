module App : Quickterface.App.S =
functor
  (Io : Quickterface.Io.S)
  ->
  struct
    let main ~io () =
      (* TODO - write your code in this function *)
      let%lwt () = Io.output_text io "What is your name?" () in
      let%lwt name = Io.input_text io () in
      Io.output_text io ("Hello, " ^ name ^ "!\n") ()
  end
