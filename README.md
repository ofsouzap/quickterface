# Quickterface

Quick-to-program app interfaces in OCaml for terminal and web.

## Overview

Quickterface is an OCaml library that lets you write interactive applications once and run them both as terminal UIs (TUIs) and web applications. Write your app logic using a simple IO interface, and Quickterface handles the rendering for both platforms.

## Features

- **Write Once, Run Anywhere**: Same code runs in terminal and browser
- **Easy Setup**: Includes a setup script executable to quickly create a Quickterface app in an existing Dune projects
- **Rich Terminal UI**: Built on Notty with full TUI support
- **Web Applications**: Automatically generates web interfaces using js_of_ocaml
- **Input Types**: Text, integers, single/multi-selection
- **Output Types**: Text, titles, and mathematical notation (via KaTeX)
- **Async Support**: Built with Lwt for asynchronous operations
- **HTTP Client**: Integrated Cohttp support for network requests

## Installation

```bash
opam install quickterface
```

## Quick Start

Create an app by defining a functor that takes an `Io` module:

```ocaml
module App : Quickterface.App.S =
functor (Io : Quickterface.Io.S) ->
struct
  let main ~io () =
    let%lwt () = Io.output_title io "My App" () in
    let%lwt () = Io.output_text io "What is your name?" () in
    let%lwt name = Io.input_text io () in
    let%lwt () = Io.output_text io ("Hello, " ^ name ^ "!") () in
    Lwt.return ()
end
```

### Terminal App

```ocaml
module Terminal = Quickterface.Terminal_app.Make(App)

let () = Terminal.command ~argv:Sys.argv ()
```

### Web App

```ocaml
module Web = Quickterface.Web_app.Make(App)

let () = Lwt_main.run (Web.run ())
```

## Examples

See the `test/examples/` directory for complete working examples including:
- Simple text IO
- String concatenator
- Math rendering
- Multi-select inputs
- Weather app (with HTTP requests)

## License

MIT

## Author

Ofsouzap <ofsouzap@gmail.com>
