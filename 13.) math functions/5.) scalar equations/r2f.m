function T_Fahrenheit = r2f(T_Rankine)
  % ---------------------------------------
  % - converts temperatures from
  %   degrees Rankine to degrees Fahrenheit
  % ---------------------------------------
  
  %% check the input argument
  if ~issym(T_Rankine)
    error('input argument must be a symbolic expression');
  end
  %% convert the temperatures
  u = symunit;
  T_Fahrenheit = rewrite(T_Rankine, u.Fahrenheit, ...
                         'Temperature', 'absolute');
  T_Fahrenheit = sym(double(separateUnits(T_Fahrenheit)))*u.Fahrenheit;
