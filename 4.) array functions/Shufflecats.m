function a = Shufflecats(a)
  % -------------------------
  % - shuffles the categories
  %   of a categorical array
  % -------------------------
  
  %% check the input argument
  arguments
    a categorical;
  end
  %% shuffle the categories 
  a = reordercats(a, Shuffle(categories(a)));
