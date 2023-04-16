function T_Kelvin = c2k(T_Celsius)
  % ----------------------------
  % - converts temperatures from
  %   degrees Celsius to Kelvin
  % ----------------------------
  
  %% check the input argument
  if ~issym(T_Celsius)
    error('input argument must be a symbolic expression');
  end
  %% convert the temperature
  u = symunit;
  T_Kelvin = rewrite(T_Celsius, u.Kelvin, ...
                      'Temperature', 'absolute');
