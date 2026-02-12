  $ quickterface-setup-script --help=plain
  NAME
         setup - Set up a new executable in an existing dune project
  
  SYNOPSIS
         setup [--executable-name=NAME] [--target-parent-path=PATH] [OPTION]…
  
  DESCRIPTION
         Creates a new executable with template code and files in an existing
         dune project.
  
  OPTIONS
         --executable-name=NAME
             Name of the executable to create.
  
         --target-parent-path=PATH (absent=.)
             Path to the directory where the executable should be added.
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
  EXIT STATUS
         setup exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  












