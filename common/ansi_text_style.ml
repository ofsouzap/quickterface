open! Core

type t =
  | Reset
  | T of {
      bold : bool;
      foreground_color : Color.t option;
      background_color : Color.t option;
    }

let reset = Reset

let make ?(bold = false) ?foreground_color ?background_color () =
  T { bold; foreground_color; background_color }

let ansi_code t =
  "\x1b["
  ^ (match t with
    | Reset -> ""
    | T { bold; foreground_color; background_color } ->
        let codes =
          List.filter_map ~f:Fn.id
            [
              Some (if bold then "1" else "22");
              Option.map foreground_color ~f:(fun color ->
                  sprintf "%d" (Color.ansi_color_code color));
              Option.map background_color ~f:(fun color ->
                  sprintf "%d" (Color.ansi_color_code color + 10));
            ]
        in
        String.concat ~sep:";" codes)
  ^ "m"

let wrap_text t ~text = ansi_code t ^ text ^ ansi_code reset
