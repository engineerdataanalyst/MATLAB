function val = feq(f, X)
  if ~isnumeric(f) && ~issym(f)
    error('first argument must be a numeric or symbolic expression');
  end
  syms L;
  N = node(X);
  val = int(f*N, 0, L);