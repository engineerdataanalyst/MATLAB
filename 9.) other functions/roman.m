function numeral = roman(num)
  % ----------------------------
  % - computes the roman numeral
  %   of an array of integers
  % ----------------------------
  
  %% check the input argument
  arguments
    num double {mustBeInteger, mustBeInRange(num, -3999, 3999)};
  end
  %% compute the roman numerals
  numeral = strings(size(num));
  for k = find(num(:) ~= 0).'
    % get the absolute value of the numbers
    if num(k) < 0
      negative = true;
      num(k) = -num(k);
    else
      negative = false;
    end
    % compute the roman numerals
    if 1 <= num(k) && num(k) < 10
      switch num(k)
        case {1 2 3}
          numeral(k) = repmat('I', 1, num(k));
        case 4
          numeral(k) = 'IV';
        case {5 6 7 8}
          numeral(k) = 'V'+roman(num(k)-5);
        case 9
          numeral(k) = 'IX';
      end
    elseif 10 <= num(k) && num(k) < 40
      X = repmat('X', 1, floor(num(k)/10));
      numeral(k) = X+roman(rem(num(k), 10));
    elseif 40 <= num(k) && num(k) < 50
      numeral(k) = 'XL'+roman(num(k)-40);
    elseif 50 <= num(k) && num(k) < 90
      numeral(k) = 'L'+roman(num(k)-50);
    elseif 90 <= num(k) && num(k) < 100
      numeral(k) = 'XC'+roman(num(k)-90);
    elseif 100 <= num(k) && num(k) < 400
      C = repmat('C', 1, floor(num(k)/100));
      numeral(k) = C+roman(rem(num(k), 100));
    elseif 400 <= num(k) && num(k) < 500
      numeral(k) = 'CD'+roman(num(k)-400);
    elseif 500 <= num(k) && num(k) < 900
      numeral(k) = 'D'+roman(num(k)-500);
    elseif 900 <= num(k) && num(k) < 1000
      numeral(k) = 'CM'+roman(num(k)-900);
    elseif 1000 <= num(k) && num(k) < 4000
      M = repmat('M', 1, floor(num(k)/1000));
      numeral(k) = M+roman(rem(num(k), 1000));
    end
    % append a '-' sign for negative numbers
    if negative
      numeral(k) = '-'+numeral(k);
    end
  end
