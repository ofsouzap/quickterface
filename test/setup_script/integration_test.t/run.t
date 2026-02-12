The library versions have some compatibility problems so
building emits warnings but I need to filter these out so
I define a helper function for building and filtering
the errors.
  $ do_build () { \
  >   dune build "$@" 2>&1 \
  >   | grep -v 'deprecated-joo-global-object'; \
  >   status=$?; \
  >   [ "$status" -eq 1 ] && return 0; \
  >   return "$status";
  > }

Create the project skeleton and check it initially builds
  $ dune init project test_quickterface_app
  Entering directory 'test_quickterface_app'
  Success: initialized project component named test_quickterface_app
  Leaving directory 'test_quickterface_app'
  $ cd test_quickterface_app
  $ do_build

Create an executable with the default name ("my_app") and check the project still builds
  $ quickterface-setup-script
  $ do_build

Specifically check that the terminal executable exists
  $ do_build ./my_app/my_app_terminal_app.exe

Create an executable with a custom name in the same project and check the project still builds
  $ quickterface-setup-script --executable-name=custom_name_app
  $ do_build

  $ echo "NAME" | dune exec ./my_app/my_app_terminal_app.exe -- --mode=minimal
  What is your name?
  > Hello, NAME!
