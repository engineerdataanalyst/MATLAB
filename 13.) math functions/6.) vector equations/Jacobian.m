function [fnew Jd Jm] = Jacobian(f, new_vars)
  % -------------------------------------------
  % - computes the jacobian change of variables
  %   of a function with a given
  %   new set of variables
  % -------------------------------------------
  
  %% check the input arguments
  % check the integrating function
  narginchk(2,2);
  if ~issymfun(f)
    error('''f'' must be a symbolic function');
  end
  % check the new variables
  f_args = argnames(f);
  if issymfun(new_vars)
    new_vars_args = argnames(new_vars);
  else
    new_vars_args = [];
  end
  if ~issymfunvector(new_vars, 'CheckEmpty', true)
    str = stack('''new_vars'' must be', ...
                'a non-empty symbolic function vector');
    error(str);
  end
  if ~isequallen(new_vars, f_args)
    str = stack('the length of ''new_vars''', ...
                'must be equal to the number', ...
                'of function arguments for ''f''');
    error(str);
  end
  if ~isequallen(new_vars_args, f_args)
    str = stack('the function arguments in ''new_vars''', ...
                'must be equal to the number', ...
                'of function arguments for ''f''');
    error(str);
  end
  if any(ismember(new_vars_args, f_args))
    str = stack('the function arguments of ''new_vars''', ...
                'must not contain', ...
                'the function arguments of ''f''');
    error(str);
  end
  %% compute the jacobian data
  IAC = {'IgnoreAnalyticConstraints' true};
  Jm = jacobian(new_vars);
  Jm = simplify(simplifyFraction(Jm), IAC{:});
  Jd = det(Jm);
  Jd = simplify(simplifyFraction(Jd), IAC{:});
  new_vars = num2cell(formula(new_vars));
  fnew(new_vars_args) = f(new_vars{:});
  fnew = simplify(simplifyFraction(fnew), IAC{:});
