function [F f tF dF sF cF] = ints(int_args, options)
  % ------------------------
  % - function that calls
  %   the integral functions
  % ------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments (Repeating)
    int_args {mustBeTextScalar, mustBeNonzeroLengthText};
  end
  arguments
    options.Overwrite (1,1) logical = false;
    options.Extract (1,1) logical = true;
    options.AddVars (1,1) logical = true;
  end
  % check the argument options
  Overwrite = options.Overwrite;
  Extract = options.Extract;
  AddVars = options.AddVars;
  options = rmfield(options, ["Extract" "AddVars"]);
  options.Workspace = 'base';
  Args = namedargs2cell(options);
  % check the integral types
  int_args = string(int_args);
  int_type_list = ["Bt" "expt" "quad" ...
                   "trig1" "trig2" "itrig" ...
                   "hyp1" "hyp2" "ihyp"].';
  if ~isunique(int_args)
    error('input arguments must be unique');
  elseif ~isempty(int_args) && ~ismember(int_args{1}, int_type_list)
    str = compose("%d.) '", 1:length(int_type_list)).'+int_type_list+"'";
    str = join(str, newline);
    str = stack('first argument must be', ...
                'one of these integral types:', ...
                '----------------------------', str);
    error(str);
  end
  %% integral cell array
  % exponential and logarithmic integrals (with base == 'B')
  int_cell = cell(9,1);
  int_cell{1} = ["B";
                 "logB"];
  % exponential and logarithmic integrals (with base == 'exp(1)')
  int_cell{2} = ["exp";
                 "log"];
  % quadratic integrals
  int_cell{3} = ["quad1rat";
                 "quad2rat"
                 "quad3logB";
                 "quad4log"];
  % trig integrals (type 1)
  int_cell{4} = ["sin";
                 "cos";
                 "tan";
                 "csc";
                 "sec";
                 "cot";
                 "sinx";
                 "cosx"];
  % trig integrals (type 2)
  int_cell{5} = ["sincos";
                 "csccot";
                 "sectan";
                 "sincosf"];
  % inverse trig integrals
  int_cell{6} = ["asin";
                 "acos";
                 "asinx";
                 "acosx";
                 "atanx";
                 "acscx";
                 "asecx";
                 "acotx"];
  % hyperbolic integrals (type 1)
  int_cell{7} = ["sinh";
                 "cosh";
                 "tanh";
                 "csch";
                 "sech";
                 "coth";
                 "sinhx";
                 "coshx"];
  % hyperbolic integrals (type 2)
  int_cell{8} = ["sinhcosh";
                 "cschcoth";
                 "sechtanh";
                 "sinhcoshf"];
  % inverse hyperbolic integrals
  int_cell{9} = ["asinh";
                 "acosh";
                 "asinhx";
                 "acoshx";
                 "atanhx";
                 "acschx";
                 "asechx";
                 "acothx"];
  % cell array modifications
  type_loc = ismember(int_args, int_type_list);
  arg_ind = [find(type_loc) nargin+1];
  start = arg_ind(1:end-1)+1;
  finish = arg_ind(2:end)-1;
  int_types = int_args(type_loc);
  [~, cell_ind] = ismember(int_types, int_type_list);
  for k = 1:length(int_types)
    int_funcs = int_args(start(k):finish(k));
    if isempty(int_funcs)
      continue;
    end
    [func_loc func_ind] = ismember(int_funcs, int_cell{cell_ind(k)});
    if ~all(func_loc)
      str = '''%s'' is not an integral of type ''%s''';
      invalid_func = int_funcs(~func_loc);
      error(str, invalid_func(1), int_types(k));
    end
    int_cell{cell_ind(k)} = int_cell{cell_ind(k)}(func_ind);
  end
  %% integral list
  if isempty(int_types)
    int_list = vertcat(int_cell{:});
  else
    int_list = vertcat(int_cell{cell_ind});
  end
  int_str = int_list+"_int";
  %% function calls
  if AddVars
    func = cell(size(int_list));
  end
  for k = 1:length(int_list)
    p = int_list(k);
    [F.(p) f.(p) tF.(p) dF.(p) sF.(p) cF.(p)] = eval(int_str(k));
    if AddVars && isstruct(F.(p))
      func{k} = F.(p).one;
    elseif AddVars
      func{k} = F.(p);
    end
  end
  %% function variables
  if AddVars
    old_assum = assumptions;
    cleanup = onCleanup(@() assume(old_assum));
    clearassum;
    n = sym('n');
    po = sym('p');
    n1p = sym('n1p');
    np = sym('np');
    if ~evalin('base', 'exist(''n1p'')') || Overwrite
      N1P(n, n1p) = piecewise(n == -1 & n1p == 0,  po, ...
                              n ~= -1 & n1p ~= 0, (n+1)/n1p);
      assignin('base', 'n1p', N1P);
    end
    if ~evalin('base', 'exist(''np'')') || Overwrite
      NP.sincos(n, np) = -n-2*np;
      assignin('base', 'np', NP);
    end
    addvar(func{:}, Args{:});
  end
  %% scalar integral special case
  if isscalar(int_list) && Extract
    F = F.(p);
    f = f.(p);
    tF = tF.(p);
    dF = dF.(p);
    sF = sF.(p);
    cF = cF.(p);
  end
