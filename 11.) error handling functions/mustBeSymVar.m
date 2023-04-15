function mustBeSymVar(a)
  if ~isallsymvar(a)
    aname = inputname(1);
    if isempty(aname)
      aname = 'arg1';
    end
    str = stack('', '''%s'' must be an array of symbolic variables');
    error(str, aname);
  end
