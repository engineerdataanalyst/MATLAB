function bool = isderived(subclass, superclass)
  % -------------------------------------------
  % - returns true if a given subclass string
  %   is derived from a given superclass string
  % -------------------------------------------
  
  %% check the input arguments
  arguments
    subclass {mustBeTextScalar, mustBeNonzeroLengthText};
    superclass {mustBeTextScalar, mustBeNonzeroLengthText};
  end
  %% check the subclass and superclass strings
  bool = ismember(superclass, superclasses(subclass));
