module App : Quickterface.App.S =
functor
  (Io : Quickterface.Io.S)
  ->
  struct
    let main ~io () =
      let%lwt () = Io.output_title io "Simple text IO app" () in
      let%lwt () = Io.output_text io "What is your name?" () in
      let%lwt name = Io.input_text io () in
      let%lwt () = Io.output_text io ("Hello, " ^ name ^ "!") () in
      Lwt.return ()
  end
