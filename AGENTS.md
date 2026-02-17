# AGENTS.md - Quickterface Project Documentation

## Project Overview

**Quickterface** is an OCaml library that enables developers to write interactive applications once and run them both as Terminal User Interfaces (TUIs) and web applications. The project uses a functor-based architecture to abstract the IO layer, allowing the same application logic to work across different platforms.

- **Repository**: ofsouzap/quickterface
- **Language**: OCaml 5.1.0+
- **Build System**: Dune 3.20+
- **License**: MIT
- **Version**: 0.1.0 (work-in-progress)
- **Author**: Ofsouzap <ofsouzap@gmail.com>

## Core Philosophy

The project's key insight is **platform abstraction through functors**. Applications are written as functors that take an `Io` module, which provides platform-agnostic input/output operations. Concrete implementations exist for:
1. **Terminal**: Using Notty for TUI rendering (with an option for a much more simplistic (named "minimal") UI that doesn't use any ANSI commands)
2. **Web**: Using js_of_ocaml to create a webpage with a fixed layout, to take the onus away from the programmer

## Architecture

### High-Level Structure

```
quickterface (library root)
├── common/               # Core abstractions and shared code
├── terminal_app/         # Terminal UI implementation
├── web_app/             # Web app interface (thin wrapper)
├── web_app_backend/     # Web app implementation (js_of_ocaml)
├── setup_script/        # CLI tool for scaffolding new apps
└── test/                # Tests and example applications
    ├── examples/        # Working example apps
    └── terminal_app/    # Terminal app tests
```

### Module Hierarchy

#### Core Library (`common/`)
- **`io.ml`**: Defines the IO abstraction signature (`Io.S`)
- **`app.ml`**: Defines the App functor signature (`App.S`)
- **`math.ml`**: Mathematical notation types
- **`color.ml`**: Color handling
- **`output_text_options.ml`**: Options for text output styling

#### Terminal App (`terminal_app/`)
- **`terminal_app_intf.mli`**: Interface for terminal implementations
- **`tui_terminal_io.ml`**: Full TUI implementation using Notty
- **`minimal_terminal_io.ml`**: Simple terminal IO without fancy UI
- **`window.ml`**: TUI window management
- **`log.ml`**: Output log management
- **`input_field.ml`**: Input field widgets
- **`progress_bar.ml`**: Progress bar widget
- **`theme.ml`**: UI theming
- **`notty_utils.ml`**: Utilities for Notty library

#### Web App (`web_app/` + `web_app_backend/`)
- **`web_app/web_app_intf.mli`**: Interface for web implementations
- **`web_app_backend/app.ml`**: Main web app implementation
- **`web_app_backend/inputs.ml`**: Input widgets for web
- **`web_app_backend/outputs.ml`**: Output rendering for web
- **`web_app_backend/log.ml`**: Web-based log display
- **`web_app_backend/katex_setup.ml`**: KaTeX integration for math
- **`web_app_backend/stylesheet.ml`**: CSS generation
- **`web_app_backend/utils.ml`**: Web utilities

#### Setup Script (`setup_script/`)
- **`main.ml`**: CLI entry point using Cmdliner
- **`templates.ml`**: Template generation logic

## Key Concepts

### 1. Functor-Based Application Pattern

Applications are written as functors of type `App.S`:

```ocaml
module type S = functor (Io : Io.S) -> sig
  val main : io:Io.t -> unit -> unit Lwt.t
end
```

Example:
```ocaml
module MyApp (Io : Quickterface.Io.S) = struct
  let main ~io () =
    let%lwt () = Io.output_title io "Hello" () in
    let%lwt name = Io.input_text io () in
    let%lwt () = Io.output_text io ("Hi, " ^ name) () in
    Lwt.return ()
end
```

### 2. IO Abstraction (`Io.S`)

The `Io.S` signature defines platform-agnostic IO operations:

**Input Types**:
- `Text`: String input with optional prompt
- `Integer`: Integer input
- `Single_selection`: Choose one from a list
- `Multi_selection`: Choose multiple from a list

**Output Types**:
- `Text`: Plain text with optional styling
- `Math`: Mathematical notation (rendered via KaTeX in web)
- `Title`: Change the window title/heading

**Progress bar**:
Slower operations can be performed with a loading bar to let the user track the progress of the operation

**Key Operations**:
```ocaml
val input_text : ?prompt:string -> t -> unit -> string Lwt.t
val input_integer : t -> unit -> int Lwt.t
val input_single_selection : t -> 'a list -> ('a -> string) -> unit -> 'a Lwt.t
val input_multi_selection : t -> 'a list -> ('a -> string) -> unit -> 'a list Lwt.t

val output_text : ?options:Output_text_options.t -> t -> string -> unit -> unit Lwt.t
val output_math : ?options:Output_text_options.t -> t -> Math.t -> unit -> unit Lwt.t
val output_title : t -> string -> unit -> unit Lwt.t

val with_progress_bar :
  ?label:string ->
  t ->
  maximum:int ->
  f:(increment_progress_bar:(unit -> unit Lwt.t) -> unit -> 'a Lwt.t) ->
  unit ->
  'a Lwt.t
```

**HTTP Client**: Each `Io.S` implementation includes an `Http_client` module compatible with Cohttp:
```ocaml
module Http_client : Cohttp_lwt.S.Client
```

### 3. Math Type System

The `Math.t` type represents mathematical notation that can be rendered in both terminal and web:

Converts to LaTeX strings for KaTeX rendering in web or approximations in terminal.

### 4. Async with Lwt

All IO operations are asynchronous using Lwt (Lightweight cooperative threads):
- Use `let%lwt` syntax for binding Lwt promises
- Use `Lwt.return` to wrap values
- `lwt_ppx` preprocessor enables the syntax

### 5. Terminal Modes

Terminal apps support two modes:
- **`Minimal`**: Simple line-based IO
- **`Tui`**: Full terminal UI with Notty (rich widgets, colors, progress bars)

## Dependencies

### Core Dependencies
- **core**: Jane Street's standard library alternative
- **lwt** + **lwt_ppx**: Asynchronous programming
- **cohttp-lwt** + **cohttp-lwt-unix** + **cohttp-lwt-jsoo**: HTTP client (platform-specific)
- **notty**: Terminal UI library (terminal apps)
- **js_of_ocaml** + **js_of_ocaml-ppx** + **js_of_ocaml-compiler**: OCaml to JavaScript compiler
- **cmdliner**: Command-line argument parsing
- **fpath** + **bos**: File path and OS operations (setup script)

## Project Structure Deep Dive

### Test Structure (`test/`)

#### Example Apps (`test/examples/`)
Each example contains:
- `*_app.ml`: Application functor definition
- `*_terminal_app.ml`: Terminal executable
- `*_web_app.ml`: Web executable
- `index.html`: HTML wrapper for web app
- `dune`: Build configuration

**Available Examples**:
- **simple_text_io_app**: Basic text input/output
- **string_concatenator**: String manipulation demo
- **math_app**: Mathematical notation rendering
- **multiselect_app**: Multi-selection input demo
- **weather_app**: HTTP client usage (fetches from wttr.in)

#### Terminal Tests (`test/terminal_app/`)
- Unit tests for terminal-specific functionality
- Integration tests for TUI components

#### Setup Script Tests (`test/setup_script/`)
- Integration tests using Dune's Cram test system (`.t` files)

## Common Tasks & Workflows

### Building the Project
```bash
dune build                    # Build everything
dune build @install           # Build installable artifacts
dune build @runtest           # Build and run tests
dune clean                    # Clean build artifacts
```

### Testing
```bash
dune runtest                  # Run all tests
dune exec -- test/examples/simple_text_io_app/simple_text_io_app_terminal_app.exe
```

### Installation
```bash
opam install .                # Install locally
opam install . --yes --with-test  # Install with test dependencies
```

### Creating a New App
```bash
dune exec -- quickterface-setup-script --executable-name my_app --target-parent-path .
```

### Compiling Web Apps
Web apps use js_of_ocaml:
```bash
dune build path/to/web_app.bc.js
```

## Development Guidelines

### Adding New Input Types
1. Extend `Input.t` GADT in `common/io.ml`
2. Implement in `terminal_app/tui_terminal_io.ml` (TUI)
3. Implement in `terminal_app/minimal_terminal_io.ml` (minimal)
4. Implement in `web_app_backend/inputs.ml` (web)
5. Add convenience function to `Io.S` signature

### Adding New Output Types
1. Extend `Output.t` GADT in `common/io.ml`
2. Implement rendering in `terminal_app/log_item.ml` (terminal)
3. Implement rendering in `web_app_backend/outputs.ml` (web)
4. Add convenience function to `Io.S` signature

### Adding New Math Constructors
1. Add constructor to `Math.t` in `common/math.ml`
2. Update `latex_string_of_t` function
3. Ensure terminal rendering handles it appropriately

### Testing Considerations
- Terminal tests can use Dune's Cram testing
- Web apps need manual browser testing
- Example apps serve as integration tests
- Keep examples simple and focused on specific features

## Code Style

- **Formatter**: ocamlformat
- **Conventions**:
  - Use `open! Core` at file start
  - For files for the web app backend, these commonly use `open! Js_of_ocaml` at file start
  - Use `.mli` files for public modules
  - GADTs for type-safe extensible input/output types
  - Functors for platform abstraction
  - Lwt for async operations

## Key Files for Modification

### Adding Features
- **`common/io.ml`**: Core IO abstractions
- **`common/app.ml`**: App interface (rarely changes)
- **`terminal_app/tui_terminal_io.ml`**: Terminal implementation
- **`web_app_backend/app.ml`**: Web implementation

### Styling/Theming
- **`terminal_app/theme.ml`**: Terminal colors and styles
- **`web_app_backend/stylesheet.ml`**: Web CSS generation

### Widgets/Components
- **Terminal**: `terminal_app/` (window.ml, log.ml, input_field.ml, progress_bar.ml)
- **Web**: `web_app_backend/` (inputs.ml, outputs.ml, log.ml)

### Setup/Scaffolding
- **`setup_script/templates.ml`**: Template generation logic
- **`setup_script/templates/`**: Template files

## API Design Patterns

### GADT-Based Extensibility
Input and output types use GADTs to maintain type safety while allowing heterogeneous collections:
```ocaml
type (_, _) t =
  | Text : (string option, string) t
  | Integer : (unit, int) t
```
First type parameter is settings, second is return type.

### Functor Application Pattern
```ocaml
(* Define app *)
module MyApp (Io : Quickterface.Io.S) = struct
  let main ~io () = ...
end

(* Terminal version *)
module MyApp_Terminal = Quickterface.Terminal_app.Make(MyApp)
let () = MyApp_Terminal.command ~argv:Sys.argv ()

(* Web version *)
module MyApp_Web = Quickterface.Web_app.Make(MyApp)
let () = Lwt_main.run (MyApp_Web.run ())
```

### Platform-Specific HTTP Clients
Cohttp provides platform-specific implementations:
- `cohttp-lwt-unix`: For terminal apps (Unix sockets)
- `cohttp-lwt-jsoo`: For web apps (XHR/Fetch)

Both implement the same `Cohttp_lwt.S.Client` signature.

## Known Limitations & Future Work

Based on version 0.1.0 status:
- Work-in-progress state
- Limited input types (no file pickers, dates, etc.)
- Math rendering approximations in terminal mode
- No built-in validation for inputs
- No state persistence between runs

Potential extensions:
- More input types (date, time, file selection, color picker)
- Output types (tables, charts, images)
- Better validation and error handling
- Theming customization
- State management utilities

## Quick Reference

### Creating an App
```ocaml
module App (Io : Quickterface.Io.S) = struct
  let main ~io () =
    (* Your app logic here *)
    Lwt.return ()
end
```

### Terminal Entry Point
```ocaml
module Terminal = Quickterface.Terminal_app.Make(App)
let () = Terminal.command ~argv:Sys.argv ()
```

### Web Entry Point
```ocaml
module Web = Quickterface.Web_app.Make(App)
let () = Lwt_main.run (Web.run ())
```

### Example Operations
```ocaml
(* Input *)
let%lwt name = Io.input_text ~prompt:"Name?" io () in
let%lwt age = Io.input_integer io () in
let%lwt color = Io.input_single_selection io ["Red"; "Blue"; "Green"] Fn.id () in

(* Output *)
let%lwt () = Io.output_title io "Results" () in
let%lwt () = Io.output_text io "Processing..." () in

(* Math *)
let math_expr = Math.(Frac (Literal "x", Literal "y")) in
let%lwt () = Io.output_math io math_expr () in

(* HTTP *)
let%lwt response, body = Io.Http_client.get (Uri.of_string "https://...") in

(* Progress bar *)
let%lwt result = Io.with_progress_bar io ~maximum:100
  ~f:(fun ~increment_progress_bar () ->
    (* Do work and call increment_progress_bar () *))
  ()
in
```

## Troubleshooting

### Build Issues
- Ensure OCaml >= 5.1.0
- Run `opam update && opam upgrade`
- Check js_of_ocaml version >= 6.0.0
- Clear build: `dune clean && dune build`

### Web App Not Working
- Check JavaScript is generated: `_build/default/path/to/app.bc.js`
- Verify index.html references correct JS file
- Check browser console for errors
- Ensure js_of_ocaml-compiler is installed

### Terminal App Rendering Issues
- Verify terminal supports UTF-8
- Check TERM environment variable
- Test with `--mode=minimal` first
- Ensure Notty >= 0.2.3

## Additional Resources

- **Source**: https://github.com/ofsouzap/quickterface
- **Issues**: https://github.com/ofsouzap/quickterface/issues
- **Examples**: See `test/examples/` directory
- **Notty docs**: https://github.com/pqwy/notty
- **js_of_ocaml**: https://ocsigen.org/js_of_ocaml/
- **Lwt manual**: https://ocsigen.org/lwt/

---

*This documentation is for AI agents and developers working on or with Quickterface. Last updated for version 0.1.0.*
