function T_Rankine = f2r(T_Fahrenheit)
  % ---------------------------------------
  % - converts temperatures from
  %   degrees Fahrenheit to degrees Rankine
  % ---------------------------------------
  
  %% check the input argument
  if ~issym(T_Fahrenheit)
    error('input argument must be a symbolic expression');
  end
  %% convert the temperatures
  u = symunit;
  T_Rankine = rewrite(T_Fahrenheit, u.Rankine, ...
                      'Temperature', 'absolute');
  T_Rankine = sym(double(separateUnits(T_Rankine)))*u.Rankine;
