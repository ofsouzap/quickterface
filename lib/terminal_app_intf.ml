open! Core

module Terminal_io = struct
  type t = { in_channel : In_channel.t; out_channel : Out_channel.t }

  let write_output_and_flush { in_channel = _; out_channel } ~text =
    Out_channel.output_string out_channel text;
    Out_channel.flush out_channel;
    Lwt.return ()

  let write_output_line_and_flush t ~text =
    write_output_and_flush t ~text:(text ^ "\n")

  let read_text ({ in_channel; out_channel = _ } as t) () =
    let%lwt () = write_output_and_flush t ~text:"> " in
    In_channel.input_line in_channel |> Option.value_exn |> Lwt.return

  let print_text t text () =
    let%lwt () = write_output_line_and_flush t ~text in
    Lwt.return ()
end

module type S = sig
  val run : unit -> unit Lwt.t
end

module Make (App : App.S) : S = struct
  module App = App (Terminal_io)

  let run =
    App.main
      ~io:
        Terminal_io.
          { in_channel = In_channel.stdin; out_channel = Out_channel.stdout }
end
