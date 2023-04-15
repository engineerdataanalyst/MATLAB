function mustBeMemberi(A, B)
  % -------------------------------------------------
  % - a slight variation of the mustBeMember function
  % - will do a case insensitive call to
  %   the ismemmber function on the arrays
  %   when validating the membership
  % -------------------------------------------------
  narginchk(2,2);
  try
    A_lower = string(lower(A));
  catch
    A_lower = A;
  end
  try
    B_lower = string(lower(B));
  catch
    B_lower = B;
  end
  try
    if ~all(ismember(A_lower, B_lower), 'all')
      mustBeMember(A, B);
    end
  catch Error
    throwAsCaller(Error);
  end
