function anew = log2sym(a)
  % --------------------------
  % - converts a logical array
  %   to a symbolic array of
  %   true and false values
  % --------------------------
  
  %% check the input arguments
  arguments
    a {mustBeA(a, "logical")};
  end
  %% convert the logical array to symbolic
  anew = sym.zeros(size(a));
  anew(a) = symtrue;
  anew(~a) = symfalse;
