function val = u(x)
  % ------------------------
  % - the unit step function
  %   in piecewise form
  % ------------------------
  narginchk(1,1);
  if isTextArray(x, ["char" "string" "cell of char"])
    x = Str2sym(x);
  end
  if issymfun(x)
    convert2symfun = true;
    args = argnames(x);
    x = formula(x);
  else
    convert2symfun = false;
  end  
  val = x;
  if isnumeric(x) || all(issymnum(x), 'all')
    val(isAlways(x >= 0)) = 1;
    val(isAlways(x < 0)) = 0;
  elseif issym(x)
    for k = 1:numel(x)
      val(k) = piecewise(x(k) >= 0, 1, 0);
    end
  else
    str = stack('input argument must be one of these:', ...
                '------------------------------------', ...
                '1.) a numeric array', ...
                '2.) a symbolic array', ...
                '3.) a symbolic string');
    error(str);
  end
  if convert2symfun
    val(args) = val;
  end
