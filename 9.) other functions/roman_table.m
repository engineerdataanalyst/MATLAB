function tbl = roman_table(num)
  % -------------------------
  % - creates a table with
  %   numbers alongside their
  %   roman numeral values  
  % -------------------------
  
  %% check the input argument
  arguments
    num (:,1) double ...
    {mustBeNonempty, mustBeInteger, mustBeInRange(num, -3999, 3999)} = 1:3999;
  end
  %% create the roman numeral table
  numeral = roman(num);
  tbl = table(num, numeral);
