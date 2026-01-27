Create the project skeleton and check it initially builds
  $ dune init project test_quickterface_app
  Entering directory 'test_quickterface_app'
  Success: initialized project component named test_quickterface_app
  Leaving directory 'test_quickterface_app'
  $ cd test_quickterface_app
  $ dune build

Create an executable with the default name and check the project still builds
  $ quickterface-setup-script
  $ dune build

Create an executable with a custom name in the same project and check the project still builds
  $ quickterface-setup-script --executable-name=custom_name_app
  $ dune build
