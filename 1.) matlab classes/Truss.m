classdef Truss
  % ==
  % -----------------
  % - the truss class
  % -----------------
  % ==
  properties % truss properties
    load;
    joint;
    member;
  end
  % ==
  properties (Constant) % table variable and category names
    load_varnames = {'class' 'magnitude' 'distance'}.';
    joint_varnames = {'distance'};
    member_varnames = {'start_distance' 'end_distance' 'E' 'A'}.';
    class_categories = {'reaction' 'concentrated'}.';
  end
  % ==
  methods % truss constructor
    % ==
    function t = Truss
      % -----------------------
      % - the truss constructor
      % -----------------------
      
      %% construct the load table
      persistent tbl1;
      if ~istable(tbl1)
        Args = {"concentrated" Truss.class_categories 'Protected' true};
        tbl1.class = categorical(Args{:});
        tbl1.magnitude = "";
        tbl1.distance = "";
        tbl1 = struct2table(tbl1);
        tbl1(:,:) = [];
      end
      t.load = tbl1;
      %% construct the joint table
      persistent tbl2;
      if ~istable(tbl2)
        tbl2.distance = "";
        tbl2 = struct2table(tbl2);
        tbl2(:,:) = [];
      end
      t.joint = tbl2;
      %% construct the member table
      persistent tbl3;
      if ~istable(tbl3)
        tbl3.start_distance = "";
        tbl3.end_distance = "";
        tbl3.E = "";
        tbl3.A = "";
        tbl3 = struct2table(tbl3);
        tbl3(:,:) = [];
      end
      t.member = tbl3;
    end
    % ==
    function t = set.load(t, rhs)
      % ---------------------
      % - sets the load table
      % ---------------------
      
      %% check for wrong variable names
      varnames = Truss.load_varnames.';
      if ~istable(rhs) || ~isperm(rhs.Properties.VariableNames, varnames)
        str = stack('''load'' property must be a table', ...
                    'with the following variable names:', ...
                    '----------------------------------', ...
                    '1.) ''class''', ...
                    '2.) ''magnitude''', ...
                    '3.) ''distance''');
        error(str);
      end
      %% check for wrong variable types
      if ~iscatcol(rhs.class)
        error('''class'' variable must be a categorical column vector');
      end
      if (~iscellcol(rhs.magnitude) && ~isStringCol(rhs.magnitude)) || ...
         (~iscellcol(rhs.distance) && ~isStringCol(rhs.distance))
        str = stack('''magnitude'' and ''distance'' variables', ...
                    'must be cell or string column vectors');
        error(str);
      end
      %% check for wrong categories
      if ~isprotected(rhs.class) || isordinal(rhs.class)
        str = stack('''class'' variable', ...
                    'must be a protected and unordinal', ...
                    'categorical array');
        error(str);
      end
      if ~isperm(Truss.class_categories, categories(rhs.class))
        str = stack('''class'' variable must have', ...
                    'the following categories:', ...
                    '-------------------------', ...
                    '1.) ''reaction''', ...
                    '2.) ''concentrated''');
        error(str);
      end
      %% check for <undefined> categories
      if any(isundefined(rhs.class))
        error('''class'' variable must not have ''<undefined>'' values');
      end
      t.load = rhs;
    end
    % ==
    function t = set.joint(t, rhs)
      % ----------------------
      % - sets the joint table
      % ----------------------
      
      %% check for wrong variable names
      varnames = Truss.joint_varnames.';
      if ~istable(rhs) || ~isperm(rhs.Properties.VariableNames, varnames)
        str = stack('''joint'' property must be a table', ...
                    'with the following variable name:', ...
                    '---------------------------------', ...
                    '1.) ''distance''');
        error(str);
      end
      %% check for wrong variable types
      if ~iscellcol(rhs.distance) && ~isStringCol(rhs.distance)
        str = stack('''joint'' variable must be', ...
                    'a cell or string column vector');
        error(str);
      end
      t.joint = rhs;
    end
    % ==
    function t = set.member(t, rhs)
      % -----------------------
      % - sets the member table
      % -----------------------
      
      %% check for wrong variable names
      varnames = Truss.member_varnames.';
      if ~istable(rhs) || ~isperm(rhs.Properties.VariableNames, varnames)
        str = stack('''member'' property must be a table', ...
                    'with the following variable names:', ...
                    '----------------------------------', ...
                    '1.) ''start_distance''', ...
                    '2.) ''end_distance''', ...
                    '3.) ''E''', ...
                    '4.) ''A''');
        error(str);
      end
      %% check for wrong variable types
      if (~iscellcol(rhs.start_distance) && ...
          ~isStringCol(rhs.start_distance)) || ...
         (~iscellcol(rhs.end_distance) && ...
          ~isStringCol(rhs.end_distance)) || ...
         (~iscellcol(rhs.E) && ~isStringCol(rhs.E)) || ...
         (~iscellcol(rhs.A) && ~isStringCol(rhs.A))
        str = stack('''member'' variables must be', ...
                    'cell or string column vectors');
        error(str);
      end
      t.member = rhs;
    end
    % ==
  end
  % ==
  methods % truss calculation member methods
    % ==
    function t = add(t, what, varargin)
      % -----------------------------------
      % - add loads, joints, and/or members
      %   to the truss
      % -----------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        t;
        what ...
        {mustBeTextScalar, ...
         mustBeMemberi(what, ["reaction" "concentrated" ...
                              "joint" "member"])};
      end
      arguments (Repeating)
        varargin;
      end
      % check the adding argument
      what = lower(what);
      %% add the loads, joints, and or/members to the truss
      switch what
        case {"reaction" "concentrated"}
          % check the table arguments
          if length(varargin) ~= 3
            str = stack('there must be 3 table arguments passed', ...
                        'when adding loads to the truss');
            error(str);
          end
          % add the load to the truss
          if isempty(varargin{1})
            rowname = ['load' num2str(height(t.load)+1)];
          else
            rowname = varargin{1};
          end
          class = what;
          magnitude = array2symstr(varargin{2});
          distance = array2symstr(varargin{3});
          t.load(end+1,:) = {class magnitude distance};
          empty_rownames = isempty(t.load.Properties.RowNames);
          one_load = height(t.load) == 1;
          if empty_rownames && one_load
            t.load.Properties.RowNames(end+1) = {rowname};
          elseif ~empty_rownames
            t.load.Properties.RowNames{end} = rowname;
          end
        case "joint"
          % check the table arguments
          if length(varargin) ~= 2
            str = stack('there must 2 table arguments passed', ...
                        'when adding joints to the truss');
            error(str);
          end
          % add the joint to the truss
          if isempty(varargin{1})
            rowname = num2str(height(t.joint)+1);
          else
            rowname = varargin{1};
          end
          distance = array2symstr(varargin{2});
          t.joint(end+1,:) = {distance};
          empty_rownames = isempty(t.joint.Properties.RowNames);
          one_joint = height(t.joint) == 1;
          if empty_rownames && one_joint
            t.joint.Properties.RowNames(end+1) = {rowname};
          elseif ~empty_rownames
            t.joint.Properties.RowNames{end} = rowname;
          end
        case "member"
          % check the table arguments
          if (length(varargin) < 3) || (length(varargin) > 5)
            str = stack('there must be at least 3,', ...
                        'but at most 5 table arguments passed', ...
                        'when adding members to the truss');
            error(str);
          end
          % add the member to the truss
          if isempty(varargin{1})
            rowname = ['member' num2str(height(t.member)+1)];
          else
            rowname = varargin{1};
          end
          start_distance = array2symstr(varargin{2});
          end_distance = array2symstr(varargin{3});
          if length(varargin) == 3
            E = 'E';
            A = 'A';
          elseif length(varargin) == 4
            E = array2symstr(varargin{4});
            A = 'A';
          else
            if isempty(varargin{4})
              E = 'E';
            else
              E = array2symstr(varargin{4});
            end
            A = array2symstr(varargin{5});
          end
          t.member(end+1,:) = {start_distance end_distance E A};
          empty_rownames = isempty(t.member.Properties.RowNames);
          one_member = height(t.member) == 1;
          if empty_rownames && one_member
            t.member.Properties.RowNames(end+1) = {rowname};
          elseif ~empty_rownames
            t.member.Properties.RowNames{end} = rowname;
          end
      end
    end
    % ==
    function t = convert2cellsym(t, options)
      % ----------------------------------
      % - converts the variables of the
      %   load, joint, and member tables
      %   to cell arrays of symbolc arrays
      % ----------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        t;
        options.Mode ...
        {mustBeTextScalar, ...
         mustBeMemberi(options.Mode, ["ignore" "nan"])} = "ignore";
        options.Prop ...
        {mustBeText, ...
         mustBeMemberi(options.Prop, ["load" "joint" "member"])};
      end
      % check the conversion mode
      Mode = lower(options.Mode);
      % check the truss property      
      if isfield(options, 'Prop')
        Prop = unique(string(lower(options.Prop)), 'stable');
      else
        Prop = ["load" "joint" "member"];
      end
      %% case for non-scalar trusses
      if isempty(t)
        return;
      elseif ~isscalar(t)
        for k = 1:numel(t)
          t(k) = t(k).convert2cellsym('Mode', Mode, 'Prop', Prop);
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
      for k = Prop
        vars = string(t.(k).Properties.VariableNames);
        if k == "load"
          vars = vars(2:end);
        end
        for p = vars
          t.(k).(p) = cellfun(@array2sym, t.(k).(p), Args{:});
        end
      end
    end
    % ==
    function t = convert2cellsymstr(t, options)
      % -------------------------------------------
      % - converts the variables of the
      %   load, joint, and member tables to
      %   cell arrays of symbolic character vectors
      % -------------------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        t;
        options.Mode ...
        {mustBeTextScalar, ...
         mustBeMemberi(options.Mode, ["ignore" "nan"])} = "ignore";
        options.Prop ...
        {mustBeText, ...
         mustBeMemberi(options.Prop, ["load" "joint" "member"])};        
      end
      % check the conversion mode
      Mode = lower(options.Mode);
      % check the truss property      
      if isfield(options, 'Prop')
        Prop = unique(string(lower(options.Prop)), 'stable');
      else
        Prop = ["load" "joint" "member"];
      end
      %% case for non-scalar trusses
      if isempty(t)
        return;
      elseif ~isscalar(t)
        for k = 1:numel(t)
          t(k) = t(k).convert2cellstr('Mode', Mode, 'Prop', Prop);
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
      for k = Prop
        vars = string(t.(k).Properties.VariableNames);
        if k == "load"
          vars = vars(2:end);
        end
        for p = vars
          t.(k).(p) = cellfun(@array2symstr, t.(k).(p), Args{:});
          symbolics = cellfun(@issym, t.(k).(p));
          t.(k).(p)(symbolics) = {'NaN'};
        end
      end
    end
    % ==
    function t = convert2string(t, options)
      % --------------------------------
      % - converts the variables of the
      %   load, joint, and member tables
      %   to string arrays
      % --------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        t;
        options.Mode ...
        {mustBeTextScalar, ...
         mustBeMemberi(options.Mode, ["ignore" "nan"])} = "ignore";
        options.Prop ...
        {mustBeText, ...
         mustBeMemberi(options.Prop, ["load" "joint" "member"])};
      end
      % check the conversion mode
      Mode = lower(options.Mode);
      % check the truss property      
      if isfield(options, 'Prop')
        Prop = unique(string(lower(options.Prop)), 'stable');
      else
        Prop = ["load" "joint" "member"];
      end
      %% case for non-scalar trusses
      if isempty(t)
        return;
      elseif ~isscalar(t)
        for k = 1:numel(t)
          t(k) = t(k).convert2string('Mode', Mode, 'Prop', Prop);
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
      for k = Prop
        vars = string(t.(k).Properties.VariableNames);
        if k == "load"
          vars = vars(2:end);
        end
        for p = vars
          t.(k).(p) = cellfun(@array2symstr, t.(k).(p), Args{:});
          chars = cellfun(@ischar, t.(k).(p));
          symbolics = cellfun(@issym, t.(k).(p));
          t.(k).(p)(~chars & ~symbolics) = {missing};
          t.(k).(p) = string(t.(k).(p));
          t.(k).(p)(symbolics) = "NaN";
        end
      end
    end
    % ==
    function t = setE(t, Enew)
      % ------------------------------------
      % - sets the E property of
      %   all members to the value of 'Enew'
      % ------------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        t;
        Enew sym;
      end
      % check the argument dimensions
      if ~isScalar(Enew) && ~isVector(Enew, 'Len', length(t.member.E))
        str = stack('''Enew'' must be:', ...
                    '---------------', ...
                    '1.) a scalar', ...
                    '2.) a vector with a', ...
                    '    length equal to the', ...
                    '    number of truss members');
        error(str);
      end
      %% case for non-scalar trusses
      if isempty(t)
        return;
      elseif ~isscalar(t)
        for k = 1:numel(t)
          t(k) = t(k).setE(Enew);
        end
        return;
      end
      %% set the E property
      if iscellsym(t.member.E)
        t.member.E(:) = array2cellsym(Enew);
      elseif iscell(t.member.E)
        t.member.E(:) = array2cellsymstr(Enew);
      else
        t.member.E(:) = array2string(Enew);
      end
    end
    % ==
    function t = setA(t, Anew)
      % ------------------------------------
      % - sets the A property of
      %   all members to the value of 'Anew'
      % ------------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        t;
        Anew sym;
      end
      % check the argument dimensions
      if ~isScalar(Anew) && ~isVector(Anew, 'Len', length(t.member.E))
        str = stack('''Anew'' must be:', ...
                    '---------------', ...
                    '1.) a scalar', ...
                    '2.) a vector with a', ...
                    '    length equal to the', ...
                    '    number of truss members');
        error(str);
      end
      %% case for non-scalar trusses
      if isempty(t)
        return;
      elseif ~isscalar(t)
        for k = 1:numel(t)
          t(k) = t(k).setA(Anew);
        end
        return;
      end
      %% set the E property
      if iscellsym(t.member.A)
        t.member.A(:) = array2cellsym(Anew);
      elseif iscell(t.member.A)
        t.member.A(:) = array2cellsymstr(Anew);
      else
        t.member.A(:) = array2string(Anew);
      end
    end
    % ==
    function t = shift_joints(t, shift)
      % -------------------------------
      % - shift the joints on the truss
      % -------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        t;
        shift sym;
      end
      % check the argument dimensions
      shift = formula(shift);
      if ~isvector(shift)
        error('''shift'' must be a vector');
      end
      %% case for non-scalar trusses
      if isempty(t)
        return;
      elseif ~isscalar(t)
        for k = 1:numel(t)
          t(k) = t(k).shift_joints(shift);
        end
        return;
      end
      %% shift the loads, joints, and members on the truss
      for k = ["load" "joint" "member"]
        for p = 1:height(t.(k))
          try
            if ismember(k, ["load" "joint"])
              % shift the loads and joints
              new_distance = array2sym(t.(k).distance(p))+shift;
              if ischar(t.(k).distance{p})
                new_distance = char(new_distance);
              end
              t.(k).distance{p} = new_distance;
            else
              % shift the starting side of the members
              new_distance = array2sym(t.(k).start_distance(p))+shift;
              if ischar(t.(k).start_distance{p})
                new_distance = char(new_distance);
              end
              t.(k).start_distance{p} = new_distance;
              % shift the ending side of the members
              new_distance = array2sym(t.(k).end_distance(p))+shift;
              if ischar(t.(k).end_distance{p})
                new_distance = char(new_distance);
              end
              t.(k).end_distance{p} = new_distance;
            end
          catch
          end
        end
      end
    end
    % ==
    function [us ua ms ma ls la] = solve(t, options)
      % ------------------------------------------------
      % - solves the truss for the following information
      %   by using the stiffness matrix method:
      % - 1.) the joint displacements
      %   2.) the forces and moments of each member
      %   3.) the forces and moments of each load
      % ------------------------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        t;
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
        options.Reference ...
        {mustBeA(options.Reference, ["numeric" "sym" ...
                                     "cell" "char" ...
                                     "string"])} = "default";
      end
      % check the simplification mode
      Mode = string(lower(options.Mode));
      if ~isStringArray(Mode, 'ArrayDim', size(t)) && ...
         ~isStringScalar(Mode) && ~isempty(t)
        str = stack('the simplification mode must be', ...
                    'a text array with the same size as the beam');
        error(str);
      end
      % check the reference points
      Reference = options.Reference;
      if isnumvector(Reference) || issymvector(Reference) || ...
         isequal(Reference, "default")
        Reference = {Reference};
      end
      uniform = {'UniformOutput' false};
      numvectors = cellfun(@isnumvector, Reference);
      symvectors = cellfun(@issymvector, Reference);
      symfuns = cellfun(@issymfun, Reference);
      func = @(arg) isequal(arg, "default");
      using_default = cellfun(func, Reference);
      Reference(symfuns) = cellfun(@formula, ...
                                   Reference(symfuns), uniform{:});
      if ~iscellarray(Reference, 'CellDim', size(t)) && ...
         ~iscellscalar(Reference) && ~isempty(t)
        str = stack('the size of the cell array', ...
                    'for the reference points must', ...
                    'be the same as the size of the truss');
        error(str);
      end
      if ~all(numvectors | symvectors | using_default, 'all')
        str = stack('the contents of the cell array', ...
                    'for the reference points must', ...
                    'contain numeric or symbolic vectors', ...
                    'or the string ''default''');
        error(str);
      end
      %% case for non-scalar trusses
      if isempty(t)
        [us ms ls] = deal(struct.empty);
        [ua ma la] = deal(sym.empty);
        return;
      elseif ~isscalar(t)
        try
          [~, Mode Reference] = scalar_expand(t, Mode, Reference);
          [us ua ms ma ls la] = deal(cell(size(t)));
          for k = 1:numel(t)
            [us{k} ua{k} ms{k} ma{k} ls{k} la{k}] = ...
            t(k).solve('Mode', Mode{k}, 'Reference', Reference{k});
          end
          return;
        catch Error
          str = 'for the truss with linear index %d:\n%s';
          new_Error = MException('', str, k, Error.message);
          if ~isempty(Error.cause)
            throw(addCause(new_Error, Error.cause{1}));
          else
            throw(new_Error);
          end
        end
      else
        Reference = Reference{1};
      end
      %% convert the table variables to cell arrays of symbolic arrays
      t = t.convert2cellsym('Mode', 'nan');
      t.load.magnitude = cellfun(@formula, t.load.magnitude, uniform{:});
      t.load.distance = cellfun(@formula, t.load.distance, uniform{:});
      t.joint.distance = cellfun(@formula, t.joint.distance, uniform{:});
      t.member.start_distance = cellfun(@formula, ...
                                        t.member.start_distance, ...
                                        uniform{:});
      t.member.end_distance = cellfun(@formula, ...
                                      t.member.end_distance, ...
                                      uniform{:});
      t.member.E = cellfun(@formula, t.member.E, uniform{:});
      t.member.A = cellfun(@formula, t.member.A, uniform{:});
      %% compute these useful values
      % frequrently used arrays
      IAC = {'IgnoreAnalyticConstraints' true};
      Full = {'FactorMode' 'full'};
      Complex = {'FactorMode' 'complex'};
      Real = {'FactorMode' 'real'};
      Expand = {'Expand' true};
      iA_str = 'unable to solve the truss';
      % load table variables
      t.load = sortrows(t.load, 'class');
      class = t.load.class;
      load_fieldnames = compute_fieldnames('load', t);
      load_magnitude = t.load.magnitude;
      load_distance = t.load.distance;
      num_loads = height(t.load);
      % joint table variable
      joint_fieldames = compute_fieldnames('joint', t);
      joint_distance = t.joint.distance;
      num_joints = height(t.joint);
      % member table variables
      member_fieldnames = compute_fieldnames('member', t);
      start_distance = t.member.start_distance;
      end_distance = t.member.end_distance;
      E = t.member.E;
      A = t.member.A;
      num_members = height(t.member);
      % class locations
      reaction_loc = class == "reaction";
      concentrated_loc = class == "concentrated";
      % reaction loads table
      reaction = t.load(reaction_loc,:);
      reaction_vars = symvar(sym(convert2col(reaction.magnitude)));
      num_reactions = height(reaction);
      num_reaction_vars = length(reaction_vars);
      % concentrated loads table
      concentrated = t.load(concentrated_loc,:);
      concentrated_vars = symvar(sym(convert2col(concentrated.magnitude)));
      % column vector of magnitudes, distances, and lengths
      column.m = sym(convert2col(load_magnitude));
      column.d = sym([convert2col(load_distance);
                      convert2col(joint_distance);
                      convert2col(start_distance);
                      convert2col(end_distance)]);
      column.lengths = [cellfun(@length, load_magnitude);
                        cellfun(@length, load_distance);
                        cellfun(@length, joint_distance);
                        cellfun(@length, start_distance);
                        cellfun(@length, end_distance)];
      % truss dimensions and variables to exclude
      if isempty(column.lengths)
        num_dimensions = 1;
      else
        num_dimensions = column.lengths(1);
      end
      Vars2Exclude = symvar([column.m; column.d;
                             convert2col(E); convert2col(A)]);
      % scalar cell array locations
      func = @(arg) isScalar(arg) && isallfinite(arg);
      scalar_Es = cellfun(func, E);
      scalar_As = cellfun(func, A);
      % vector cell array locations
      func = @(arg) isVector(arg, 'CheckEmpty', true) && ...
                    isallfinite(arg);
      vector_load_magnitudes = cellfun(func, load_magnitude);
      vector_load_distances = cellfun(func, load_distance);
      vector_joint_distances = cellfun(func, joint_distance);
      vector_start_distances = cellfun(func, start_distance);
      vector_end_distances = cellfun(func, end_distance);
      vector_distances = all(vector_load_distances) && ...
                         all(vector_joint_distances) && ...
                         all(vector_start_distances) && ...
                         all(vector_end_distances);
      % symbolic variable cell array locations
      func = @(arg) issymvarmultiplevector(arg, 'CountZero', true);
      symvarmultiplevectors = cellfun(func, load_magnitude);
      %% inspect the magnitudes and distances
      % check the magnitudes of the reactions
      if any(reaction_loc & ~symvarmultiplevectors)
        str = stack('the magnitudes of the reactions', ...
                    'must be numeric or symbolic vectors', ...
                    'containing numeric scalar multiples', ...
                    'of a symbolic variable scalar');
        error(str);
      end
      % check the magnitudes of the concentrated loads
      if any(concentrated_loc & ~vector_load_magnitudes)
        str = stack('the magnitudes of the concentrated loads', ...
                    'must be non-empty numeric or symbolic scalars', ...
                    'with no Inf or NaN values');
        error(str);
      end
      % check the distances
      if ~vector_distances
        str = stack('the distances must be', ...
                    'non-empty numeric or symbolic vectors', ...
                    'with no Inf or NaN values');
        error(str);
      end
      % check the lengths of the magnitudes and distances
      if ~isallequal(column.lengths) || any(column.lengths > 3)
        str = stack('the lengths of the magnitudes and distances', ...
                    'must all be the same and not exceed 3');
        error(str);
      end
      % check E and A
      if ~all(scalar_Es & scalar_As)
        str = stack('''E'' and ''A'' must be', ...
                    'numeric or symbolic scalars', ...
                    'with no Inf or NaN values');
        error(str);
      end
      % the distances must have compatible units
      if ~checkUnits(sum(column.d), 'Compatible')
        error('the distances must have compatible units');
      end
      % the distances must not contain
      % the magnitude of the reactions
      if any(ismember(symvar(column.d), reaction_vars))
        str = stack('the distances must not contain', ...
                    'the magnitudes of the reactions');
        error(str);
      end
      %% inspect the loads
      % the magnitudes of the reactions
      % must not be scalar multiples of one another
      reaction.magnitude = sym(convert2row(reaction.magnitude));
      magnitude_col = reaction.magnitude(:);
      magnitude_col(~issymvarmultiple(magnitude_col)) = [];
      if ~isequallen(magnitude_col, reaction_vars)
        str = stack('the magnitudes of the reactions', ...
                    'must not be scalar multiples of one another');
        error(str);
      end
      % the magnitudes of the concentrated loads
      % must not contain the magnitudes of the reactions
      if any(ismember(concentrated_vars, reaction_vars))
        str = stack('the magnitudes of the concentrated loads', ...
                    'must not contain the magnitudes of the reactions');
        error(str);
      end
      % there must be unique distances values for the reactions
      reaction.distance = sym(convert2row(reaction.distance));
      for k = 1:num_reactions-1
        lhs = reaction.distance(k,:);
        for p = k+1:num_reactions
          rhs = reaction.distance(p,:);
          if isAlwaysError(lhs == rhs, iA_str)
            error('at least 2 reactions have the same distance');
          end
        end
      end
      % the truss must be stable
      Args = {num_reaction_vars num_dimensions num_joints num_members};
      if ~Truss.stable(Args{:})
        error('the truss must be stable');
      end
      %% inspect the joints
      % the length of the reference point
      % must be the same as
      % the number of truss dimensions
      if using_default
        Reference = joint_distance{1};
      end
      if ~isrow(Reference) && ~isscalar(Reference)
        Reference = Reference.';
      end
      if ~islen(Reference, num_dimensions)
        str = stack('the length of the reference point', ...
                    'must be the same as', ...
                    'the number of truss dimensions');
        error(str);
      end
      % the reference point must have units
      % that are compatible with the distance units
      if ~checkUnits(sum(Reference)+sum(column.d), 'Compatible')
        str = stack('the reference point must have units', ...
                    'that are compatible with the distance units');
        error(str);
      end
      % there must be unique distance values for the joints
      joint_distance = sym(convert2row(joint_distance));
      for k = 1:num_joints-1
        for p = k+1:num_joints
          equal_distance = joint_distance(k,:) == joint_distance(p,:);
          if isAlwaysError(equal_distance, iA_str)
            fields = [t.joint.Properties.RowNames(k);
                      t.joint.Properties.RowNames(p)];
            str = stack('joints ''%s'' and ''%s''', ...
                        'have the same distance');
            error(str, fields{:});
          end
        end
      end
      % all loads must be connected to a joint
      load_magnitude = sym(convert2row(load_magnitude));
      load_distance = sym(convert2row(load_distance));
      for k = 1:num_loads
        load_at_joint = load_distance(k,:) == joint_distance;
        load_at_joint = all(isAlwaysError(load_at_joint, iA_str), 2);
        if ~any(load_at_joint)
          error('load #%d is not connected to a joint', k);
        end
      end
      %% inspect the members
      % there must be unique distance values for the members
      for k = 1:num_members-1
        for p = k+1:num_members
          equal_distance = (start_distance{k} == start_distance{p}) & ...
                           (end_distance{k} == end_distance{p});
          if isAlwaysError(equal_distance, iA_str)
            str = stack('members ''%s'' and ''%s''', ...
                        'have the same distances');
            error(str, member_fieldnames{[k p]});
          end
        end
      end
      % both sides of all members
      % must have different distances and
      % must be connected to a joint
      start_distance = sym(convert2row(start_distance));
      end_distance = sym(convert2row(end_distance));
      for k = 1:num_members
        start_equals_end = start_distance(k,:) == end_distance(k,:);
        start_equals_end = isAlwaysError(start_equals_end, iA_str);
        start_equals_end = all(start_equals_end, 2);
        start_at_joint = start_distance(k,:) == joint_distance;
        start_at_joint = all(isAlwaysError(start_at_joint, iA_str), 2);
        end_at_joint = end_distance(k,:) == joint_distance;
        end_at_joint = all(isAlwaysError(end_at_joint, iA_str), 2);
        if any(start_equals_end)
          str = stack('both sides of member ''%s''', ...
                      'have the same distance');
        elseif ~any(start_at_joint) && ~any(end_at_joint)
          str = stack('both sides of member ''%s''', ...
                      'are not connected to a joint');
        elseif ~any(start_at_joint)
          str = stack('the starting side of member ''%s''', ...
                      'is not connected to a joint');
        elseif ~any(end_at_joint)
          str = stack('the ending side of member ''%s''', ...
                      'is not connected to a joint');
        else
          str = '';
        end
        if ~isempty(str)
          error(str, member_fieldnames{k});
        end
      end
      %% compute the global stiffness matrix data
      Ind = @(k) num_dimensions*(k-1)+1;
      N = 0:num_dimensions-1;
      distance = end_distance-start_distance;
      lambda = simplify(unit_vector(distance, 'Dim', 2), IAC{:});
      E = sym(E);
      A = sym(A);
      L = simplify(Norm(distance, 'Dim', 2), IAC{:});
      EAL = simplify(E.*A./L, IAC{:});
      %% compute the global stiffness matrix
      connect = zeros(num_members, 2*num_dimensions);
      [T Kl Km] = deal(cell(num_members, 1));
      Kg = sym.zeros(num_dimensions*num_joints);
      for k = 1:num_members
        % joint indices
        start_at_joint = start_distance(k,:) == joint_distance;
        start_at_joint = all(isAlwaysError(start_at_joint, iA_str), 2);
        end_at_joint = end_distance(k,:) == joint_distance;
        end_at_joint = all(isAlwaysError(end_at_joint, iA_str), 2);
        joint_ind = [find(start_at_joint, 1) find(end_at_joint, 1)];
        % connectivity matrix
        connect(k,1:num_dimensions) = Ind(joint_ind(1))+N;
        connect(k,num_dimensions+1:2*num_dimensions) = Ind(joint_ind(2))+N;
        % member stiffness matrix
        lambda_vals = lambda(k,:);
        zero_vals = zeros(size(lambda_vals));
        T{k} = [lambda_vals zero_vals; zero_vals lambda_vals];
        Kl{k} = EAL(k)*[1 -1; -1 1];
        Km{k} = T{k}.'*Kl{k}*T{k};
        % global stiffness matrix
        ind = connect(k,:);
        Kg(ind,ind) = Kg(ind,ind)+Km{k};
      end
      %% compute the global displacement and force vectors
      dim = [num_dimensions*num_joints 1];
      Ug = randsym(dim, 'Vars2Exclude', Vars2Exclude);
      Fg = sym.zeros(num_dimensions*num_joints, 1);
      var_found = issymvarmultiple(load_magnitude);
      for k = 1:num_joints
        equal_distance = load_distance == joint_distance(k,:);
        equal_distance = isAlwaysError(all(equal_distance, 2), iA_str);
        ind = Ind(k);
        for p = 1:num_dimensions
          % global displacement vector
          reaction_found = reaction_loc & equal_distance & var_found(:,p);
          if any(reaction_found)
            Ug(ind) = 0;
          end
          % global force vector
          Fg(ind) = sum(load_magnitude(equal_distance, p));
          ind = ind+1;
        end
      end
      %% solve for the unknown variables
      % compute the solution
      eqn = Kg*Ug == Fg;
      unknowns = [reaction_vars Ug(issymvar(Ug)).'];
      soln = solve(eqn, unknowns);
      Ug = subs(Ug, soln);
      % compute the joint displacement structure array
      fields = joint_fieldames;
      for k = 1:length(fields)
        if isempty(Ug)
          us.(fields{k}) = Ug;
          continue;
        end
        us.(fields{k}) = simplify(Ug(k), IAC{:});
        switch Mode
          case "factor"
            us.(fields{k}) = prodfactor(us.(fields{k}));
          case "factor full"
            us.(fields{k}) = prodfactor(us.(fields{k}), Full{:});
          case "factor complex"
            us.(fields{k}) = prodfactor(us.(fields{k}), Complex{:});
          case "factor real"
            us.(fields{k}) = prodfactor(us.(fields{k}), Real{:});
          case "simplify fraction"
            us.(fields{k}) = simplifyFraction(us.(fields{k}));
          case "simplify fraction expand"
            us.(fields{k}) = simplifyFraction(us.(fields{k}), Expand{:});
        end
      end
      % compute the force and moment structure array
      num_fields = num_members+num_loads;
      zero_vals = zeros(num_fields, 3-num_dimensions);
      Reference = repmat(Reference, num_fields, 1);
      magnitude = subs(load_magnitude, soln);
      distance = [[start_distance; load_distance]-Reference zero_vals];
      fields = [member_fieldnames; load_fieldnames];
      for k = 1:length(fields)
        if isempty(Ug)
          f.m.(fields{k}) = Ug;
          f.c.(fields{k}) = Ug;
          m.m.(fields{k}) = Ug;
          m.c.(fields{k}) = Ug;
          continue;
        end
        if k <= num_members
          % member force magnitude
          ind = connect(k,:);
          f.m.(fields{k}) = Kl{k}*T{k}*Ug(ind);
          f.m.(fields{k}) = simplify(f.m.(fields{k})(2), IAC{:});
          % member force components
          f.c.(fields{k}) = Km{k}*Ug(ind);
          f.c.(fields{k}) = [f.c.(fields{k})(Ind(2):end); zero_vals(k,:)];
          f.c.(fields{k}) = simplify(f.c.(fields{k}), IAC{:});
        else
          % load force magnitude
          f.m.(fields{k}) = Norm(magnitude(k-num_members,:));
          f.m.(fields{k}) = simplify(f.m.(fields{k}), IAC{:});
          % load force components
          f.c.(fields{k}) = [magnitude(k-num_members,:) zero_vals(k,:)].';
          f.c.(fields{k}) = simplify(f.c.(fields{k}), IAC{:});
        end
        % moment components
        m.c.(fields{k}) = cross(distance(k,:).', f.c.(fields{k}));
        m.c.(fields{k}) = simplify(m.c.(fields{k}), IAC{:});
        % moment magnitudes
        m.m.(fields{k}) = Norm(m.c.(fields{k}));
        m.m.(fields{k}) = simplify(m.m.(fields{k}), IAC{:});
        switch Mode
          case "factor"
            f.m.(fields{k}) = prodfactor(f.m.(fields{k}));
            f.c.(fields{k}) = prodfactor(f.c.(fields{k}));
            m.m.(fields{k}) = prodfactor(m.m.(fields{k}));
            m.c.(fields{k}) = prodfactor(m.c.(fields{k}));
          case "factor full"
            f.m.(fields{k}) = prodfactor(f.m.(fields{k}), Full{:});
            f.c.(fields{k}) = prodfactor(f.c.(fields{k}), Full{:});
            m.m.(fields{k}) = prodfactor(m.m.(fields{k}), Full{:});
            m.c.(fields{k}) = prodfactor(m.c.(fields{k}), Full{:});
          case "factor complex"
            f.m.(fields{k}) = prodfactor(f.m.(fields{k}), Complex{:});
            f.c.(fields{k}) = prodfactor(f.c.(fields{k}), Complex{:});
            m.m.(fields{k}) = prodfactor(m.m.(fields{k}), Complex{:});
            m.c.(fields{k}) = prodfactor(m.c.(fields{k}), Complex{:});
          case "factor real"
            f.m.(fields{k}) = prodfactor(f.m.(fields{k}), Real{:});
            f.c.(fields{k}) = prodfactor(f.c.(fields{k}), Real{:});
            m.m.(fields{k}) = prodfactor(m.m.(fields{k}), Real{:});
            m.c.(fields{k}) = prodfactor(m.c.(fields{k}), Real{:});
          case "simplify fraction"
            f.m.(fields{k}) = simplifyFraction(f.m.(fields{k}));
            f.c.(fields{k}) = simplifyFraction(f.c.(fields{k}));
            m.m.(fields{k}) = simplifyFraction(m.m.(fields{k}));
            m.c.(fields{k}) = simplifyFraction(m.c.(fields{k}));
          case "simplify fraction expand"
            f.m.(fields{k}) = simplifyFraction(f.m.(fields{k}), Expand{:});
            f.c.(fields{k}) = simplifyFraction(f.c.(fields{k}), Expand{:});
            m.m.(fields{k}) = simplifyFraction(m.m.(fields{k}), Expand{:});
            m.c.(fields{k}) = simplifyFraction(m.c.(fields{k}), Expand{:});
        end
      end
      % compute the member force and moment structure array
      ms.f.m = rmfield(f.m, setdiff(fields, member_fieldnames));
      ms.f.c = rmfield(f.c, setdiff(fields, member_fieldnames));
      ms.m.m = rmfield(m.m, setdiff(fields, member_fieldnames));
      ms.m.c = rmfield(m.c, setdiff(fields, member_fieldnames));
      % compute the reaction force and moment structure array
      ls.f.m = rmfield(f.m, setdiff(fields, load_fieldnames));
      ls.f.c = rmfield(f.c, setdiff(fields, load_fieldnames));
      ls.m.m = rmfield(m.m, setdiff(fields, load_fieldnames));
      ls.m.c = rmfield(m.c, setdiff(fields, load_fieldnames));
      % compute the symbolic arrays
      s2c = @struct2cell;
      if ~isempty(Ug)
        % joint displacement symbolic array
        ua = [sym(fieldnames(us)) sym(s2c(us))];
        % member force and moment symbolic arrays
        ma.f.m = [sym(fieldnames(ms.f.m)) sym(s2c(ms.f.m))];
        ma.f.c = [sym(fieldnames(ms.f.c)) sym(convert2row(s2c(ms.f.c)))];
        ma.m.m = [sym(fieldnames(ms.m.m)) sym(s2c(ms.m.m))];
        ma.m.c = [sym(fieldnames(ms.m.c)) sym(convert2row(s2c(ms.m.c)))];
        % load force and moment symbolic arrays
        la.f.m = [sym(fieldnames(ls.f.m)) sym(s2c(ls.f.m))];
        la.f.c = [sym(fieldnames(ls.f.c)) sym(convert2row(s2c(ls.f.c)))];
        la.m.m = [sym(fieldnames(ls.m.m)) sym(s2c(ls.m.m))];
        la.m.c = [sym(fieldnames(ls.m.c)) sym(convert2row(s2c(ls.m.c)))];
      else
        % joint displacement symbolic array
        ua = [sym(fieldnames(us)) nan(numFields(us), 1)];
        % member force and moment symbolic arrays
        ma.f.m = [sym(fieldnames(ms.f.m)) nan(numFields(ms.f.m), 1)];
        ma.f.c = [sym(fieldnames(ms.f.c)) nan(numFields(ms.f.c), 1)];
        ma.m.m = [sym(fieldnames(ms.m.m)) nan(numFields(ms.m.m), 1)];
        ma.m.c = [sym(fieldnames(ms.m.c)) nan(numFields(ms.m.c), 1)];
        % load force and moment symbolic arrays
        la.f.m = [sym(fieldnames(ls.f.m)) nan(numFields(ls.f.m), 1)];
        la.f.c = [sym(fieldnames(ls.f.c)) nan(numFields(ls.f.c), 1)];
        la.m.m = [sym(fieldnames(ls.m.m)) nan(numFields(ls.m.m), 1)];
        la.m.c = [sym(fieldnames(ls.m.c)) nan(numFields(ls.m.c), 1)];
      end
    end
    % ==
  end
  % ==
  methods (Static) % truss calculation static methods
    % ==
    function [bool diff] = stable(R, D, J, M)
      % ----------------------------------------
      % - returns true if the truss is stable
      % - the truss is stable
      %   if R >= D*J-M
      % - where:
      %   R == the number of reaction magnitudes
      %   D == the number of truss dimensions
      %   J == the number of joints
      %   M == the number of members
      %   R >= 0, 1 <= D <= 3, J >= 0, M >= 0
      % ----------------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        R double {mustBeNonempty, mustBeInteger, mustBeNonnegative};
        D double {mustBeNonempty, mustBeInteger, mustBeInRange(D, 1, 3)};
        J double {mustBeNonempty, mustBeInteger, mustBeNonnegative};
        M double {mustBeNonempty, mustBeInteger, mustBeNonnegative};
      end
      % check the argument dimensions
      if ~compatible_dims(R, D, J, M)
        error('input arguments must have compatible dimensions');
      end
      %% determine if the truss is stable
      lhs = R;
      rhs = D.*J-M;
      uniform = {'UniformOutput' false};
      func = @(arg) arg == 0;
      zero_args = fold(@or, cellfun(func, {R J M}, uniform{:}));
      invalid_args = J < 2;
      bool = lhs >= rhs;
      bool(zero_args | invalid_args) = false;
      diff = lhs-rhs;
    end
    % ==
    function bool = statically_determinate(R, D, J, M)
      % ----------------------------------------
      % - returns true if the truss
      %   is statically determinate
      % - the truss is
      %   statically determinate
      %   if R == D*J-M
      % - where:
      %   R == the number of reaction magnitudes
      %   D == the number of truss dimensions
      %   J == the number of joints
      %   M == the number of members
      %   R >= 0, 1 <= D <= 3, J >= 0, M >= 0
      % ----------------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        R double {mustBeNonempty, mustBeInteger, mustBeNonnegative};
        D double {mustBeNonempty, mustBeInteger, mustBeInRange(D, 1, 3)};
        J double {mustBeNonempty, mustBeInteger, mustBeNonnegative};
        M double {mustBeNonempty, mustBeInteger, mustBeNonnegative};
      end
      % check the argument dimensions
      if ~compatible_dims(R, D, J, M)
        error('input arguments must have compatible dimensions');
      end
      %% determine if the truss is statically determinate
      lhs = R;
      rhs = D.*J-M;
      uniform = {'UniformOutput' false};
      func = @(arg) arg == 0;
      zero_args = fold(@or, cellfun(func, {R J M}, uniform{:}));
      invalid_args = J < 2;
      bool = lhs == rhs;
      bool(zero_args | invalid_args) = false;
    end
    % ==
  end
  % ==
end
% ==
function fields = compute_fieldnames(Prop, t)
  % -------------------------------
  % - helper function for computing
  %   the field names of the struct
  %   for the truss tables
  % -------------------------------
  uniform = {'UniformOutput' false};
  switch Prop
    case "load"
      reaction_loc = t.load.class == 'reaction';
      concentrated_loc = t.load.class == 'concentrated';
      num_reactions = height(t.load(reaction_loc,:));
      num_concentrated = height(t.load(concentrated_loc,:));
      fields = t.load.Properties.RowNames;
      if isempty(fields)
        Nums = [{num2cellstr(1:num_reactions)} ...
                {num2cellstr(1:num_concentrated)}];
        Cell = [{repmat({'R'}, 1, num_reactions)} ...
                {repmat({'P'}, 1, num_concentrated)}];
        for k = 1:2
          Cell{k} = cellfun(@horzcat, Cell{k}, Nums{k}, uniform{:});
        end
        fields = vertcat(Cell{:});
      end
    case "joint"
      num_joints = height(t.joint);
      if isempty(t.joint.distance)
        num_dimensions = 1;
      else
        num_dimensions = length(t.joint.distance{1});
      end
      fields = t.joint.Properties.RowNames;
      switch num_dimensions
        case 1
          Cell = repmat({'u'}, num_joints, 1);
        case 2
          Cell = repmat({'u'; 'v'}, num_joints, 1);
        case 3
          Cell = repmat({'u'; 'v'; 'w'}, num_joints, 1);
      end
      if isempty(fields)
        fields = num2cellstr(repmat(1:num_joints, num_dimensions, 1));
      else
        fields = repmat(fields(:).', num_dimensions, 1);
      end
      fields = cellfun(@horzcat, Cell, fields(:), uniform{:});
    case "member"
      num_members = height(t.member);
      fields = t.member.Properties.RowNames;
      if isempty(fields)
        Nums = num2cellstr(1:num_members).';
        fields = repmat({'member'}, num_members, 1);
        fields = cellfun(@horzcat, fields, Nums, uniform{:});
      end
      for k = 1:num_members
        while ismember(fields{k}, t.load.Properties.RowNames)
          fields{k} = [fields{k} '_'];
        end
      end
  end
  fields = convert2identifier(fields);
end
% ==
