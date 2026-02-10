open! Core
open Quickterface.Io

type t = { in_channel : In_channel.t; out_channel : Out_channel.t }

module Http_client = Cohttp_lwt_unix.Client

let write_output
    ?options:({ Quickterface.Output_text_options.color } =
        Quickterface.Output_text_options.default) ?(flush = true)
    { in_channel = _; out_channel } ~text =
  let formatted_text =
    match color with
    | `Default -> text
    | `Custom color ->
        Quickterface.Ansi_text_style.(
          wrap_text (make ~foreground_color:color ()) ~text)
  in
  Out_channel.output_string out_channel formatted_text;
  if flush then Out_channel.flush out_channel;
  Lwt.return ()

let write_output_line ?options ?flush t ~text =
  write_output ?options ?flush t ~text:(text ^ "\n")

let input_text ({ in_channel; out_channel = _ } as t) () =
  let%lwt () = write_output ~flush:true t ~text:"> " in
  In_channel.input_line in_channel |> Option.value_exn |> Lwt.return

let input_integer ({ in_channel; out_channel = _ } as t) () =
  let rec get_input_integer () =
    (* Get an input *)
    let%lwt () = write_output ~flush:true t ~text:"> " in
    let input_string = In_channel.input_line in_channel |> Option.value_exn in

    (* Try read it as an integer *)
    match Int.of_string_opt input_string with
    | Some x -> Lwt.return x
    | None ->
        let%lwt () =
          write_output_line ~flush:true t
            ~text:"[Invalid input. Input must be an integer]"
        in
        get_input_integer ()
  in

  get_input_integer ()

let input_single_selection ({ in_channel; out_channel = _ } as t) options () =
  (* Print the options *)
  let%lwt () =
    write_output_line t ~flush:true ~text:"[Select an option from the below]"
  in
  let option_printers =
    List.mapi options ~f:(fun i option ->
        let i_string = string_of_int i in
        write_output_line t ~flush:false
          ~text:[%string "  [%{i_string}] %{option}"])
  in
  let%lwt _ = Lwt.all option_printers in

  (* Helpers for parsing the input *)
  let read_input input_string =
    let read_input_as_index input_string =
      match Int.of_string_opt input_string with
      | Some x -> (
          match List.nth options x with
          | Some value -> `Is_valid value
          | None -> `Out_of_range)
      | None -> `Not_integer
    in
    let read_input_as_value_name input_string =
      List.fold_result options ~init:() ~f:(fun () option ->
          if String.equal option input_string then Error option else Ok ())
      |> function
      | Ok () -> `No_match
      | Error value -> `Is_valid value
    in
    match read_input_as_index input_string with
    | `Is_valid value -> Ok value
    | `Out_of_range -> Error "index provided is out of range"
    | `Not_integer -> (
        match read_input_as_value_name input_string with
        | `Is_valid value -> Ok value
        | `No_match -> Error "input is not name of option or index of option")
  in

  (* Get the selected option *)
  let rec get_input () =
    (* Get an input *)
    let%lwt () = write_output ~flush:true t ~text:"> " in
    let input_string = In_channel.input_line in_channel |> Option.value_exn in
    match read_input input_string with
    | Ok value -> Lwt.return value
    | Error error_message ->
        let%lwt () =
          write_output_line ~flush:true t
            ~text:[%string "[Invalid input: %{error_message}]"]
        in
        get_input ()
  in

  get_input ()

let input_multi_selection ({ in_channel; out_channel = _ } as t) options () =
  (* Print instructions *)
  let%lwt () =
    write_output_line t ~flush:true
      ~text:
        "[Enter an option to toggle selecting it. Press ENTER without \
         selecting anything to submit the selection]"
  in

  (* Printing the options *)
  let print_options_state ~selected_options =
    let option_printers =
      List.mapi options ~f:(fun i option ->
          let i_string = string_of_int i in
          let selected_mark =
            (if Set.mem selected_options option then 'X' else ' ')
            |> String.of_char
          in
          write_output_line t ~flush:false
            ~text:[%string "  [%{selected_mark}] [%{i_string}] %{option}"])
    in
    let%lwt _ = Lwt.all option_printers in
    Lwt.return ()
  in

  (* Helpers for parsing the input *)
  let read_input input_string =
    let read_input_as_index input_string =
      match Int.of_string_opt input_string with
      | Some x -> (
          match List.nth options x with
          | Some value -> `Is_valid value
          | None -> `Out_of_range)
      | None -> `Not_integer
    in
    let read_input_as_value_name input_string =
      List.fold_result options ~init:() ~f:(fun () option ->
          if String.equal option input_string then Error option else Ok ())
      |> function
      | Ok () -> `No_match
      | Error value -> `Is_valid value
    in
    match read_input_as_index input_string with
    | `Is_valid value -> Ok value
    | `Out_of_range -> Error "index provided is out of range"
    | `Not_integer -> (
        match read_input_as_value_name input_string with
        | `Is_valid value -> Ok value
        | `No_match -> Error "input is not name of option or index of option")
  in

  (* Get the selected options *)
  let rec get_input ~selected_options () =
    (* Get an input *)
    let%lwt () = print_options_state ~selected_options in
    let%lwt () = write_output ~flush:true t ~text:"> " in
    let input_string = In_channel.input_line in_channel |> Option.value_exn in
    match input_string with
    | "" ->
        (* If nothing entered, submit the selections *)
        Lwt.return selected_options
    | _ -> (
        match read_input input_string with
        | Ok selection_to_toggle ->
            (* Toggle the selected option *)
            let new_selected_options =
              if Set.mem selected_options selection_to_toggle then
                Set.remove selected_options selection_to_toggle
              else Set.add selected_options selection_to_toggle
            in
            get_input ~selected_options:new_selected_options ()
        | Error error_message ->
            let%lwt () =
              write_output_line ~flush:true t
                ~text:[%string "[Invalid input: %{error_message}]"]
            in
            get_input ~selected_options ())
  in
  let%lwt selected_options = get_input ~selected_options:String.Set.empty () in
  Lwt.return (Set.to_list selected_options)

let input : type settings a.
    _ -> (settings, a) Input.t -> settings -> unit -> a Lwt.t =
 fun t -> function
  | Text -> fun () -> input_text t
  | Integer -> fun () -> input_integer t
  | Single_selection -> fun options -> input_single_selection t options
  | Multi_selection -> fun options -> input_multi_selection t options

let output_text ?options t text () =
  let%lwt () = write_output_line ?options ~flush:true t ~text in
  Lwt.return ()

let output_math ?options t (math : Quickterface.Math.t) () =
  let open Quickterface.Math in
  let rec math_to_string = function
    | Literal s -> s
    | Infinity -> "∞"
    | Pi -> "π"
    | E -> "e"
    | Plus -> "+"
    | Star -> "*"
    | C_dot -> "·"
    | Superscript { base; superscript } ->
        Printf.sprintf "(%s)^(%s)" (math_to_string base)
          (math_to_string superscript)
    | Subscript { base; subscript } ->
        Printf.sprintf "(%s)_(%s)" (math_to_string base)
          (math_to_string subscript)
    | Exp -> "exp"
    | Ln -> "ln"
    | List elements ->
        elements |> List.map ~f:math_to_string |> String.concat ~sep:" "
    | Frac (num, denom) ->
        Printf.sprintf "(%s)/(%s)" (math_to_string num) (math_to_string denom)
    | Bracketed inner -> Printf.sprintf "(%s)" (math_to_string inner)
    | Partial -> "∂"
    | Integral { lower; upper; body } ->
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
        Printf.sprintf "∫%s%s %s" lower_str upper_str (math_to_string body)
  in
  let math_string = math_to_string math in
  let%lwt () = write_output_line ?options ~flush:true t ~text:math_string in
  Lwt.return ()

let output_title t text () =
  let title_length = String.length text in
  let border_line = String.init (title_length + 4) ~f:(Fn.const '#') in
  let title_line = [%string "# %{text} #"] in
  write_output t ~flush:true
    ~text:[%string "%{border_line}\n%{title_line}\n%{border_line}\n\n"]

let output : type options a.
    ?options:options -> _ -> (options, a) Output.t -> a -> unit -> unit Lwt.t =
 fun ?options t -> function
  | Text -> fun x -> output_text ?options t x
  | Math -> fun x -> output_math ?options t x
  | Title -> ( fun x -> match options with None | Some () -> output_title t x)

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

let make () =
  { in_channel = In_channel.stdin; out_channel = Out_channel.stdout }
