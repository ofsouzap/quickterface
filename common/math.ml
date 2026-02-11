open! Core

type t =
  | Char of char
  | Literal of string
  | Infinity
  | Pi
  | E
  | Equals
  | Plus
  | Minus
  | Star
  | C_dot
  | Times
  | Divide
  | Plus_minus
  | Superscript of { base : t; superscript : t }
  | Subscript of { base : t; subscript : t }
  | Exp
  | Ln
  | Sin
  | Cos
  | List of t list
  | Frac of t * t
  | Bracketed of t
  | Partial
  | Integral of { lower : t option; upper : t option; body : t }
  | Less_than
  | Less_than_or_equal_to
  | Greater_than
  | Greater_than_or_equal_to
  | Not_equal
  | Approximately_equals
  | Equivalent_to

let rec latex_string_of_t = function
  | Char c -> Char.to_string c
  | Literal s -> s
  | Infinity -> "\\infty"
  | Pi -> "\\pi"
  | E -> "e"
  | Equals -> "="
  | Plus -> "+"
  | Minus -> "-"
  | Star -> "*"
  | C_dot -> "\\cdot"
  | Times -> "\\times"
  | Divide -> "\\div"
  | Plus_minus -> "\\pm"
  | Superscript { base; superscript } ->
      sprintf "{%s}^{%s}" (latex_string_of_t base)
        (latex_string_of_t superscript)
  | Subscript { base; subscript } ->
      sprintf "{%s}_{%s}" (latex_string_of_t base) (latex_string_of_t subscript)
  | Exp -> "\\exp"
  | Ln -> "\\ln"
  | Sin -> "\\sin"
  | Cos -> "\\cos"
  | List elements ->
      elements |> List.map ~f:latex_string_of_t |> String.concat ~sep:" "
  | Frac (num, denom) ->
      sprintf "\\frac{%s}{%s}" (latex_string_of_t num) (latex_string_of_t denom)
  | Bracketed inner -> sprintf "\\left(%s\\right)" (latex_string_of_t inner)
  | Partial -> "\\partial"
  | Integral { lower; upper; body } ->
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
      sprintf "\\int%s%s %s" lower_str upper_str (latex_string_of_t body)
  | Less_than -> "<"
  | Less_than_or_equal_to -> "\\leq"
  | Greater_than -> ">"
  | Greater_than_or_equal_to -> "\\geq"
  | Not_equal -> "\\neq"
  | Approximately_equals -> "\\approx"
  | Equivalent_to -> "\\equiv"
