classdef beam
  % ==
  % ----------------
  % - the beam class
  % ----------------
  % ==
  properties % beam properties
    load;
    E sym = sym('E');
    I sym = sym('I');
    L sym = sym('L');
  end
  % ==
  properties (Constant) % table variable and category names
    load_varnames = {'class' 'type' 'magnitude' 'distance' 'ends'}.';
    class_categories = {'reaction' 'hinge' 'concentrated' 'distributed'}.';
    type_categories = {'force' 'moment'}.';
  end
  % ==
  methods % beam constructor
    % ==
    function b = beam(what, varargin)
      % ----------------------
      % - the beam constructor
      % ----------------------
      
      %% check the argument classes
      arguments
        what ...
        {mustBeTextScalar, ...
         mustBeMemberi(what, ["cantilever" ...
                              "simply supported" ...
                              "moment" ...
                              "even" ...
                              "triangular"])} = "cantilever";
      end
      arguments (Repeating)
        varargin;
      end
      % check the number of input arguments
      narginchk(0,3);
      what = lower(what);
      % construct the load table
      persistent tbl;
      if ~istable(tbl)
        Args1 = {"reaction" beam.class_categories 'Protected' true};
        Args2 = {"force" beam.type_categories 'Protected' true};
        tbl.class = categorical(Args1{:});
        tbl.type = categorical(Args2{:});
        tbl.magnitude = "";
        tbl.distance = "";
        tbl.ends = [true true];
        tbl = struct2table(tbl);
        tbl(:,:) = [];
      end
      b.load = tbl;
      if nargin == 0
        return;
      end
      %% construct the beam object
      switch what
        case "cantilever"
          R = sym('R');
          M = sym('M');
          if nargin == 1
            P = -sym('P');
            L = sym('L');
          elseif nargin == 2
            P = varargin{1};
            L = sym('L');
          elseif isempty(varargin{1})
            P = -sym('P');
            L = varargin{2};
            b.L = L;
          else
            P = varargin{1};
            L = varargin{2};
            b.L = L;
          end
          b = b.add('reaction', 'force', R, 0);
          b = b.add('reaction', 'moment', M, 0);
          b = b.add('concentrated', 'force', P, L);
        case "simply supported"
          R1 = sym('R1');
          R2 = sym('R2');
          if nargin == 1
            P = -sym('P');
            L = sym('L');
          elseif nargin == 2
            P = varargin{1};
            L = sym('L');
          elseif isempty(varargin{1})
            P = -sym('P');
            L = varargin{2};
            b.L = L;
          else
            P = varargin{1};
            L = varargin{2};
            b.L = L;
          end
          b = b.add('reaction', 'force', R1, 0);
          b = b.add('reaction', 'force', R2, L);
          b = b.add('concentrated', 'force', P, L/2);
        case "moment"
          R1 = sym('R1');
          R2 = sym('R2');
          if nargin == 1
            Mo = sym('Mo');
            L = sym('L');
          elseif nargin == 2
            Mo = varargin{1};
            L = sym('L');
          elseif isempty(varargin{1})
            Mo = sym('Mo');
            L = varargin{2};
            b.L = L;
          else
            Mo = varargin{1};
            L = varargin{2};
            b.L = L;
          end
          b = b.add('reaction', 'force', R1, 0);
          b = b.add('reaction', 'force', R2, L);
          b = b.add('concentrated', 'moment', Mo, L);
        case {"even" "triangular"}
          R1 = sym('R1');
          R2 = sym('R2');
          if nargin == 1
            wo = -sym('wo');
            L = sym('L');
          elseif nargin == 2
            wo = varargin{1};
            L = sym('L');
          elseif isempty(varargin{1})
            wo = -sym('wo');
            L = varargin{2};
            b.L = L;
          else
            wo = varargin{1};
            L = varargin{2};
            b.L = L;
          end
          b = b.add('reaction', 'force', R1, 0);
          b = b.add('reaction', 'force', R2, L);
          if what == "even"
            magnitude = wo;
          else
            magnitude = findpoly(1, 'thru', [0 0], 'thru', [L wo]);
          end
          b = b.add('distributed', 'force', magnitude, [0 L]);
      end
    end
    % ==
    function b = set.load(b, rhs)
      % ---------------------
      % - sets the load table
      % ---------------------
      
      %% check for wrong variable names
      varnames = beam.load_varnames.';
      if ~istable(rhs) || ~isperm(rhs.Properties.VariableNames, varnames)
        str = stack('''load'' property must be a table', ...
                    'with the following variable names:', ...
                    '----------------------------------', ...
                    '1.) ''class''', ...
                    '2.) ''type''', ...
                    '3.) ''magnitude''', ...
                    '4.) ''distance''', ...
                    '5.) ''ends''');
        error(str);
      end
      % check for wrong variable types
      if ~iscatcol(rhs.class) || ~iscatcol(rhs.type)
        str = stack('''class'' and ''type'' variables', ...
                    'must be categorical column vectors');
        error(str);
      end
      if (~iscellcol(rhs.magnitude) && ~isStringCol(rhs.magnitude)) || ...
         (~iscellcol(rhs.distance) && ~isStringCol(rhs.distance))
        str = stack('''magnitude'' and ''distance'' variables', ...
                    'must be cell or string column vectors');
        error(str);
      end
      if ~islogarray(rhs.ends, 'Dim', [height(rhs) 2])
        str = stack('''ends'' variable', ...
                    'must be a 2-D logical array', ...
                    'with dimensions [height(load) x 2]');
        error(str);
      end
      %% check for wrong categories
      if ~isprotected(rhs.class) || ~isprotected(rhs.type) || ...
          isordinal(rhs.class) || isordinal(rhs.type)
        str = stack('''class'' and ''type'' variables', ...
                    'must be protected and unordinal', ...
                    'categorical arrays');
        error(str);
      end
      if ~isperm(beam.class_categories, categories(rhs.class))
        str = stack('''class'' variable must have', ...
                    'the following categories:', ...
                    '-------------------------', ...
                    '1.) ''reaction''', ...
                    '2.) ''hinge''', ...
                    '3.) ''concentrated''', ...
                    '4.) ''distributed''');
        error(str);
      end
      if ~isperm(beam.type_categories, categories(rhs.type))
        str = stack('''type'' variable must have', ...
                    'the following categories:', ...
                    '-------------------------', ...
                    '1.) ''force''', ...
                    '2.) ''moment''');
        error(str);
      end
      %% check for <undefined> categories
      if any(isundefined(rhs.class) | isundefined(rhs.type))
        str = stack('''class'' and ''type'' variables', ...
                    'must not have ''<undefined>'' values');
        error(str);
      end
      b.load = rhs;
    end
    % ==
    function b = set.E(b, rhs)
      % ---------------------
      % - sets the E property
      % ---------------------
      if ~isScalar(rhs)
        error('''E'' property must be a scalar');
      end
      b.E = rhs;
    end
    % ==
    function b = set.I(b, rhs)
      % ---------------------
      % - sets the I property
      % ---------------------
      if ~isScalar(rhs)
        error('''I'' property must be a scalar');
      end
      b.I = rhs;
    end
    % ==
    function b = set.L(b, rhs)
      % ---------------------
      % - sets the L property
      % ---------------------
      if ~isScalar(rhs)
        error('''L'' property must be a scalar');
      end
      b.L = rhs;
    end
    % ==
  end
  % ==
  methods % beam calculation member methods
    % ==
    function b = add(b, class, type, magnitude, distance, ends)
      % -----------------------
      % - add loads to the beam
      % -----------------------
      
      %% check the input arguments
      arguments
        b;
        class ...
        {mustBeTextScalar, ...
         mustBeMemberi(class, ["reaction" "hinge" ...
                               "concentrated" "distributed"])};
        type ...
        {mustBeTextScalar, mustBeMemberi(type, ["force" "moment"])};
        magnitude;
        distance;
        ends (1,2) logical = default_ends(class);
      end
      %% add the loads to the beam
      class = lower(class);
      type = lower(type);
      magnitude = array2symstr(magnitude);
      distance = array2symstr(distance);
      b.load(end+1,:) = {class type magnitude distance ends};
    end
    % ==
    function b = convert2cellsym(b, options)
      % -------------------------------
      % - converts the variables of the
      %   load table to cell arrays
      %   of symbolc arrays
      % -------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        b;
        options.Mode ...
        {mustBeTextScalar, ...
         mustBeMemberi(options.Mode, ["ignore" "nan"])} = "ignore";
      end
      % check the conversion mode
      Mode = lower(options.Mode);
      %% case for non-scalar beams
      if isempty(b)
        return;
      elseif ~isscalar(b)
        for k = 1:numel(b)
          b(k) = b(k).convert2cellsym('Mode', Mode);
        end
        return;
      end
      %% convert to cell arrays of symbolic arrays
      switch Mode
        case "ignore"
          Args = {'ErrorHandler' @ignore_args 'UniformOutput' false};
        case "nan"
          Args = {'ErrorHandler' @nan_args 'UniformOutput' false};
      end
      for k = ["magnitude" "distance"]
        b.load.(k) = cellfun(@array2sym, b.load.(k), Args{:});
      end
    end
    % ==
    function b = convert2cellsymstr(b, options)
      % -------------------------------
      % - converts the variables of the
      %   load table to cell arrays
      %   of symbolic character vectors
      % -------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        b;
        options.Mode ...
        {mustBeTextScalar, ...
         mustBeMemberi(options.Mode, ["ignore" "nan"])} = "ignore";
      end
      % check the conversion mode
      Mode = lower(options.Mode);

      %% case for non-scalar beams
      if isempty(b)
        return;
      elseif ~isscalar(b)
        for k = 1:numel(b)
          b(k) = b(k).convert2cellstr('Mode', Mode);
        end
        return;
      end
      %% convert to cell arrays of symbolic character vectors
      switch Mode
        case "ignore"
          Args = {'ErrorHandler' @ignore_args 'UniformOutput' false};
        case "nan"
          Args = {'ErrorHandler' @nan_args 'UniformOutput' false};
      end
      for k = ["magnitude" "distance"]
        b.load.(k) = cellfun(@array2symstr, b.load.(k), Args{:});
        symbolics = cellfun(@issym, b.load.(k));
        b.load.(k)(symbolics) = {'NaN'};
      end
    end
    % ==
    function b = convert2string(b, options)
      % -------------------------------
      % - converts the variables of the
      %   load table to string arrays
      % -------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        b;
        options.Mode ...
        {mustBeTextScalar, ...
         mustBeMemberi(options.Mode, ["ignore" "nan"])} = "ignore";
      end
      % check the conversion mode
      Mode = lower(options.Mode);
      %% case for non-scalar beams
      if isempty(b)
        return;
      elseif ~isscalar(b)
        for k = 1:numel(b)
          b(k) = b(k).convert2string('Mode', Mode);
        end
        return;
      end
      %% convert to string arrays
      switch Mode
        case "ignore"
          Args = {'ErrorHandler' @ignore_args 'UniformOutput' false}; 
        case "nan"
          Args = {'ErrorHandler' @nan_args 'UniformOutput' false};
      end
      for k = ["magnitude" "distance"]
        if ~isstring(b.load.(k))
          b.load.(k) = cellfun(@array2symstr, b.load.(k), Args{:});
          chars = cellfun(@ischar, b.load.(k));
          symbolics = cellfun(@issym, b.load.(k));
          b.load.(k)(~chars & ~symbolics) = {missing};
          b.load.(k) = string(b.load.(k));
          b.load.(k)(symbolics) = "NaN";
        end
      end
    end
    % ==
    function b = setL(b, Lnew)
      % ---------------------------------------
      % - sets the beam's length to Lnew
      % - then divides all valid beam distances
      %   by their prime scale factor value
      %   and then multiplies them by the
      %   value of the new beam length Lnew
      % ---------------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        b;
        Lnew sym;
      end
      % check the argument dimensions
      if ~isScalar(Lnew)
        error('''Lnew'' must be a scalar');
      end
      % check the argument units
      if ~checkUnits(sum(sym(Lnew)), 'Compatible')
        error('''Lnew'' must have compatible units');
      end
      %% case for non-scalar beams
      if isempty(b)
        return;
      elseif ~isscalar(b)
        for k = 1:numel(b)
          b(k) = b(k).setL(Lnew);
        end
        return;
      end
      %% convert the load distances to symbolic
      func = @(arg) isTextScalar(arg, ["char" "string" "cell of char"]);
      Args = {'ErrorHandler' @nan_args 'UniformOutput' false};
      uniform = Args(3:4);
      distance = cellfun(@array2sym, b.load.distance, Args{:});
      TextScalars = cellfun(func, b.load.distance);
      %% compute the load distance cell array locations
      func = @(arg) checkUnits(arg, 'Compatible');
      finite = cellfun(@isallfinite, b.load.distance);
      col = cellfun(@sum, convert2col(distance), uniform{:});
      compatible = cellfun(func, col);
      %% set the new beam length and new load distances
      if isAlways(Lnew > 0, 'Unknown', 'true')
        IAC = {'IgnoreAnalyticConstraints' true};
        new_distance = distance(finite & compatible);
        for k = 1:length(new_distance)
          new_distance{k} = removeUnits(new_distance{k}/b.L)*Lnew;
          new_distance{k} = simplify(new_distance{k}, IAC{:});
        end
        b.load.distance(finite & compatible) = new_distance;
        distance = b.load.distance(TextScalars);
        b.load.distance(TextScalars) = cellfun(@char, distance, uniform{:});
        b.L = Lnew;
      end
    end
    % ==
    function [y dy m v w rs ra hs ha] = elastic_curve(b, options)
      % --------------------------------
      % - computes the elastic curve
      %   of the beam as a function of
      %   the beam distance variable 'x'
      % --------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        b;
        options.Mode ...
        {mustBeText, ...
         mustBeMemberi(options.Mode, ["simplify" ...
                                      "factor" ...
                                      "factor full" ...
                                      "factor complex" ...
                                      "factor real" ...
                                      "simplify fraction" ...
                                      "simplify fraction expand"])} = ...
                                      "simplify";
        options.Var sym = sym('x');
      end
      % check the simplification mode
      Mode = string(lower(options.Mode));
      if ~isStringArray(Mode, 'ArrayDim', size(b)) && ...
         ~isStringScalar(Mode) && ~isempty(b)
        str = stack('the simplification mode must be', ...
                    'a text array with the same size as the beam');
        error(str);
      end
      % check the beam distance variable
      x = options.Var;
      if issymfun(x)
        x = formula(x);
      end
      if ~issymvararray(x, 'Dim', size(b)) && ...
         ~issymvarscalar(x) && ~isempty(b)
        str = stack('the beam distance variable must be:', ...
                    'an array of symbolic variables', ...
                    'with the same size as the beam');
        error(str);
      end
      %% case for non-scalar beams
      if isempty(b)
        [y dy m v w ra ha] = deal(sym.empty);
        [rs hs] = deal(struct.empty);
        return;
      elseif ~isscalar(b)
        try
          [~, Mode x] = scalar_expand(b, Mode, x);
          [y dy m v w rs ra hs ha] = deal(cell(size(b)));
          for k = 1:numel(b)
            [y{k} dy{k} m{k} v{k} w{k} rs{k} ra{k} hs{k} ha{k}] = ...
            b(k).elastic_curve('Mode', Mode(k), 'Var', x(k));
          end
          return;
        catch Error
          str = 'for the beam with linear index %d:\n%s';
          new_Error = MException('', str, k, Error.message);
          if ~isempty(Error.cause)
            throw(addCause(new_Error, Error.cause{1}));
          else
            throw(new_Error);
          end
        end
      end
      %% convert the load variables to cell arrays of symbolic arrays
      b = b.convert2cellsym('Mode', 'nan');
      uniform = {'UniformOutput' false};
      b.load.magnitude = cellfun(@formula, b.load.magnitude, uniform{:});
      b.load.distance = cellfun(@formula, b.load.distance, uniform{:});
      b.E = formula(b.E);
      b.I = formula(b.I);
      b.L = formula(b.L);
      num_loads = height(b.load);
      %% compute these useful values
      % frequrently used arrays
      IAC = {'IgnoreAnalyticConstraints' true};
      Full = {'FactorMode' 'full'};
      Complex = {'FactorMode' 'complex'};
      Real = {'FactorMode' 'real'};
      Expand = {'Expand' true};
      iA_str = 'unable to compute the elastic curve';
      % assumptions
      old_assum = assumptions;
      cleanup = onCleanup(@() setassum(old_assum, 'Mode', 'clear'));
      if isAlways(b.L > 0, 'Unknown', 'false') || ~issymnum(b.L)
        setassum(0 < x & x < b.L, 'Mode', 'append');
      end
      % table variables
      class = b.load.class;
      type = b.load.type;
      magnitude = b.load.magnitude;
      distance = b.load.distance;
      ends = b.load.ends;
      % class locations
      reaction_loc = class == "reaction";
      hinge_loc = class == "hinge";
      concentrated_loc = class == "concentrated";
      distributed_loc = class == "distributed";
      % type locations
      force_loc = type == "force";
      moment_loc = type == "moment";
      % reaction loads table
      reaction = b.load(reaction_loc,:);
      reaction_force_loc = reaction.type == "force";
      reaction_moment_loc = reaction.type == "moment";
      reaction_vars = symvar(sym(convert2col(reaction.magnitude)));
      num_reactions = length(reaction_vars);
      % hinge loads table
      hinge = b.load(hinge_loc,:);
      hinge_vars = symvar(sym(convert2col(hinge.magnitude)));
      num_hinges = length(hinge_vars);
      % concentrated loads table
      concentrated = b.load(concentrated_loc,:);
      concentrated_vars = symvar(sym(convert2col(concentrated.magnitude)));
      % distributed loads table
      distributed = b.load(distributed_loc,:);
      distributed_vars = symvar(sym(convert2col(distributed.magnitude)));
      % column vector of magnitudes and distances
      column.ml = sym(convert2col(magnitude));
      column.dl = sym(convert2col(distance));
      column.db = sym(convert2col(hinge.distance));
      % scalar cell array locations
      func = @(arg) isScalar(arg) && isallfinite(arg);
      scalar_magnitudes = cellfun(func, magnitude);
      scalar_distances = cellfun(func, distance);
      % vector cell array locations
      func = @(arg) isVector(arg, 'Len', 2) && isallfinite(arg);
      vector_distances = cellfun(func, distance);
      % symbolic variable cell array locations
      func = @issymvarmultiplescalar;
      symvarmultiplescalars = cellfun(func, magnitude);
      %% inspect the magnitudes and distances
      % check the magnitudes of the reactions and hinges
      if any((reaction_loc | hinge_loc) & ~symvarmultiplescalars)
        str = stack('the magnitudes of the reactions and hinges', ...
                    'must be numeric scalar multiples', ...
                    'of a symbolic variable scalar');
        error(str);
      end
      % check the magnitudes of the concentrated loads
      if any(concentrated_loc & ~scalar_magnitudes)
        str = stack('the magnitudes of the concentrated loads', ...
                    'must be numeric or symbolic scalars', ...
                    'with no Inf or NaN values');
        error(str);
      end
      % check the magnitudes of the distributed loads
      if any(distributed_loc & ~scalar_magnitudes)
        str = stack('the magnitudes of the distributed loads', ...
                    'must be numeric or symbolic scalars', ...
                    'with no Inf or NaN values');
        error(str);
      end
      % check the distances of the non-distributed loads
      if any(~distributed_loc & ~scalar_distances)
        str = stack('the distances of the non-distributed loads', ...
                    'must be numeric or symbolic scalars', ...
                    'with no Inf or NaN values');
        error(str);
      end
      % check the distances of the distributed loads
      if any(distributed_loc & ~vector_distances)
        str = stack('the distances of the distributed loads', ...
                    'must be numeric or symbolic vectors of length 2', ...
                    'with no Inf or NaN values');
        error(str);
      end
      %% inspect the beam length and distances
      % all distances must not contain 'x'
      for k = 1:2
        if k == 1
          vars = symvar(b.L);
          what = sprintf('beam length ''%s''', b.L);
        else
          vars = symvar(column.dl);
          what = 'distances';
        end
        if ismember(x, vars)
          str = stack('the %s must not contain', ...
                      'the beam distance variable ''%s''');
          error(str, what, x);
        end
      end
      % the beam length must be positive and finite
      str = 'the beam length ''%s'' must be positive and finite';
      if ~isAlwaysError(b.L > 0, str, b.L) || ~isfinite(b.L)
        error(str, b.L);
      end
      % the distances must have compatible units
      if ~checkUnits(sum(column.dl), 'Compatible')
        error('the distances must have compatible units');
      end
      % the distances must be in the range 0 <= d <= L
      str = stack('the distances must be at least zero,', ...
                  'but at most the beam length ''%s''');
      dl_in_range = 0 <= column.dl & column.dl <= b.L;
      dl_in_range = isAlwaysError(dl_in_range, str, b.L);
      if ~all(dl_in_range)
        error(str, b.L);
      end
      %% compute these necessary values
      % load distance matrix
      Args = {'Mode' 'pw' 'Var' x};
      matrix.dl = symunion(0, column.dl, b.L, ...
                           discont(b.E, Args{:}), ...
                           discont(b.I, Args{:}));
      matrix.dl = [matrix.dl(1:end-1) matrix.dl(2:end)];
      num_load_ranges = size(matrix.dl, 1);
      % beam distance matrix
      matrix.db = symunique([0; column.db; b.L]);
      matrix.db = [matrix.db(1:end-1) matrix.db(2:end)];
      num_beam_ranges = size(matrix.db, 1);
      % equations and unknowns
      dim = [1 2*num_load_ranges];
      Vars2Exclude = symvar([column.ml; column.dl; x; b.E; b.I]);
      C = randsym(dim, 'Vars2Exclude', Vars2Exclude);
      unknowns = [union(reaction_vars, hinge_vars) C];
      eqn = sym.zeros(length(unknowns), 1);
      ind = 2*num_beam_ranges+1;
      % combined reaction and concentrated loads table
      rc = b.load(reaction_loc | concentrated_loc,:);
      rc.magnitude = sym(rc.magnitude);
      rc.distance = sym(rc.distance);
      rc_force_loc = rc.type == 'force';
      rc_moment_loc = rc.type == 'moment';
      distance_equals_zero = isAlwaysError(rc.distance == 0, iA_str);
      zero_vals = zeros(num_beam_ranges-1, 1);
      %% inspect the loads
      % internal hinges cannot have bending moments
      if any(hinge_loc & moment_loc)
        error('internal hinges cannot have bending moments');
      end
      % the magnitudes of the reactions and hinges
      % must not be scalar multiples of one another
      reaction.magnitude = sym(reaction.magnitude);
      hinge.magnitude = sym(hinge.magnitude);
      lhs = [reaction.magnitude; hinge.magnitude];
      rhs = setdiff(unknowns, C);
      if ~isequallen(lhs, rhs)
        str = stack('at least 2 reactions and/or hinges', ...
                    'contain the same magnitude');
        error(str);
      end
      % the magnitudes of the non-distributed loads
      % must not contain the beam distance variable
      vars = [reaction_vars hinge_vars concentrated_vars];
      if ismember(x, vars)
        str = stack('the magnitudes of the non-distributed loads', ...
                    'must not contain the beam distance variable ''%s''');
        error(str, x);
      end
      % the magniudes of the concentrated and distributed loads
      % must not contain the magnitudes of the reactions and hinges
      vars = [concentrated_vars distributed_vars];
      if any(ismember(vars, [reaction_vars hinge_vars]))
        str = stack('the magnitudes of the', ...
                    'concentrated and distributed loads', ...
                    'must not contain the magnitudes', ...
                    'of the reactions and hinges');
        error(str);
      end
      % the distances of the reaction moments
      % must be zero or the beam length
      str = stack('the distances of the reaction moments', ...
                  'must be zero or the beam length ''%s''');
      reaction.distance = sym(reaction.distance);
      d = reaction.distance(reaction_moment_loc);
      if ~all(symismember(d, [0 b.L]))
        error(str, b.L);
      end
      % the distances of the hinges
      % must not be zero or the beam length
      str = stack('the distances of the hinges', ...
                  'must not be zero or the beam length ''%s''');
      hinge.distance = sym(hinge.distance);
      d = hinge.distance;
      if any(symismember(d, [0 b.L]))
        error(str, b.L);
      end
      % there must be unique distances values
      % for the reactions and hinges
      for k = ["forces" "moments"]
        if k == "forces"
          loc = reaction_force_loc;
        else
          loc = reaction_moment_loc;
        end
        if ~symisunique(reaction.distance(loc))
          str = stack('at least 2 reaction %s', ...
                      'have the same distance');
          error(str, k);
        end
      end
      if ~symisunique(hinge.distance)
        str = stack('at least 2 hinge forces', ...
                    'have the same distance');
        error(str);
      end
      % the distances of all loads on the beam
      % must not contain the magnitudes of the reactions and hinges
      vars = symvar(matrix.dl);
      if any(ismember(vars, [reaction_vars hinge_vars]))
        str = stack('the distances must not contain', ...
                    'the magnitudes of the', ...
                    'reactions and hinges');
        error(str);
      end
      % cannot add both values to left and right
      % of the non-distributed loads
      bool = [reaction.ends; hinge.ends; concentrated.ends];
      if any(all(bool, 2))
        str = stack('cannot add both values', ...
                    'to the left and right', ...
                    'of the non-distributed loads');
        error(str);
      end
      % the beam must be stable
      if ~beam.stable(num_reactions, num_hinges)
        error('the beam must be stable');
      end
      %% compute the piecewise functions for the loads
      % compute the distributed load formulas
      [fd md] = deal(repmat({sym(0)}, num_loads, 1));
      for k = find(distributed_loc).'
        [x1 x2 Vars2Exclude] = randsym('Vars2Exclude', Vars2Exclude);
        if type(k) == "force"
          fd{k}(x1, x2) = int(magnitude{k}, x, x1, x2, IAC{:});
          md{k}(x1, x2) = int(magnitude{k}*x, x, x1, x2, IAC{:});
        else
          fd{k}(x1, x2) = fd{k};
          md{k}(x1, x2) = int(magnitude{k}, x, x1, x2, IAC{:});
        end
      end
      % compute the singularity functions for the loads
      [m v w] = deal(sym.zeros(num_loads, 1));
      for k = 1:num_loads
        if class(k) == "distributed"
          % piecewise arguments
          if ~isrow(distance{k})
            distance{k} = distance{k}.';
          end
          distance{k} = symsort(distance{k});
          d = num2cell(distance{k});
          if isAlwaysError(d{1} == d{2}, iA_str)
            continue;
          end
          [m_args v_args w_args] = deal({});
          % first portion
          if isAlwaysError(d{1} ~= 0, iA_str)
            if ends(k,1)
              range = x < d{1};
            else
              range = x <= d{1};
            end
            m_args = [m_args; {range; 0}];
            v_args = [v_args; {range; 0}];
            w_args = [w_args; {range; 0}];
          end
          % second portion
          if ends(k,1)
            range = d{1} <= x;
          else
            range = d{1} < x;
          end
          if ends(k,2)
            range = range & x <= d{2};
          else
            range = range & x < d{2};
          end          
          if type(k) == "force"
            expr = fd{k}(d{1}, x)*x-md{k}(d{1}, x);
            m_args = [m_args; {range; expr}];
            v_args = [v_args; {range; diff(expr, x)}];
            w_args = [w_args; {range; diff(expr, x, 2)}];
          else
            expr = -md{k}(d{1}, x);
            m_args = [m_args; {range; expr}];
            v_args = [v_args; {range; 0}];
            w_args = [w_args; {range; 0}];
          end
          % third portion
          if isAlwaysError(d{2} ~= b.L, iA_str)
            if ends(k,2)
              range = d{2} < x;
            else
              range = d{2} <= x;
            end
            if type(k) == "force"
              expr = fd{k}(d{:})*x-md{k}(d{:});
              m_args = [m_args; {range; expr}];
              v_args = [v_args; {range; diff(expr, x)}];
              w_args = [w_args; {range; diff(expr, x, 2)}];
            else
              expr = -md{k}(d{:});
              m_args = [m_args; {range; expr}];
              v_args = [v_args; {range; 0}];
              w_args = [w_args; {range; 0}];
            end
          end
          % overall piecewise expression
          m(k) = piecewise(m_args{:});
          v(k) = piecewise(v_args{:});
          w(k) = piecewise(w_args{:});
        elseif class(k) ~= "hinge"
          % piecewise arguments
          m_args = {};
          if type(k) == "force"
            v_args = {};
          end
          % first portion
          if isAlwaysError(distance{k} ~= 0, iA_str)
            if ends(k,1)
              range = x <= distance{k};
            else
              range = x < distance{k};
            end
            m_args = [m_args; {range; 0}];
            if type(k) == "force"
              v_args = [v_args; {range; 0}];
            end
          end
          % second portion
          if ends(k,2)
            range = distance{k} <= x;
          else
            range = distance{k} < x;
          end
          if type(k) == "force"
            m_args = [m_args; {range; magnitude{k}*(x-distance{k})}];
            v_args = [v_args; {range; magnitude{k}}];
          else
            m_args = [m_args; {range; -magnitude{k}}];
          end
          % overall piecewise expression
          m(k) = piecewise(m_args{:});
          if type(k) == "force"
            v(k) = piecewise(v_args{:});
          end
        end
      end
      % compute the total piecewise function
      m(x) = sum(m);
      v(x) = sum(v);
      w(x) = sum(w);
      %% compute the hinge force matrix
      if any(rc_force_loc)
        loc = rc_force_loc & distance_equals_zero;
        left = [sum(rc.magnitude(loc)); zero_vals];
        right = sym.zeros(num_beam_ranges, 1);
        for k = 1:num_beam_ranges
          equal_distance = rc.distance == matrix.db(k,2);
          equal_distance = isAlwaysError(equal_distance, iA_str);
          loc = rc_force_loc & equal_distance;
          right(k) = sum(rc.magnitude(loc));
        end
        frc = [left right];
      else
        frc = 0;
      end
      matrix.fh = [hinge.magnitude -hinge.magnitude].';
      matrix.fh = reshape([0; matrix.fh(:); 0], 2, []).'+frc;
      %% compute the hinge moment matrix
      if any(rc_moment_loc)
        loc = rc_moment_loc & distance_equals_zero;
        left = [sum(rc.magnitude(loc)); zero_vals];
        right = sym.zeros(num_beam_ranges, 1);
        for k = 1:num_beam_ranges
          equal_distance = rc.distance == matrix.db(k,2);
          equal_distance = isAlwaysError(equal_distance, iA_str);
          loc = rc_moment_loc & equal_distance;
          right(k) = sum(rc.magnitude(loc));
        end
        mrc = [left right];
      else
        mrc = 0;
      end
      matrix.mh = matrix.fh.*matrix.db+mrc;
      %% statics (sum of forces and moments == 0 [+up]/[+ccw])
      in_range = false(num_loads, 1);
      for k = 1:num_beam_ranges
        % -------------------------------
        % - in range locations
        %   for the non-distributed loads
        % -------------------------------
        loc = ~distributed_loc;
        left = matrix.db(k,1) < distance(loc);
        right = distance(loc) < matrix.db(k,2);
        in_range(loc) = isAlwaysError(left & right, iA_str);
        % ---------------------------------
        % - in range locations
        %   for the distributed loads
        % - case 1: at least one end of the
        %           distributed load lies
        %           within the ends
        %           of the beam range
        % ---------------------------------
        loc = distributed_loc;
        left = matrix.db(k,1) <= distance(loc);
        right = distance(loc) <= matrix.db(k,2);
        case1 = any(isAlwaysError(left & right, iA_str), 2);
        % ---------------------------------
        % - in range locations
        %   for the distributed loads
        % - case 2: both ends of the
        %           beam range
        %           lie between the ends
        %           of the distributed load
        % ---------------------------------
        d = sym(distance(loc));
        if isempty(d)
          d = reshape(d, 0, 2);
        end
        left = d(:,1) < matrix.db(k,1);
        right = matrix.db(k,2) < d(:,2);
        case2 = all(isAlwaysError(left & right, iA_str), 2);
        in_range(loc) = case1 | case2;
        % ---------------------------
        % - in range distances
        %   for the distributed loads
        % ---------------------------
        loc = distributed_loc & in_range;
        dl_in_range = distance(loc);
        num_in_range = length(dl_in_range);
        x1 = sym.zeros(num_in_range, 1);
        x2 = x1;
        for p = 1:num_in_range
          x1(p) = symmax([matrix.db(k,1) dl_in_range{p}(1)], iA_str);
          x2(p) = symmin([matrix.db(k,2) dl_in_range{p}(2)], iA_str);
        end
        % ------------
        % - force sums
        % ------------
        % sum of the reaction and concentrated forces
        % that are in between the beam range
        loc = (reaction_loc | concentrated_loc) & force_loc & in_range;
        sum_frc = sum(sym(magnitude(loc)));
        % sum of the reaction and concentrated forces
        % that are at the ends of the connetion range
        sum_fh = sum(matrix.fh(k,:));
        % sum of the distributed forces
        loc = distributed_loc & in_range;
        fd_in_range = fd(loc);
        sum_fd = 0;
        for p = 1:num_in_range
          sum_fd = sum_fd+fd_in_range{p}(x1(p), x2(p));
        end
        % -------------
        % - moment sums
        % -------------
        % sum of the moments from the reaction and concentrated forces
        % that are in between the beam range
        loc = (reaction_loc | concentrated_loc) & force_loc & in_range;
        magnitude_col = sym(magnitude(loc));
        distance_col = sym(distance(loc));
        sum_mrc.force = sum(magnitude_col.*distance_col);
        % sum of the reaction and concentrated moments
        % that are in between the beam range
        loc = (reaction_loc | concentrated_loc) & moment_loc & in_range;
        sum_mrc.moment = sum(sym(magnitude(loc)));
        % sum of the reaction and concentrated moments
        % that are at the ends of the connetion range
        sum_mh = sum(matrix.mh(k,:));
        % sum of the distributed moments
        loc = distributed_loc & in_range;
        md_in_range = md(loc);
        sum_md = 0;
        for p = 1:num_in_range
          sum_md = sum_md+md_in_range{p}(x1(p), x2(p));
        end
        % ------------------------------
        % - static equilibrium equations
        % ------------------------------
        force_eqn = sum_frc+sum_fh+sum_fd == 0;
        moment_eqn = sum_mrc.force+sum_mrc.moment+sum_mh+sum_md == 0;
        eqn(2*k-1:2*k) = [force_eqn; moment_eqn];
      end
      %% elastic curve (E*I*d^2y/dx^2 == M)
      % compute the singularity functions for the elastic curve
      [y dy] = deal(sym.zeros(num_load_ranges, 1));
      [y_args dy_args] = deal(cell(2*num_load_ranges, 1));
      for k = 1:num_load_ranges
        % compute the load range
        d = matrix.dl(k,:);
        range = d(1) < x & x <= d(2);
        setassum([d(1) < x & x < d(2), old_assum], iA_str);
        % compute the elastic curve equation
        dy(k) = simplify(m/b.EI, IAC{:});
        dy(k) = int(dy(k), x, IAC{:})+C(2*k-1);
        y(k) = int(dy(k), x, IAC{:})+C(2*k);
        % compute the piecewise arguments
        y_args(2*k-1:2*k) = {range; y(k)};
        dy_args(2*k-1:2*k) = {range; dy(k)};
      end
      setassum([0 < x & x < b.L, old_assum], iA_str);
      % apply the boundary conditions
      for k = 1:num_load_ranges
        % boundary conditions for the reactions
        for p = 1:2
          % distance location
          equal_distance = reaction.distance == matrix.dl(k,p);
          equal_distance = isAlwaysError(equal_distance, iA_str);
          % reaction force condition
          reaction_force_found = reaction_force_loc & equal_distance;
          if any(reaction_force_found)
            eqn(ind) = subs(y(k), x, matrix.dl(k,p)) == 0;
            ind = ind+1;
          end
          % reaction moment condition
          reaction_moment_found = reaction_moment_loc & equal_distance;
          if any(reaction_moment_found)
            eqn(ind) = subs(dy(k), x, matrix.dl(k,p)) == 0;
            ind = ind+1;
          end
        end
        % boundary conditions for continuity
        if k ~= num_load_ranges
          % displacement condition
          reaction_found = reaction.distance == matrix.dl(k,2);
          reaction_found = isAlwaysError(reaction_found, iA_str);
          if ~any(reaction_found)
            lhs = subs(y(k), x, matrix.dl(k,2));
            rhs = subs(y(k+1), x, matrix.dl(k,2));
            eqn(ind) = lhs == rhs;
            ind = ind+1;
          end
          % slope condition
          hinge_found = hinge.distance == matrix.dl(k,2);
          hinge_found = isAlwaysError(hinge_found, iA_str);
          if ~any(hinge_found)
            lhs = subs(dy(k), x, matrix.dl(k,2));
            rhs = subs(dy(k+1), x, matrix.dl(k,2));
            eqn(ind) = lhs == rhs;
            ind = ind+1;
          end
        end
      end
      % compute the total elastic curve
      y(x) = piecewise(y_args{:});
      dy(x) = piecewise(dy_args{:});
      %% solve for the unknown variables
      % compute the solution
      soln = solve(eqn, unknowns);
      fields = fieldnames(soln);
      % compute the reaction and hinge structure arrays
      rs = rmfield(soln, fields(~ismember(fields, reaction_vars)));
      hs = rmfield(soln, fields(~ismember(fields, hinge_vars)));
      if ~isempty(soln.(fields{1}))
        % reaction structure array
        for field = string(fieldnames(rs)).'
          rs.(field) = simplify(rs.(field), IAC{:});
          switch Mode
            case "factor"
              rs.(field) = prodfactor(rs.(field));
            case "factor full"
              rs.(field) = prodfactor(rs.(field), Full{:});
            case "factor complex"
              rs.(field) = prodfactor(rs.(field), Complex{:});
            case "factor real"
              rs.(field) = prodfactor(rs.(field), Real{:});
            case "simplify fraction"
              rs.(field) = simplifyFraction(rs.(field));
            case "simplify fraction expand"
              rs.(field) = simplifyFraction(rs.(field), Expand{:});
          end
        end
        % hinge structure array
        for field = string(fieldnames(hs)).'
          hs.(field) = simplify(hs.(field), IAC{:});
          switch Mode
            case "factor"
              hs.(field) = prodfactor(hs.(field));
            case "factor full"
              hs.(field) = prodfactor(hs.(field), Full{:});
            case "factor complex"
              hs.(field) = prodfactor(hs.(field), Complex{:});
            case "factor real"
              hs.(field) = prodfactor(hs.(field), Real{:});
            case "simplify fraction"
              hs.(field) = simplifyFraction(hs.(field));
            case "simplify fraction expand"
              hs.(field) = simplifyFraction(hs.(field), Expand{:});
          end
        end
      end
      % compute the reaction and hinge symbolic arrays
      if ~isempty(soln.(fields{1}))
        ra = [sym(fieldnames(rs)) sym(struct2cell(rs))];
        ha = [sym(fieldnames(hs)) sym(struct2cell(hs))];
      else
        ra = [sym(fieldnames(rs)) nan(numFields(rs), 1)];
        ha = [sym(fieldnames(hs)) nan(numFields(hs), 1)];
      end
      % substitute the solution into the elastic curve
      y = subs(y, soln);
      dy = subs(dy, soln);
      m = subs(m, soln);
      v = subs(v, soln);
      w = subs(w, soln);
      % simplify the elastic curve
      y = simplify(y, IAC{:});
      dy = simplify(dy, IAC{:});
      m = simplify(m, IAC{:});
      v = simplify(v, IAC{:});
      w = simplify(w, IAC{:});
      switch Mode
        case "factor"
          y = prodfactor(y);
          dy = prodfactor(dy);
          m = prodfactor(m);
          v = prodfactor(v);
          w = prodfactor(w);
        case "factor full"
          y = prodfactor(y, Full{:});
          dy = prodfactor(dy, Full{:});
          m = prodfactor(m, Full{:});
          v = prodfactor(v, Full{:});
          w = prodfactor(w, Full{:});
        case "factor complex"
          y = prodfactor(y, Complex{:});
          dy = prodfactor(dy, Complex{:});
          m = prodfactor(m, Complex{:});
          v = prodfactor(v, Complex{:});
          w = prodfactor(w, Complex{:});
        case "factor real"
          y = prodfactor(y, Real{:});
          dy = prodfactor(dy, Real{:});
          m = prodfactor(m, Real{:});
          v = prodfactor(v, Real{:});
          w = prodfactor(w, Real{:});
        case "simplify fraction"
          y = simplifyFraction(y);
          dy = simplifyFraction(dy);
          m = simplifyFraction(m);
          v = simplifyFraction(v);
          w = simplifyFraction(w);
        case "simplify fraction expand"
          y = simplifyFraction(y, Expand{:});
          dy = simplifyFraction(dy, Expand{:});
          m = simplifyFraction(m, Expand{:});
          v = simplifyFraction(v, Expand{:});
          w = simplifyFraction(w, Expand{:});
      end
    end
    % ==
    function ue = strain_energy(b, m, x)
      % ----------------------------
      % - computes the strain energy
      %   of the entire beam
      % ----------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        b;
        m {mustBeA(m, ["numeric" "sym" "cell"])};
        x = 0;
      end
      % check the beam lengths
      if ~all(isAlways([b.L] > 0, 'Unknown', 'true'))
        error('the beam lengths must be positive');
      end
      % check the moment function
      if iscell(m)
        m = array2cellsym(m);
      elseif ~issym(m)
        m = sym(m);
      end
      % check the beam distance variables
      if nargin == 2
        if iscell(m)
          func = @(arg) symvar(arg, 1);
          x = cellfun(func, m, 'UniformOutput', false);
          emptys = cellfun(@isempty, x);
          if any(emptys, 'all')
            Vars2Exclude = symvar([[b.E] [b.I] [b.L] [m{:}]]);
            [x{emptys}, ~] = randsym('Vars2Exclude', Vars2Exclude);
          elseif isempty(emptys)
            Vars2Exclude = symvar([[b.E] [b.I] [b.L]]);
            x = randsym('Vars2Exclude', Vars2Exclude);
          end
          x = sym(x);
        else
          x = symvar(m, 1);
          if isempty(x)
            Vars2Exclude = symvar([[b.E] [b.I] [b.L]]);
            x = randsym('Vars2Exclude', Vars2Exclude);
          end
        end
      end
      if ~isallsymvar(x)
        error('''x'' must be an array of symbolic variables');
      end
      % check the argument dimensions
      if ~compatible_dims(b, m, x)
        str = stack('''b'', ''m'', and ''x''', ...
                    'must have compatible dimensions');
        error(str);
      end
      %% compute the strain energy
      % initialize the strain energy array
      IAC = {'IgnorEAnalyticConstraints' true};
      [b m x] = scalar_expand(b, m, x);
      if any(cellfun(@isEmpty, {b m}))
        if issym(m)
          ue = sym.empty;
        else
          ue = {};
        end
        return;
      elseif issym(m)
        ue = sym.zeros(size(b));
      else
        ue = cell(size(b));
      end
      % compute the elastic strain energy
      for k = 1:numel(ue)
        if issym(m)
          ue(k) = index(m, k)^2/(2*formula(b(k).EI));
          ue(k) = simplify(int(ue(k), x(k), 0, b(k).L, IAC{:}), IAC{:});
        else
          ue{k} = m{k}^2/(2*formula(b(k).EI));
          ue{k} = simplify(int(ue{k}, x(k), 0, b(k).L, IAC{:}), IAC{:});
        end
      end
    end
    % ==
    function expr = EI(b)
      % ---------------------------------
      % - computes the product of E and I
      % ---------------------------------
      try
        expr = b.E*b.I;
      catch
        expr = formula(sym(b.E))*formula(sym(b.I));
      end
    end
    % ==
    function expr = EIL(b)
      % -------------------------------------
      % - computes the product of E, I, and L
      % -------------------------------------
      try
        expr = b.E*b.I*b.L;
      catch
        expr = formula(sym(b.E))*formula(sym(b.I))*formula(sym(b.L));
      end
    end
    % ==
  end
  % ==
  methods (Static) % beam calculation static methods
    % ==
    function [bool diff] = stable(R, H)
      % ------------------------------------
      % - returns true if the beam is stable
      % - the beam is stable
      %   if R >= H+1
      % - where:
      %   R == the number of reactions
      %   H == the number of internal hinges
      %   R >= 0, H >= 0
      % ------------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        R double {mustBeNonempty, mustBeInteger, mustBeNonnegative};
        H double {mustBeNonempty, mustBeInteger, mustBeNonnegative};
      end
      % check the argument dimensions
      if ~compatible_dims(R, H)
        error('input arguments must have compatible dimensions');
      end
      %% determine if the beam is stable
      lhs = R;
      rhs = H+1;
      bool = lhs >= rhs;
      diff = lhs-rhs;
    end
    % ==
    function bool = statically_determinate(R, H)
      % ------------------------------------
      % - returns true if the beam
      %   is statically determinate
      % - the beam is
      %   statically determinate
      %   if R == H+1 or H+2
      % - where:
      %   R == the number of reactions
      %   H == the number of internal hinges
      %   R >= 0, H >= 0
      % ------------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        R double {mustBeNonempty, mustBeInteger, mustBeNonnegative};
        H double {mustBeNonempty, mustBeInteger, mustBeNonnegative};
      end
      % check the argument dimensions
      if ~compatible_dims(R, H)
        error('input arguments must have compatible dimensions');
      end
      %% determine if the beam is statically determinate
      lhs = {R R};
      rhs = {H+1 H+2};
      uniform = {'UniformOutput' false};
      bool = fold(@or, cellfun(@eq, lhs, rhs, uniform{:}));
    end
    % ==
    function answer = range_test(func, num, x0, x)
      % ----------------------------
      % - range test function for
      %   the elastic_curve function
      % ----------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        func sym;
        num (1,1) double {mustBeInteger, mustBePositive};
        x0 sym;
        x sym = symvar(func, 1);
      end
      % check the elastic curve function
      if ~ispiecewisescalar(func) || (numBranches(func) < 2)
        str = stack('''func'' must be a piecewise scalar', ...
                    'with at least 2 branches');
        error(str);
      end
      % check the range value
      if ~isScalar(x0)
        error('''x0'' must be a scalar');
      end
      % check the range variable
      if ~issymvarscalar(x)
        error('''x'' must be a symbolic variable scalar');
      end
      %% compute the range test value
      IAC = {'IgnoreAnalyticConstraints' true};
      answer = subs(expression(func, num:num+1), x, x0);
      answer = simplify(answer(1)-answer(2), IAC{:});
    end
    % ==
    function [yn Qn In] = neutral_axis(yc, Ac, Ic)
      % -------------------------------------------------------
      % - calculates the neutral axis location (yn),
      %   the first moment of area about the neutral axis (Qn),
      %   the moment of inertia abount the neutal axis (In),
      % -------------------------------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        yc {mustBeA(yc, ["numeric" "sym"])};
        Ac {mustBeA(Ac, ["numeric" "sym"])};
        Ic {mustBeA(Ic, ["numeric" "sym"])};
      end
      % check the argument dimensions
      Args = {yc Ac Ic};
      if ~compatible_dims(Args{:})
        error('input arguments must have compatible dimensions');
      end
      symbolics = cellfun(@issym, Args);
      %% compute the neutral axis calculations
      yc_col = reshape(yc, [], 1);
      Ac_col = reshape(Ac, [], 1);
      yn = sum(yc_col.*Ac_col)/sum(Ac_col);
      Qn = (yc-yn).*Ac;
      In = Ic+Ac.*(yc-yn).^2;
      if any(symbolics)
        yn = simplify(yn, 'IgnoreAnalyticConstraints', true);
        Qn = simplify(Qn, 'IgnoreAnalyticConstraints', true);
        In = simplify(In, 'IgnoreAnalyticConstraints', true);
      end
    end
    % ==
    function Inyz = Iyz(yc, zc, Ac, Icy, Icz, Icyz)
      % -----------------------------------
      % - calculates the product of inertia
      %   about the neutral axis
      % -----------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        yc {mustBeA(yc, ["numeric" "sym"])};
        zc {mustBeA(zc, ["numeric" "sym"])};
        Ac {mustBeA(Ac, ["numeric" "sym"])};
        Icy {mustBeA(Icy, ["numeric" "sym"])};
        Icz {mustBeA(Icz, ["numeric" "sym"])};
        Icyz {mustBeA(Icyz, ["numeric" "sym"])} = 0;
      end
      % check the argument dimensions
      Args = {yc zc Ac Icy Icz Icyz};
      if ~compatible_dims(Args{:})
        error('input arguments must have compatible dimensions');
      end
      %% compute the product of inertia
      yn = beam.neutral_axis(yc, Ac, Icz);
      zn = beam.neutral_axis(zc, Ac, Icy);
      Inyz = Icyz+Ac.*(yc-yn).*(zc-zn);
    end
    % ==
    function [sigma alpha] = unsymmetric(My, Mz, Iy, Iz, y, z)
      % ----------------------------------------------------
      % - calculates the unsymmetric bending stress (sigma),
      %   the neutral axis angle (alpha)
      % ----------------------------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        My {mustBeA(My, ["numeric" "sym"])};
        Mz {mustBeA(Mz, ["numeric" "sym"])};
        Iy {mustBeA(Iy, ["numeric" "sym"])};
        Iz {mustBeA(Iz, ["numeric" "sym"])};
        y {mustBeA(y, ["numeric" "sym"])} = 0;
        z {mustBeA(z, ["numeric" "sym"])} = 0;
      end
      % check the argument dimensions
      Args = {My Mz Iy Iz y z};
      if ~compatible_dims(Args{:})
        error('input arguments must have compatible dimensions');
      end
      symbolics = cellfun(@issym, Args);
      %% compute the unsymmetric calculations
      sigma = -Mz.*y./Iz+My.*z./Iy;
      alpha = atand(My.*Iz./(Mz.*Iy));
      if any(symbolics)
        sigma = simplify(sigma, 'IgnoreAnalyticConstraints', true);
        alpha = simplify(alpha, 'IgnoreAnalyticConstraints', true);
        alpha = alpha*symunit('deg');
      end
    end
    % ==
    function [sigmaxm sigmaym tauxym] = mohr(sigmax, sigmay, tauxy, theta)
      % ------------------------
      % - computes the equations
      %   for the Mohr's Circle
      % ------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        sigmax {mustBeA(sigmax, ["numeric" "sym"])};
        sigmay {mustBeA(sigmay, ["numeric" "sym"])};
        tauxy {mustBeA(tauxy, ["numeric" "sym"])};
        theta {mustBeA(theta, ["numeric" "sym"])};
      end
      % check the argument dimensions
      Args = {sigmax sigmay tauxy theta};
      if ~compatible_dims(Args{:})
        error('input arguments must have compatible dimensions');
      end
      symbolics = cellfun(@issym, Args);
      %% compute the Mohr's Circle equations
      sigmaavg = (sigmax+sigmay)/2;
      sigmadiff = (sigmax-sigmay)/2;
      if ~any(hasUnits(theta), 'all')
        sigmaxm = sigmaavg+sigmadiff.*cosd(2*theta)+tauxy.*sind(2*theta);
        sigmaym = sigmaavg-sigmadiff.*cosd(2*theta)-tauxy.*sind(2*theta);
        tauxym = -sigmadiff.*sind(2*theta)+tauxy.*cosd(2*theta);
      else
        sigmaxm = sigmaavg+sigmadiff.*cos(2*theta)+tauxy.*sin(2*theta);
        sigmaym = sigmaavg-sigmadiff.*cos(2*theta)-tauxy.*sin(2*theta);
        tauxym = -sigmadiff.*sin(2*theta)+tauxy.*cos(2*theta);
      end
      if any(symbolics)
        sigmaxm = simplify(sigmaxm, 'IgnoreAnalyticConstraints', true);
        sigmaym = simplify(sigmaym, 'IgnoreAnalyticConstraints', true);
        tauxym = simplify(tauxym, 'IgnoreAnalyticConstraints', true);
      end
    end
    % ==
    function [sigmaxp sigmayp tauxyp thetap] = principal(sigmax, sigmay, tauxy)
      % ----------------------------------
      % - computes the principal stresses
      %   from the Mohr's Circle equations
      % ----------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        sigmax {mustBeA(sigmax, ["numeric" "sym"])};
        sigmay {mustBeA(sigmay, ["numeric" "sym"])};
        tauxy {mustBeA(tauxy, ["numeric" "sym"])};
      end
      % check the argument dimensions
      Args = {sigmax sigmay tauxy};
      if ~compatible_dims(Args{:})
        error('input arguments must have compatible dimensions');
      end
      symbolics = cellfun(@issym, Args);
      deg = symunit('deg');
      unknown = {'Unknown' 'false'};
      uniform = {'UniformOutput' false};
      IAC = {'IgnoreAnalyticConstraints' true};
      %% compute the principal angles
      % first solution
      sigmadiff = (sigmax-sigmay)/2;
      thetap = atand(tauxy./sigmadiff)/2;
      if issymscalar(tauxy) && ~issymscalar(thetap)
        tauxy = repmat(tauxy, size(thetap));
      end
      if issymscalar(sigmadiff) && ~issymscalar(thetap)
        sigmadiff = repmat(sigmadiff, size(thetap));
      end
      tauxy_is_negative = isAlways(tauxy < 0, unknown{:});
      tauxy_is_non_negative = isAlways(tauxy >= 0, unknown{:});
      sigmadiff_is_zero = isAlways(sigmadiff == 0, unknown{:});
      thetap(tauxy_is_negative & sigmadiff_is_zero) = -45;
      thetap(tauxy_is_non_negative & sigmadiff_is_zero) = 45;
      % second solution
      if issymfun(thetap)
        thetapf = formula(thetap);
      else
        thetapf = thetap;
      end
      if numel(thetapf) <= 1
        thetap = [thetap thetap+90];
      else
        thetap1 = array2cell(thetap);
        thetap2 = array2cell(thetap+90);
        thetap = cellfun(@horzcat, thetap1, thetap2, uniform{:});
      end
      if any(symbolics)
        if ~iscell(thetap)
          thetap = simplify(thetap*deg, IAC{:});
        else
          for k = 1:2
            switch k
              case 1
                func = @(arg) mtimes(arg, deg);
              case 2
                func = @(arg) simplify(arg, IAC{:});
            end
          end
          thetap = cellfun(func, thetap, uniform{:});
        end
      end
      %% compute the principal stresses
      if ~iscell(thetap)
        Args = [Args {thetap}];
        [sigmaxp sigmayp tauxyp] = beam.mohr(Args{:});
      else
        % fix the scalar stress values
        Args(symfuns) = cellfun(@formula, Args(symfuns), uniform{:});
        scalars = cellfun(@isscalar, Args);
        sizes = cellfun(@size, Args, 'UniformOutput', false);
        dim = sizes(~scalars);
        if ~isempty(dim)
          dim = dim{1};
          if isnumscalar(sigmax) || issymscalar(sigmax)
            sigmax = repmat(sigmax, dim);
          end
          if isnumscalar(sigmay) || issymscalar(sigmay)
            sigmay = repmat(sigmay, dim);
          end
          if isnumscalar(tauxy) || issymscalar(tauxy)
            tauxy = repmat(tauxy, dim);
          end
        end
        % compute the principal stresses
        sigmaxp = cell(size(thetap));
        sigmayp = sigmaxp;
        tauxyp = sigmaxp;
        for k = 1:numel(thetap)
          Args = {index(sigmax, k) index(sigmay, k) ...
                  index(tauxy, k) thetap{k}};
          [sigmaxp{k} sigmayp{k} tauxyp{k}] = beam.mohr(Args{:});
        end
      end
    end
    % ==
    function [sigmaxs sigmays tauxys thetas] = max_shear(sigmax, sigmay, tauxy)
      % -------------------------------------
      % - computes the maximum shear stresses
      %   from the Mohr's Circle equations
      % -------------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        sigmax {mustBeA(sigmax, ["numeric" "sym"])};
        sigmay {mustBeA(sigmay, ["numeric" "sym"])};
        tauxy {mustBeA(tauxy, ["numeric" "sym"])};
      end
      % check the argument dimensions
      Args = {sigmax sigmay tauxy};
      if ~compatible_dims(Args{:})
        error('input arguments must have compatible dimensions');
      end
      symbolics = cellfun(@issym, Args);
      deg = symunit('deg');
      unknown = {'Unknown' 'false'};
      uniform = {'UniformOutput' false};
      IAC = {'IgnoreAnalyticConstraints' true};
      %% compute the maximum shear angles
      % first solution
      sigmadiff = (sigmax-sigmay)/2;
      thetas = atand(-sigmadiff./tauxy)/2;
      if issymscalar(sigmadiff) && ~issymscalar(thetas)
        sigmadiff = repmat(sigmadiff, size(thetas));
      end
      if issymscalar(tauxy) && ~issymscalar(thetas)
        tauxy = repmat(tauxy, size(thetas));
      end
      sigmadiff_is_negative = isAlways(sigmadiff < 0, unknown{:});
      sigmadiff_is_non_negative = isAlways(sigmadiff >= 0, unknown{:});
      tauxy_is_zero = isAlways(tauxy == 0, unknown{:});
      thetas(sigmadiff_is_negative & tauxy_is_zero) = 45;
      thetas(sigmadiff_is_non_negative & tauxy_is_zero) = -45;
      % second solution
      if issymfun(thetas)
        thetasf = formula(thetas);
      else
        thetasf = thetas;
      end
      if numel(thetasf) <= 1
        thetas = [thetas thetas+90];
      else
        thetas1 = array2cell(thetas);
        thetas2 = array2cell(thetas+90);
        thetas = cellfun(@horzcat, thetas1, thetas2, uniform{:});
      end
      if any(symbolics)
        if ~iscell(thetas)
          thetas = simplify(thetas*deg, IAC{:});
        else
          for k = 1:2
            switch k
              case 1
                func = @(arg) mtimes(arg, deg);
              case 2
                func = @(arg) simplify(arg, IAC{:});
            end
          end
          thetas = cellfun(func, thetas, uniform{:});
        end
      end
      %% compute the maximum shear stresses
      if ~iscell(thetas)
        Args = [Args {thetas}];
        [sigmaxs sigmays tauxys] = beam.mohr(Args{:});
      else
        % fix the scalar stress values
        Args(symfuns) = cellfun(@formula, Args(symfuns), uniform{:});
        scalars = cellfun(@isscalar, Args);
        sizes = cellfun(@size, Args, 'UniformOutput', false);
        dim = sizes(~scalars);
        if ~isempty(dim)
          dim = dim{1};
          if isnumscalar(sigmax) || issymscalar(sigmax)
            sigmax = repmat(sigmax, dim);
          end
          if isnumscalar(sigmay) || issymscalar(sigmay)
            sigmay = repmat(sigmay, dim);
          end
          if isnumscalar(tauxy) || issymscalar(tauxy)
            tauxy = repmat(tauxy, dim);
          end
        end
        % compute the maximum stresses
        sigmaxs = cell(size(thetas));
        sigmays = sigmaxs;
        tauxys = sigmaxs;
        for k = 1:numel(thetas)
          Args = {index(sigmax, k) index(sigmay, k) ...
                  index(tauxy, k) thetas{k}};
          [sigmaxs{k} sigmays{k} tauxys{k}] = beam.mohr(Args{:});
        end
      end
    end
    % ==
    function mohr_plot(varargin)
      % -------------------------
      % - plots the Mohr's Circle
      % -------------------------
      
      %% parse the input arguments
      % compute sigmax, sigmay, and tauxy
      narginchk(3,inf);
      [sigmax sigmay tauxy] = deal(varargin{1:3});
      % compute the plotting unit
      if (nargin >= 4) && iscell(varargin{4})
        unit = varargin{4};
        options = varargin(5:end);
      else
        unit = [];
        options = varargin(4:end);
      end
      %% check the input arguments
      % check sigmax, sigmay, and tauxy
      symnumsscalars = cellfun(@issymnumscalar, varargin(1:3));
      if ~all(symnumsscalars)
        str = stack('''sigmax'', ''sigmay'', and ''tauxy''', ...
                    'must be symbolic scalars with only numbers');
        error(str);
      end
      % check the plotting unit
      if ~isTextScalar(unit, 'CheckEmptyText', true)
        str = stack('''unit'' must be', ...
                    'a cell scalar of non-empty strings');
        error(str);
      end
      %% plot the Mohr's Circle
      figure;
      theta = sym('theta');
      [sigmaxm, ~, tauxym] = beam.mohr(sigmax, sigmay, tauxy, theta);
      sigmaxm = removeUnits(sigmaxm);
      tauxym = removeUnits(tauxym);
      fplot(sigmaxm, tauxym, [0 180], options{:});
      title('Mohr''s Circle');
      if ~isempty(unit)
        xlabel(['sigma (' unit{1} ')']);
        ylabel(['tau (' unit{1} ')']);
      else
        xlabel('sigma');
        ylabel('tau');
      end
      grid on;
    end
    % ==
    function shear_moment(varargin)
      % --------------------
      % - plots the shear
      %   and moment diagram
      % --------------------
      
      %% parse the input arguments
      % compute m and v
      narginchk(3,inf);
      [m v] = deal(varargin{1:2});
      % compute the plotting variable
      if isScalar(varargin{3})
        x = varargin{3};
        options = varargin(4:end);
      else
        if isallsymnum(m)
          x = randsym(vars2Exclude, symvar(v));
        elseif issym(m)
          x = symvar(m, 1);
        end
        options = varargin(3:end);
      end
      % comute the plotting range
      if ~isempty(options)
        range = options{1};
        options = options(2:end);
      else
        range = [];
      end
      % compute the plotting units
      if ~isempty(options) && (iscell(options{1}) || isstring(options{1}))
        units = options{1};
        options = options(2:end);
      else
        units = [];
      end
      %% check the input arguments
      % check m and v
      if ~issymscalar(m) || ~issymscalar(v)
         error('''m'' and ''v'' must be symbolic scalars');
      end
      % check the plotting variable
      if ~issymvarscalar(x)
        error('''x'' must be a symbolic variable scalar');
      end
      % check the plotting range
      if ~isnumvector(range, 'Len', 2) && ~issymnumvector(range, 'Len', 2)
        str = stack('''range'' must be:', ...
                    '----------------', ...
                    '1.) a numeric vector of length 2', ...
                    '2.) a symbolic vector of length 2 with only numbers');
        error(str);
      end
      % check the plotting units
      if ~isTextVector(units, ["string" "cell"], ...
                       'ArrayLen', 2, 'CheckEmptyText', true) && ...
         ~isempty(units)
        str = stack('''units'' must be', ...
                    'a cell/string vector of length 2', ...
                    'containing non-empty strings');
        error(str);
      end
      %% plot the shear and moment diagram
      figure;
      func = {v m};
      titles = {'shear diagram' 'moment diagram'};
      for k = 1:length(func)
        subplot(2,1,k);
        symplot(func{k}, x, range, options{:});
        title(titles{k});
        if ~isempty(units)
          xlabel(['distance (' units{2} ')']);
          ylabel(['shear (' units{1} ')']);
        else
          xlabel('distance');
          ylabel('shear');
        end
        grid on;
      end
    end
    % ==
    function [xr yr] = xyrot(x, y, theta)
      % ------------------------------------------
      % - computes the rotated x and y coordinates
      %   of the x and y coordinates about
      %   the angle theta
      % ------------------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        x {mustBeA(x, ["numeric" "sym"])};
        y {mustBeA(y, ["numeric" "sym"])};
        theta {mustBeA(theta, ["numeric" "sym"])};
      end
      % check the argument dimensions
      Args = {x y theta};
      if ~compatible_dims(Args{:})
        error('input arguments must have compatible dimensions');
      end
      symbolics = cellfun(@issym, Args);
      %% compute the rotated coordinates
      if ~any(hasUnits(theta), 'all')
        xr = x.*cosd(theta)+y.*sind(theta);
        yr = y.*cosd(theta)-x.*sind(theta);
      else
        xr = x.*cos(theta)+y.*sin(theta);
        yr = y.*cos(theta)-x.*sin(theta);
      end
      if any(symbolics)
        xr = simplify(xr, 'IgnoreAnalyticConstraints', true);
        yr = simplify(yr, 'IgnoreAnalyticConstraints', true);
      end
    end
    % ==
    function [Ixr Iyr Ixyr] = Irot(Ix, Iy, Ixy, theta)
      % ------------------------------------
      % - computes the moments and products
      %   of inertia about the x and y axes
      %   rotated at an angle theta
      % ------------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        Ix {mustBeA(Ix, ["numeric" "sym"])};
        Iy {mustBeA(Iy, ["numeric" "sym"])};
        Ixy {mustBeA(Ixy, ["numeric" "sym"])};
        theta {mustBeA(theta, ["numeric" "sym"])};
      end
      % check the argument dimensions
      Args = {Ix Iy Ixy theta};
      if ~compatible_dims(Args{:})
        error('input arguments must have compatible dimensions');
      end
      symbolics = cellfun(@issym, Args);
      %% compute the rotated moments and products of inertias
      Iavg = (Ix+Iy)/2;
      Idiff = (Ix-Iy)/2;
      if ~any(hasUnits(theta), 'all')
        Ixr = Iavg+Idiff.*cosd(2*theta)-Ixy.*sind(2*theta);
        Iyr = Iavg-Idiff.*cosd(2*theta)+Ixy.*sind(2*theta);
        Ixyr = Idiff.*sind(2*theta)+Ixy.*cosd(2*theta);
      else
        Ixr = Iavg+Idiff.*cos(2*theta)-Ixy.*sin(2*theta);
        Iyr = Iavg-Idiff.*cos(2*theta)+Ixy.*sin(2*theta);
        Ixyr = Idiff.*sin(2*theta)+Ixy.*cos(2*theta);
      end
      % convert to symbolic if necessary
      if any(symbolics)
        Ixr = simplify(Ixr, 'IgnoreAnalyticConstraints', true);
        Iyr = simplify(Iyr, 'IgnoreAnalyticConstraints', true);
        Ixyr = simplify(Ixyr, 'IgnoreAnalyticConstraints', true);
      end
    end
    % ==
    function [Ixp Iyp Ixyp thetap] = Ip(Ix, Iy, Ixy)
      % ---------------------------------
      % - computes the principal
      %   moments and products of inertia
      %   about the x and y axes
      % ---------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        Ix {mustBeA(Ix, ["numeric" "sym"])};
        Iy {mustBeA(Iy, ["numeric" "sym"])};
        Ixy {mustBeA(Ixy, ["numeric" "sym"])};
      end
      % check the argument dimensions
      Args = {Ix Iy Ixy};
      if ~compatible_dims(Args{:})
        error('input arguments must have compatible dimensions');
      end
      symbolics = cellfun(@issym, Args);
      deg = symunit('deg');
      unknown = {'Unknown' 'false'};
      uniform = {'UniformOutput' false};
      IAC = {'IgnoreAnalyticConstraints' true};
      %% compute the principal angles
      % first solution
      Idiff = (Ix-Iy)/2;
      thetap = atand(-Ixy./Idiff)/2;
      if issymscalar(Ixy) && ~issymscalar(thetap)
        Ixy = repmat(Ixy, size(thetap));
      end
      if issymscalar(Idiff) && ~issymscalar(thetap)
        Idiff = repmat(Idiff, size(thetap));
      end
      Ixy_is_negative = isAlways(Ixy < 0, unknown{:});
      Ixy_is_non_negative = isAlways(Ixy >= 0, unknown{:});
      Idiff_is_zero = isAlways(Idiff == 0, unknown{:});
      thetap(Ixy_is_negative & Idiff_is_zero) = -45;
      thetap(Ixy_is_non_negative & Idiff_is_zero) = 45;
      % second solution
      if issymfun(thetap)
        thetapf = formula(thetap);
      else
        thetapf = thetap;
      end
      if numel(thetapf) <= 1
        thetap = [thetap thetap+90];
      else
        thetap1 = array2cell(thetap);
        thetap2 = array2cell(thetap+90);
        thetap = cellfun(@horzcat, thetap1, thetap2, uniform{:});
      end
      if any(symbolics)
        if ~iscell(thetap)
          thetap = simplify(thetap*deg, IAC{:});
        else
          for k = 1:2
            switch k
              case 1
                func = @(arg) mtimes(arg, deg);
              case 2
                func = @(arg) simplify(arg, IAC{:});
            end
          end
          thetap = cellfun(func, thetap, uniform{:});
        end
      end
      %% compute the principal moments and products of inertias
      if ~iscell(thetap)
        Args = [Args {thetap}];
        [Ixp Iyp Ixyp] = beam.Irot(Args{:});
      else
        % fix the scalar inertia values
        Args(symfuns) = cellfun(@formula, Args(symfuns), uniform{:});
        scalars = cellfun(@isscalar, Args);
        sizes = cellfun(@size, Args, 'UniformOutput', false);
        dim = sizes(~scalars);
        if ~isempty(dim)
          dim = dim{1};
          if isnumscalar(Ix) || issymscalar(Ix)
            Ix = repmat(Ix, dim);
          end
          if isnumscalar(Iy) || issymscalar(Iy)
            Iy = repmat(Iy, dim);
          end
          if isnumscalar(Ixy) || issymscalar(Ixy)
            Ixy = repmat(Ixy, dim);
          end
        end
        % compute the principal moments and products of inertias
        Ixp = cell(size(thetap));
        Iyp = Ixp;
        Ixyp = Ixp;
        for k = 1:numel(thetap)
          Args = {index(Ix, k) index(Iy, k) ...
                  index(Ixy, k) thetap{k}};
          [Ixp{k} Iyp{k} Ixyp{k}] = beam.Irot(Args{:});
        end
      end
    end
    % ==
    function tbl = appendixB(units)
      % --------------------------
      % - returns the table
      %   from Appendix B of the
      %   Solid Mechanics textbook
      % --------------------------
      
      %% check the input arguments
      arguments
        units ...
        {mustBeTextScalar, mustBeMemberi(units, ["fps" "si"])} = "fps";
      end      
      %% compute the Appendix B table
      persistent Struct;
      if isempty(Struct)
        % compute the table struct
        filename = 'Wide-Flange Sections or W Shapes.xlsx';
        rvn = {'ReadVariableNames' false};
        rrn = {'ReadRowNames' true};
        varnames = {'Area'; ...
                    'Depth'; ...
                    'Web_Thickness'; ...
                    'Flange_Width'; ...
                    'Flange_Thickness'; ...
                    'Ix'; ...
                    'Sx'; ...
                    'rx'; ...
                    'Iy'; ...
                    'Sy'; ...
                    'ry'};
        for field = ["fps" "si"]
          % read the table from the excel file
          Sheet = upper(field);
          Args = [{filename 'Range' 'A4:L58' 'Sheet' Sheet} rvn rrn];
          if field == "fps"
            varunits = {'in^2';
                        'in';
                        'in';
                        'in';
                        'in';
                        'in^4';
                        'in^3';
                        'in';
                        'in^4';
                        'in^3';
                        'in'};
          else
            varunits = {'mm^2';
                        'mm';
                        'mm';
                        'mm';
                        'mm';
                        '10^6 x mm^4';
                        '10^3 x mm^3';
                        'mm';
                        '10^6 x mm^4';
                        '10^3 x mm^3';
                        'mm'};
          end
          Struct.(field) = readtable(Args{:});
          Args = {Struct.(field) {'Model' 'Weight'} {'table' 'table'}};
          Struct.(field) = addprop(Args{:});
          Struct.(field).Properties.VariableNames = varnames;
          Struct.(field).Properties.VariableUnits = varunits;
          rownames = Struct.(field).Properties.RowNames;
          uniform = {'UniformOutput' false};
          % compute the model of the beams
          x = repmat({' x'}, length(rownames), 1);
          Args = [{@extractBefore rownames x} uniform];
          Model = categorical(cellfun(Args{:}));
          Struct.(field).Properties.CustomProperties.Model = Model;
          % compute the weight of the beams
          x = repmat({'x '}, length(rownames), 1);
          Args = [{@extractAfter rownames x} uniform];
          if field == "fps"
            Units = symunit('lbf')/symunit('ft');
          else
            Units = symunit('kg')/symunit('m');
          end
          Weight = cellfun(Args{:})*Units;
          Struct.(field).Properties.CustomProperties.Weight = Weight;
        end
      end
      %% return the Appendix B table
      if nargin == 0
        tbl = Struct;
      else
        tbl = Struct.(lower(units));
      end
    end
    % ==
  end
  % ==
end
% =
function ends = default_ends(class)
  % ---------------------------------
  % - helper function for determining
  %   the default ends value for
  %   adding loads to the beam
  % ---------------------------------
  if class == "distributed"
    ends = [true true];
  else
    ends = [true false];
  end
end
% =
