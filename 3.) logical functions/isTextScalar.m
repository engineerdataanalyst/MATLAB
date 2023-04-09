function bool = isTextScalar(a, classname, options)
  % --------------------------
  % - returns true if an array
  %   is a scalar of text
  % --------------------------
  
  %% check the input arguments
  arguments
    a;
    classname ...
    {mustBeNonzeroLengthText, mustBeVector, ...
     mustBeMemberi(classname, ["char" ...
                               "string" ...
                               "cell of char" ...
                               "cell of string" ...
                               "cell"])} = ["char" ...
                                            "string" ...
                                            "cell of char" ...
                                            "cell of string" ...
                                            "cell"];
    options.TextLen (1,1) double {mustBeInteger, mustBeNonnegative};
    options.CheckEmptyText (1,1) logical;
  end
  %% compute the test function handles
  options = namedargs2cell(options);
  char_case = @(arg) ischar(arg) && ...
                     isStringScalar2(string(arg), options{:});
  string_case = @(arg) isStringScalar2(arg, options{:});
  char_or_string_case = @(arg) char_case(arg) || string_case(arg);
  %% check the array
  bool = false;
  classname = unique(lower(string(classname)), 'stable');
  for k = 1:length(classname)
    % test conditions
    switch classname(k)
      case "char"
        bool = char_case(a);
      case "string"
        bool = string_case(a);
      otherwise
        if iscellscalar(a)
          cell_type = extractAfter(classname(k), "cell of ");
          switch cell_type
            case "char"
              bool = char_case(a{1});
            case "string"
              bool = string_case(a{1});
            otherwise
              bool = char_or_string_case(a{1});
          end
        end
    end
    % breaking the loop if necessary
    if bool
      break;
    end
  end
