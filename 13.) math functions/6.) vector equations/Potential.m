function [Pc Pf] = Potential(f, rfun)
  % --------------------------------------------
  % - computes the potential curve (Pc)
  %   and the potential function (Pf)
  %   of a scalar field (f) as a function
  %   of the parametrized vector function (rfun)
  % --------------------------------------------
  
  %% check the input arguments
  % check the integrating and displacement functions
  narginchk(2,inf);
  if ~issymfunvector(f, 'CheckEmpty', true) || ...
     ~issymfunvector(rfun, 'CheckEmpty', true)
    str = stack('''f'' and ''rfun'' must be', ...
                'symbolic functions of non-empty vectors');
    error(str);
  end
  % check the integrating and displacement function arguments
  if ~isequallen(argnames(f), rfun)
    str = stack('the number of function arguments to ''f''', ...
                'must be the same as the length of ''rfun''');
    error(str);
  end
  % check the integrating and displacement function lengths
  if ~isequallen(f, rfun) && ~issymfunscalar(f)
    str = stack('the length of ''f'' must be the same as', ...
                'the length of ''rfun'', (if ''f'' is not a scalar)');
    error(str);
  end
  % check the number of displacement function arguments
  if numArgs(rfun) ~= 1
    error('''rfun'' must have one function argument');
  end
  %% compute the potential function curve
  IAC = {'IgnoreAnalyticConstraints' true};
  t = argnames(rfun);
  rfun_cell = num2cell(formula(rfun));
  Pf = potential(f);
  Pf = simplify(simplifyFraction(Pf), IAC{:});
  Pc(t) = Pf(rfun_cell{:});
  Pc = simplify(simplifyFraction(Pc), IAC{:});
