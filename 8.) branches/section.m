function val = section(f, x, varargin)
  % ----------------------
  % - the section function
  % ----------------------

  %% check the input arguments
  narginchk(3,4);
  arglist = [{f x} varargin];
  numargs = cellfun(@isnumeric, arglist);
  symargs = cellfun(@issym, arglist);  
  scalarargs = cellfun(@isscalar, arglist);
  if ~any(numargs) && ~any(symargs)
    str = stack('input arguments must be', ...
                'numeric or symbolic expressions');
    error(str);
  end
  %% return the section
  if nargin == 3
    if ~islen(varargin{1}, 2)
      str = stack('passing 3 arguments', ...
                  'requires the last one', ...
                  'to be a vector of length 2');
      error(str);
    end
    d1 = varargin{1}(1);
    d2 = varargin{1}(2);
  else    
    if ~all(scalarargs(3:4))
      str = stack('passing 4 arguments', ...
                  'requires the last 2', ...
                  'to be scalars');
      error(str);
    end
    [d1 d2] = deal(varargin{:});
  end
  if ~issymscalar(f)
    str = stack('''f'' must be', ...
                'a symbolic scalar');
    error(str);
  end
  if ~issymvarscalar(x)
    str = stack('''x'' must be', ...
                'a symbolic variable scalar');
    error(str);
  end
  val = f*piecewise(d1 <= x & x <= d2, 1, 0);
