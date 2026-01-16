open! Core

type t = { channel_options : Output_channel_options.t }

let default =
  {
    channel_options =
      Default_output_channel { color = Color.default_foreground };
  }
