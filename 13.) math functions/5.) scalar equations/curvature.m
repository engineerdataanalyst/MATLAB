function K = curvature(varargin)
  % --------------------------
  % - returns the curvature
  %   of a symbolic expression
  % --------------------------
  try
    s = parse_curvature_args(varargin{:});
  catch Error
    throw(Error);
  end
  mode = s.mode;
  switch mode
    case "cartesian"
      dy = s.dy;
      d2y = s.d2y;
      K = d2y./(1+dy.^2).^(3/2);
    case "polar"
      r = s.y;
      dr = s.dy;
      d2r = s.d2y;
      K = (r.^2+2*dr.^2-r.*d2r)./(r.^2+dr.^2).^(3/2);
    case "parametric"
      dS = s.dS;
      dT = s.dT;
      if iscell(dS)
        symfuns = cellfun(@issymfun, dS);
        if any(symfuns)
          args = cellfun(@argnames, dS(symfuns), 'UniformOutput', false);
          dS = cellfun(@formula, dS, 'UniformOutput', false);
          dT = cellfun(@formula, dT, 'UniformOutput', false);
        end
        K = cellfun(@Norm, dT)./cellfun(@Norm, dS);
        if any(symfuns)
          K(args{1}) = K;
        end
      else
        K = Norm(dT)/Norm(dS);
      end
  end
  K = abs(simplify(K, 'IgnoreAnalyticConstraints', true));
