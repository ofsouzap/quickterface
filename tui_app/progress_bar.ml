open! Core

type t = { config : Progress_bar_config.t; current_value : int }
[@@deriving sexp, fields]

let maximum_value { config = { maximum_value; _ }; _ } = maximum_value
let make ?(current_value = 0) ~config () = { config; current_value }

let increment t =
  if current_value t < maximum_value t then
    { t with current_value = t.current_value + 1 }
  else
    raise_s
      [%message "Cannot increment loading bar beyond maximum value" (t : t)]

let render ~render_info { config = { label; maximum_value }; current_value } =
  let open Notty.I in
  let margin = { Notty_utils.Sides.left = 1; right = 1; top = 1; bottom = 1 } in

  let title_img =
    Option.value_map label ~default:empty ~f:(fun label ->
        string Theme.loading_bar_title label)
  in

  let bar_img =
    let progress_text =
      (* E.g. "20/40 (50%)" *)
      sprintf "%d/%d (%.1f%%)" current_value maximum_value
        Float.(of_int 100 * of_int current_value / of_int maximum_value)
    in
    let progress_text_img =
      string Theme.loading_bar_text progress_text |> hpad 1 1
    in

    let left_edge_img = char Theme.loading_bar_bar_edges '[' 1 1 in
    let right_edge_img = char Theme.loading_bar_bar_edges ']' 1 1 in

    let bar_img_width =
      render_info.Render_info.screen_width - width progress_text_img
      - width left_edge_img - width right_edge_img - margin.left - margin.right
    in
    if bar_img_width <= 0 then
      raise_s
        [%message
          "Not enough room to render progress bar"
            (render_info.Render_info.screen_width : int)];

    let cell_progress_uchars =
      Notty_utils.
        [
          Uchar.of_char ' ';
          uchar_left_block_one_eighth;
          uchar_left_block_one_quarter;
          uchar_left_block_three_eighths;
          uchar_left_block_half;
          uchar_left_block_five_eighths;
          uchar_left_block_three_quarters;
          uchar_left_block_seven_eighths;
          uchar_left_block_full;
        ]
    in
    let progress_cells_per_cell = List.length cell_progress_uchars in
    let total_progress_cells = bar_img_width * progress_cells_per_cell in
    let progress_cells_filled =
      Float.(
        of_int total_progress_cells
        * of_int current_value / of_int maximum_value)
      |> Float.round |> Int.of_float
    in
    let progress_cells_img =
      List.init bar_img_width ~f:(fun cell_index ->
          let start_progress_cell = cell_index * progress_cells_per_cell in
          let relative_progress_cell =
            progress_cells_filled - start_progress_cell
          in
          if relative_progress_cell < 0 then Uchar.of_char ' '
          else if relative_progress_cell >= progress_cells_per_cell then
            List.last_exn cell_progress_uchars
          else List.nth_exn cell_progress_uchars relative_progress_cell)
      |> Array.of_list
      |> uchars Theme.loading_bar_bar_cells
    in

    left_edge_img <|> progress_cells_img <|> right_edge_img
    <|> progress_text_img
  in

  (Notty_utils.Sides.pad margin) (title_img <-> bar_img)
