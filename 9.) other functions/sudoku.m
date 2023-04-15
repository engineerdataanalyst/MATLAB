function grid = sudoku
  grid = randperm(9);
  for j = 1:8
    valid = false;
    while ~valid
      row = randperm(9);
      valid = true;
      for k = 1:9
        if ~isunique([grid(:,k); row(:,k)])
          valid = false;
          break;
        end
      end
    end
    grid = [grid; row];
  end
