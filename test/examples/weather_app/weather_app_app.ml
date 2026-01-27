open! Core

module App (Io : Quickterface.Io.S) = struct
  let main ~io () =
    let%lwt () = Io.output_text io "Weather App" () in
    let%lwt () = Io.output_text io "I will now fetch the weather!" () in
    let%lwt _response, body =
      Io.Http_client.get (Uri.of_string "http://wttr.in/?format=3")
    in
    let%lwt body_string = Cohttp_lwt.Body.to_string body in
    let%lwt () = Io.output_text io body_string () in
    Lwt.return ()
end
