function answer = logB(x, B)
  % -----------------------
  % - returns the logarithm
  %   to the base B
  % -----------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    x;
    B {mustBeA(B, ["numeric" "sym"])} = sym('B');
  end
  % check the argument dimensions
  if ~compatible_dims(x, B)
    error('input arguments must have compatible dimensions');
  end
  %% return the logarithm to the base b
  if issym(x) || issym(B)
    if ~issym(x)
      x = sym(x);
    elseif ~issym(B)
      B = sym(B);
    end
  end
  answer = log(x)./log(B);
  %% fix the infinity answers
  if issymfun(answer)
    arglist = argnames(answer);
    f = formula(answer);
    f(isinf(answer)) = nan;
    answer(arglist) = f;
  else
    answer(isinf(answer)) = nan;
  end
