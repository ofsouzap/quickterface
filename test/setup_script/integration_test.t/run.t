Create the project skeleton and check it initially builds
  $ dune init project test_quickterface_app
  Entering directory 'test_quickterface_app'
  Success: initialized project component named test_quickterface_app
  Leaving directory 'test_quickterface_app'
  $ cd test_quickterface_app
  $ dune build

Create an executable with the default name ("my_app") and check the project still builds
  $ quickterface-setup-script
  $ dune build

Specifically check that the terminal executable exists
  $ dune build ./my_app/my_app_terminal_app.exe

Create an executable with a custom name in the same project and check the project still builds
  $ quickterface-setup-script --executable-name=custom_name_app
  $ dune build

  $ echo "NAME" | dune exec ./my_app/my_app_terminal_app.exe -- --mode=minimal
  What is your name?
  > Hello, NAME!
  
