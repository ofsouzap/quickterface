open! Core

module Terminal_io = struct
  type t = { in_channel : In_channel.t; out_channel : Out_channel.t }

  module Http_client = Cohttp_lwt_unix.Client

  let write_output
      ?options:({ Quickterface.Output_text_options.color } =
          Quickterface.Output_text_options.default) ?(flush = true)
      { in_channel = _; out_channel } ~text =
    let formatted_text =
      let set_color = Quickterface.Color.ansi_color_code color in
      let reset_color =
        Quickterface.Color.(ansi_color_code default_foreground)
      in
      [%string "%{set_color}%{text}%{reset_color}"]
    in
    Out_channel.output_string out_channel formatted_text;
    if flush then Out_channel.flush out_channel;
    Lwt.return ()

  let write_output_line ?options ?flush t ~text =
    write_output ?options ?flush t ~text:(text ^ "\n")

  let read_text ({ in_channel; out_channel = _ } as t) () =
    let%lwt () = write_output ~flush:true t ~text:"> " in
    In_channel.input_line in_channel |> Option.value_exn |> Lwt.return

  let print_text ?options t text () =
    let%lwt () = write_output_line ?options ~flush:true t ~text in
    Lwt.return ()

  let print_math ?options t (math : Quickterface.Math.t) () =
    let open Quickterface.Math in
    let rec math_to_string = function
      | Literal s -> s
      | Infinity -> "∞"
      | Pi -> "π"
      | E -> "e"
      | Plus -> "+"
      | Star -> "*"
      | C_dot -> "·"
      | Superscript inner -> Printf.sprintf "^(%s)" (math_to_string inner)
      | Subscript inner -> Printf.sprintf "_(%s)" (math_to_string inner)
      | Exp -> "exp"
      | Ln -> "ln"
      | List elements ->
          elements |> List.map ~f:math_to_string |> String.concat ~sep:" "
      | Frac (num, denom) ->
          Printf.sprintf "(%s)/(%s)" (math_to_string num) (math_to_string denom)
      | Bracketed inner -> Printf.sprintf "(%s)" (math_to_string inner)
      | Partial -> "∂"
      | Integral { lower; upper } ->
          let lower_str =
            match lower with
            | None -> ""
            | Some l -> Printf.sprintf "_(%s)" (math_to_string l)
          in
          let upper_str =
            match upper with
            | None -> ""
            | Some u -> Printf.sprintf "^(%s)" (math_to_string u)
          in
          Printf.sprintf "∫%s%s" lower_str upper_str
    in
    let math_string = math_to_string math in
    let%lwt () = write_output_line ?options ~flush:true t ~text:math_string in
    Lwt.return ()

  let with_progress_bar ?label t ~maximum ~f () =
    let bar_width = 30 in
    let bar_character = '#' in
    let curr_value = ref 0 in
    let bar_string ~curr_value =
      let curr_bars =
        (* Note, this arithmetic evaluation order is necessary for the integer division to not collapse to 0 *)
        curr_value * bar_width / maximum
      in
      let rem_bars = bar_width - curr_bars in
      Printf.sprintf " %s[%s%s] %d/%d"
        (Option.value_map label ~default:"" ~f:(fun l -> l ^ " "))
        (String.init curr_bars ~f:(fun _ -> bar_character))
        (String.init rem_bars ~f:(fun _ -> ' '))
        curr_value maximum
    in
    let update_bar () =
      let%lwt () = write_output ~flush:false t ~text:"\r" in
      write_output ~flush:true t ~text:(bar_string ~curr_value:!curr_value)
    in
    let increment_progress_bar () =
      curr_value := !curr_value + 1;
      update_bar ()
    in
    let%lwt () = update_bar () in
    let%lwt result = f ~increment_progress_bar () in
    let%lwt () = write_output ~flush:true t ~text:"\n" in
    Lwt.return result
end

module type S = sig
  val run : unit -> unit Lwt.t
end

module Make (App : Quickterface.App.S) : S = struct
  module App = App (Terminal_io)

  let run =
    App.main
      ~io:
        Terminal_io.
          { in_channel = In_channel.stdin; out_channel = Out_channel.stdout }
end
