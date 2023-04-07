function bool = islen(a, len)
  % --------------------------
  % - returns true if an array
  %   has a specified length
  % --------------------------
  
  %% check the input arguments  
  arguments
    a;
    len (1,1) double {mustBeInteger, mustBeNonnegative};
  end  
  %% check the array
  bool = Length(a) == len;
