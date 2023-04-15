function a = SimplifyFraction(a, ind, options)
  % ---------------------------
  % - a slight variation of the
  %   simplifyFraction function
  % - will call the
  %   simplifyFraction function
  %   on each term of a
  %   symbolic expression 
  %   separately and then
  %   add up the terms
  % ---------------------------
  
  %% check the input argument
  arguments
    a sym;
    ind (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBePositive} = 1:numTerms(a);
    options.Separate (1,1) logical = true;
    options.Expand;
  end
  % check the symbolic array
  if ~isScalar(a)
    error('''a'' must be a scalar');
  end
  % check the term index
  num_terms = numTerms(a);
  if ~isunique(ind)
    error('''ind'' must be unique');
  elseif ~all(ismember(ind, 1:num_terms)) && (num_terms ~= 0)
    str = stack('''ind'' must contain numbers', ...
                'that do not exceed', ...
                'the number of terms in ''a'' (%d)');
    error(str, num_terms);
  end
  % check the options
  Separate = options.Separate;
  options = namedargs2cell(rmfield(options, 'Separate'));
  %% call the simplify function on each term
  if isSymType(a, 'plus')
    terms = sym(children(a));
    if Separate
      func = @(arg) simplifyFraction(arg, options{:});
      terms(ind) = arrayfun(func, terms(ind));
      answer = sum(terms);
    else
      simplified_terms = simplifyFraction(sum(terms(ind)), options{:});
      non_simplified_terms = sum(setdiff(terms, terms(ind)));
      answer = simplified_terms;
      if ~isempty(non_simplified_terms)
        answer = answer+non_simplified_terms;
      end
    end
  elseif ispiecewise(a)
    if nargin == 1
      func = @(arg) SimplifyFraction(arg, options{:});
    else
      func = @(arg) SimplifyFraction(arg, ind, options{:});
    end
    [expr cond] = branches(a);
    expr = arrayfun(func, expr);
    answer = branches2piecewise(expr, cond);
  else
    answer = simplifyFraction(a, options{:});
  end
  %% modify the output to the correct type
  if issymfun(a)
    a(argnames(a)) = answer;
  else
    a = answer;
  end
