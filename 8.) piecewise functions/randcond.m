function s = randcond(a, num, options)
  % -----------------------------
  % - computes random values
  %   that satisfy the condition
  %   of a given branch of a
  %   piecewise expression
  % -----------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
    num (:,1) double ...
    {mustBeNonempty, mustBeInteger, mustBePositive} = default_num(a);
    options.Limit (1,1) double ...
    {mustBeInteger, mustBeGreaterThanOrEqual(options.Limit, 10)} = 10;
  end
  % check the symbolic array
  if ~ispiecewisescalar(a)
    error('''a'' must be a piecewise scalar array');
  end
  % check the branch numbers
  if ~all(ismember(num, 1:numBranches(a)))
    str = stack('''num'' must contain numbers', ...
                'that are greater than or equal to 1', ...
                'and less than or equal to', ...
                'the number of branches of ''a'' (%d)');
    error(str, numBranches(a));
  end
  % check the number limit
  Limit = options.Limit;
  %% compute the random values satisfying the given condition
  cond = condition(a, num);
  [rand_vals s] = deal(cell(size(cond)));
  for k = 1:length(num)
    [cond_vars rand_vals{k}] = deal(num2cell(symvar(cond(k))));
    valid_vals = false;
    while ~valid_vals
      try
        eq_loc = false(size(cond_vars));
        eq = findSymType(cond(k), 'eq');
        for p = 1:length(eq)
          eq_vars = symvar(eq(p));
          eq_vals = symrandis([1 Limit], size(eq_vars));
          eq_vals = num2cell((-1).^randi(0:1, size(eq_vars)).*eq_vals);
          if ~isscalar(eq_vars)
            eq(p) = subs(eq(p), eq_vars(1:end-1), eq_vals(1:end-1));
          end
          eq_vals{end} = rhs(isolate(eq(p), eq_vars(end)));
          [~, ind] = ismember(eq_vars, cond_vars);
          rand_vals{k}(ind) = eq_vals;
          eq_loc(ind) = true;
        end
        [rand_vals{k}{~eq_loc}] = symrandis([-Limit Limit]);
        valid_vals = isAlways(subs(cond(k), cond_vars, rand_vals{k}));
      catch
        valid_vals = false;
      end
    end
    s{k} = cell2struct(rand_vals{k}, string(cond_vars), 2);
  end
  %% modify the output to a more convenient type
  if isallequal(cellfun(@fieldnames, s, 'UniformOutput', false))
    s = table2struct(struct2table(vertcat(s{:})), 'ToScalar', true);
  end
end
% =
function num = default_num(a)
  % ---------------------------------
  % - helper function for determining
  %   the default branch numbers
  % ---------------------------------
  if ispiecewisescalar(a)
    num = 1:numBranches(a);
  else
    num = 1;
  end
end
% =
