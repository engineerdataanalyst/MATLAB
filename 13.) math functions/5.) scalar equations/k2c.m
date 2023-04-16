function T_Celsius = k2c(T_Kelvin)
  % ----------------------------
  % - converts temperatures from
  %   Kelvin to degrees Celsius
  % ----------------------------
  
  %% check the input argument
  if ~issym(T_Kelvin)
    error('input argument must be a symbolic expression');
  end
  %% convert the temperatures
  u = symunit;
  T_Celsius = rewrite(T_Kelvin, u.Celsius, ...
                      'Temperature', 'absolute');  
