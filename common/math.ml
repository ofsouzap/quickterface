open! Core

type t =
  | Literal of string
  | Infinity
  | Pi
  | E
  | Plus
  | Star
  | C_dot
  | Superscript of { base : t; superscript : t }
  | Subscript of { base : t; subscript : t }
  | Exp
  | Ln
  | List of t list
  | Frac of t * t
  | Bracketed of t
  | Partial
  | Integral of { lower : t option; upper : t option }

let rec latex_string_of_t = function
  | Literal s -> s
  | Infinity -> "\\infty"
  | Pi -> "\\pi"
  | E -> "e"
  | Plus -> "+"
  | Star -> "*"
  | C_dot -> "\\cdot"
  | Superscript { base; superscript } ->
      sprintf "{%s}^{%s}" (latex_string_of_t base)
        (latex_string_of_t superscript)
  | Subscript { base; subscript } ->
      sprintf "{%s}_{%s}" (latex_string_of_t base) (latex_string_of_t subscript)
  | Exp -> "\\exp"
  | Ln -> "\\ln"
  | List elements ->
      elements |> List.map ~f:latex_string_of_t |> String.concat ~sep:" "
  | Frac (num, denom) ->
      sprintf "\\frac{%s}{%s}" (latex_string_of_t num) (latex_string_of_t denom)
  | Bracketed inner -> sprintf "\\left(%s\\right)" (latex_string_of_t inner)
  | Partial -> "\\partial"
  | Integral { lower; upper } ->
      let lower_str =
        match lower with
        | None -> ""
        | Some l -> sprintf "_{%s}" (latex_string_of_t l)
      in
      let upper_str =
        match upper with
        | None -> ""
        | Some u -> sprintf "^{%s}" (latex_string_of_t u)
      in
      sprintf "\\int%s%s" lower_str upper_str
