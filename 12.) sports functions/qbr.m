function rating = qbr(com, att, yd, td, int)
  % ----------------------------
  % - quarterback rating formula
  %   used in the NFL
  % ----------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    com {mustBeA(com, ["numeric" "sym"])};
    att {mustBeA(att, ["numeric" "sym"])};
    yd {mustBeA(yd, ["numeric" "sym"])};
    td {mustBeA(td, ["numeric" "sym"])};
    int {mustBeA(int, ["numeric" "sym"])};
  end
  % check the argument dimensions
  Args = {com att yd td int};
  if ~compatible_dims(Args{:})
    error('input arguments must have compatible dimensions');
  end
  % check for invalid symbolic function arguments
  if ~isequalargnames(Args{:})
    error(message('symbolic:symfun:InputMatch'));
  end
  symfuns = cellfun(@issymfun, Args);
  args = cellfun(@argnames, Args(symfuns), 'UniformOutput', false);
  %% pass completions
  a = (com./att-0.3)*5;
  if issymfun(a)
    a = formula(a);
  end
  a(isAlways(a < 0, 'Unknown', 'false')) = 0;
  a(isAlways(a > 2.375, 'Unknown', 'false')) = 2.375;
  %% pass yards
  b = (yd./att-3)*0.25;
  if issymfun(b)
    b = formula(b);
  end
  b(isAlways(b < 0, 'Unknown', 'false')) = 0;
  b(isAlways(b > 2.375, 'Unknown', 'false')) = 2.375;
  %% pass touchdowns
  c = td./att*20;
  if issymfun(c)
    c = formula(c);
  end
  c(isAlways(c > 2.375, 'Unknown', 'false')) = 2.375;
  %% interceptions
  d = 2.375-(int./att*25);
  if issymfun(a)
    d = formula(d);
  end
  d(isAlways(d < 0, 'Unknown', 'false')) = 0;
  %% passer rating formula
  rating = (a+b+c+d)/6*100;
  if ~isempty(args)
    rating(args{1}) = rating;
  end
