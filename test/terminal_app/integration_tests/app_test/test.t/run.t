  $ cat input.txt | ../exec/my_app_terminal_app.exe --mode=minimal
  #####################
  # This is the title #
  #####################
  
  Input text
  > You gave "John Appleseed"
  Input integer
  > You gave 1234
  Input single selection
  [Select an option from the below]
    [0] A
    [1] B
    [2] C
    [3] D
  > You chose: C
  [Enter an option to toggle selecting it. Press ENTER without selecting anything to submit the selection]
    [ ] [0] A
    [ ] [1] B
    [ ] [2] C
    [ ] [3] D
  >   [X] [0] A
    [ ] [1] B
    [ ] [2] C
    [ ] [3] D
  >   [X] [0] A
    [ ] [1] B
    [X] [2] C
    [ ] [3] D
  >   [X] [0] A
    [ ] [1] B
    [X] [2] C
    [X] [3] D
  > You chose: A, C, D
  Here is some math
  (e)^(i π) - 1 = 0

