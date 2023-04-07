function bool = isperm(a, b, options)
  % --------------------------------
  % - returns true if two vectors
  %   are permuations of one another
  % --------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a;
    b;
    options.Dim (1,1) double ...
    {mustBeInteger, mustBePositive} = default_dim(a);
  end
  % check for tables and symbolic functions
  if istabular(a)
    a = table2cell(a);
  elseif issymfun(a)
    a = formula(a);
  end
  if istabular(b)
    b = table2cell(b);
  elseif issymfun(b)
    b = formula(b);
  end
  % check the array dimension
  Dim = options.Dim;
  if ~ismember(Dim, [1 2])
    error('''Dim'' must be 1 or 2');
  end
  %% determine if the two vectors are permutations of one another
  try    
    if isempty(a) || isempty(b) || ~isequaldim(a, b)
      bool = false;
    elseif Dim == 1
      num_cols = width(a);
      bool = false(1, num_cols);
      for k = 1:num_cols
        bool(k) = isequal(sort(a(:,k)), sort(b(:,k)));
      end
    else
      num_rows = height(a);
      bool = false(num_rows, 1);
      for k = 1:num_rows
        bool(k) = isequal(sort(a(k,:)), sort(b(k,:)));
      end
    end
  catch
    str = stack('function call to ''isperm'' failed because', ...
                'at least one of the vectors cannot be sorted');
    error(str);
  end
end
% =
function Dim = default_dim(a)
  % ---------------------------------
  % - helper function for determining
  %   the default dimension for
  %   the arrays
  % ---------------------------------
  if isScalar(a)
    Dim = 1;
  else
    Dim = find(Size(a) ~= 1, 1);
  end
end
% =
