open! Core

type t = { items_rev : Log_item.t list }

let make () = { items_rev = [] }

let render { items_rev } =
  let open Notty.I in
  items_rev |> List.rev |> List.map ~f:Log_item.render |> vcat

let add_log_item t item = { items_rev = item :: t.items_rev }
