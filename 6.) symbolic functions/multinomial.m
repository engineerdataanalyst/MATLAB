function f = multinomial(varargin)
  % ---------------------------
  % - computes the multiniomial
  %   expression of an array
  % ---------------------------
  
  %% check the input arguments
  % check the terms
  narginchk(2,inf);
  terms = varargin(1:end-1).';
  scalar_terms = isscalar(terms);
  numeric = cellfun(@isnumscalar, terms) | ...
           (cellfun(@isnumvector, terms) & scalar_terms);
  symbolic = cellfun(@issymscalar, terms) | ...
            (cellfun(@issymvector, terms) & scalar_terms);
  if ~all(numeric | symbolic)
    str = stack('the terms must be', ...
                'numeric or symbolic scalars', ...
                'or one vector containing', ...
                'numeric or symbolic scalars');
    error(str);
  end
  % check the exponent  
  exponent = varargin{end};
  if ~isintscalar(exponent, 'Type', 'positive or zero') && ...
     ~issymscalar(exponent)
    str = stack('the exponent must be a', ...
                'non-negative integer', ...
                'or a symbolic scalar');
    error(str);
  end
  % check for valid symbolic functions
  symfuns = cellfun(@issymfun, varargin.');
  args = cellfun(@argnames, varargin(symfuns.'), 'UniformOutput', false);
  if ~isallequal(args)
    error(message('symbolic:symfun:InputMatch'));
  end
  if ~isempty(args)
    args = args{1};
  end
  %% make any necessary changes
  % modify the terms and exponent as necessary
  if scalar_terms && cellfun(@isrow, terms)
    terms = cell2sym(terms).';    
  else
    terms = cell2sym(terms);
  end
  exponent = formula(sym(exponent));
  % check for special case for nterms
  nterms = length(terms);
  if nterms == 1
    f = terms^exponent;
    return;
  end
  %% compute these extra variables
  % compute the variable list
  old_vals = [terms; exponent];
  varlist = symvar(old_vals);
  % compute the dummy x variables for the symfuns
  x = array2cellsymstr(sym('x', [nterms+1 1]));
  for ind = 1:nterms+1
    while ismember(x{ind}, varlist)
      x{ind} = [x{ind} num2str(randi(9))];
    end
  end
  x = cell2sym(x);
  % compute the summation index k
  k = array2cellsymstr(sym('k', [nterms-1 1]));
  for ind = 1:nterms-1
    while ismember(k{ind}, varlist)
      k{ind} = [k{ind} num2str(randi(9))];
    end
  end
  k = cell2sym(k);
  % temporarily replace the terms and exponents for symbolic functions
  if scalar_terms
    symfuns = [repmat(symfuns(1), nterms, 1); symfuns(end)];
  end
  terms(symfuns(1:end-1)) = x(symfuns(1:end-1));
  if symfuns(end)
    exponent = x(end);
  end
  %% return the multinomial
  % compute the multinomial arguments
  nck = 1;
  trm = 1;
  symsum_args = {};
  for ind = 1:nterms
    if ind == 1
      nck = nck*nchoosek(exponent,k(ind));
      trm = trm*terms(ind)^(exponent-k(ind));
      symsum_args = [symsum_args; {[0 exponent]}];
    elseif ind ~= nterms
      nck = nck*nchoosek(k(ind-1),k(ind));
      trm = trm*terms(ind)^(k(ind-1)-k(ind));
      symsum_args = [symsum_args; {[0 k(ind-1)]}];
    else
      trm = trm*terms(ind)^k(ind-1);
    end
  end
  % compute the multinomial
  if any(symfuns)
    f(args) = itsymsum(nck*trm, k, symsum_args{:});
  else
    f = itsymsum(nck*trm, k, symsum_args{:});
  end
  f = subs(f, x(symfuns), old_vals(symfuns));
