function expr = index(a, varargin)
  % ---------------------------------------
  % - allows indexing of symbolic functions
  % ---------------------------------------
  
  %% temporarily convert symbolic functions to syms
  if issymfun(a)
    convert2symfun = true;
    args = argnames(a);
    a = formula(a);
  else
    convert2symfun = false;
  end    
  %% call the subsref function
  s.type = '()';
  s.subs = varargin;
  expr = subsref(a, s);
  %% convert back to symbolic function if necessary
  if convert2symfun
    expr(args) = expr;
  end
