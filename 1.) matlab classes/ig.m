classdef ig
  % =
  % ---------------------
  % - the ideal gas class
  % ---------------------
  % =
  properties (SetAccess = private)
    name;
    chemical_formula;
    molar_mass;
    R;
    rho;
    cp;
    cv;
    gamma;    
  end
  methods % constructor
    % ==
    function g = ig(name, units)
      % ---------------------------
      % - the ideal gas constructor
      % ---------------------------
      
      %% check the input arguments
      if nargin == 0
        name = 'Air';
        units = 'SI';
      elseif nargin == 1
        units = 'SI';
      elseif isempty(name) && ~isTextScalar(name, ["char" "string"])
        name = 'Air';
      end
      if ~isTextScalar(name, ["char" "string"], 'CheckEmptyText', true)
        error('first argument must be a non-empty string');
      elseif ~isTextScalar(units, ["char" "string"], ...
                           'CheckEmptyText', true) || ...
             ~any(strcmpi(units, {'SI' 'US'}))
        str = stack('second argument must be', ...
                    'one of these strings:', ...
                    '---------------------', ...
                    '1.) ''SI''', ...
                    '2.) ''US''');
        error(str);
      end
      %% construct the ideal gas
      t = ig.props(units);
      if ~isrowvar(t, name)
        error('''%s'' is not found in the ideal gas table', name);
      end
      t = t(name,:);
      g.name = t.Properties.RowNames{1};
      for field = t.Properties.VariableNames
        if ismember(field{1}, {'chemical_formula' 'gamma'})
          g.(field{1}) = t.(field{1});
        else        
          unit = str2symunit(t.Properties.VariableUnits{field{1}});
          g.(field{1}) = t.(field{1})*unit;
          if strcmpi([field(1) {units}], {'molar_mass' 'US'})
            g.(field{1}) = g.(field{1})*2.20462;
          elseif strcmpi([field(1) {units}], {'rho' 'US'})
            g.(field{1}) = g.(field{1})/10^3;
          end        
        end
      end
    end
    % ==
  end
  methods % isentropic flow functions
    function answer = Ms(g, M)
      % -------------------------------------
      % - don't know much about this function
      % -------------------------------------
      
      %% check the input argument
      if ~isnumeric(M) && ~issym(M)
        error('M must be a numeric or symbolic expression');
      end
      if issymfun(M)
        convert2symfun = true;
        args = argnames(M);
        M = formula(M);
      else
        convert2symfun = false;
      end
      %% compute Ms
      negative = (isnumeric(M) & M < 0) | ...
                 (issym(M) & isAlways(M < 0, 'Unknown', 'false'));
      expr = 2/(g.gamma+1)*(1+(g.gamma-1)/2*M.^2);
      answer = M./sqrt(expr);
      answer(negative) = nan;
      answer(isinf(M)) = sqrt((g.gamma+1)/(g.gamma-1));
      if convert2symfun
        answer(args) = answer;
      end
    end
    function ratio = A_As(g, M)
      % -----------------------------
      % - computes the sonic velocity
      %   area ratio for the ideal gas
      % -----------------------------
      
      %% check the input argument
      if ~isnumeric(M) && ~issym(M)
        error('M must be a numeric or symbolic expression');
      end
      if issymfun(M)
        convert2symfun = true;
        args = argnames(M);
        M = formula(M);
      else
        convert2symfun = false;
      end
      %% compute the ratio
      negative = (isnumeric(M) & M < 0) | ...
                 (issym(M) & isAlways(M < 0, 'Unknown', 'false'));
      expr = 2/(g.gamma+1)*(1+(g.gamma-1)/2*M.^2);
      ratio = expr.^((g.gamma+1)/(2*(g.gamma-1)))./M;
      ratio(negative) = nan;
      ratio(isinf(M)) = inf;
      if convert2symfun
        ratio(args) = ratio;
      end
    end
    function ratio = p_po(g, M)
      % ----------------------------------
      % - computes the stagnation pressure
      %   ratio for the ideal gas
      % ----------------------------------
      
      %% check the input argument
      if ~isnumeric(M) && ~issym(M)
        error('M must be a numeric or symbolic expression');
      end
      if issymfun(M)
        convert2symfun = true;
        args = argnames(M);
        M = formula(M);
      else
        convert2symfun = false;
      end
      %% compute the ratio
      negative = (isnumeric(M) & M < 0) | ...
                 (issym(M) & isAlways(M < 0, 'Unknown', 'false'));
      expr = 1+(g.gamma-1)/2*M.^2;
      ratio = expr.^(-g.gamma/(g.gamma-1));
      ratio(negative) = nan;
      if convert2symfun
        ratio(args) = ratio;
      end
    end
    function ratio = rho_rhoo(g, M)
      % ---------------------------------
      % - computes the stagnation density
      %   ratio for the ideal gas
      % ---------------------------------
      
      %% check the input argument
      if ~isnumeric(M) && ~issym(M)
        error('M must be a numeric or symbolic expression');
      end
      if issymfun(M)
        convert2symfun = true;
        args = argnames(M);
        M = formula(M);
      else
        convert2symfun = false;
      end
      %% compute the ratio
      negative = (isnumeric(M) & M < 0) | ...
                 (issym(M) & isAlways(M < 0, 'Unknown', 'false'));
      expr = 1+(g.gamma-1)/2*M.^2;
      ratio = expr.^(-1/(g.gamma-1));
      ratio(negative) = nan;
      if convert2symfun
        ratio(args) = ratio;
      end
    end
    function ratio = T_To(g, M)
      % -------------------------------------
      % - computes the stagnation temperature
      %   ratio for the ideal gas
      % -------------------------------------
      
      %% check the input argument
      if ~isnumeric(M) && ~issym(M)
        error('M must be a numeric or symbolic expression');
      end
      if issymfun(M)
        convert2symfun = true;
        args = argnames(M);
        M = formula(M);
      else
        convert2symfun = false;
      end
      %% compute the ratio
      negative = (isnumeric(M) & M < 0) | ...
                 (issym(M) & isAlways(M < 0, 'Unknown', 'false'));
      expr = 1+(g.gamma-1)/2*M.^2;
      ratio = expr.^-1;
      ratio(negative) = nan;
      if convert2symfun
        ratio(args) = ratio;
      end
    end
  end
  methods % normal shock functions
    function answer = My(g, Mx)
      % --------------------------------
      % - computes the Mach number
      %   at the downstream of a
      %   normal shock for the ideal gas
      % --------------------------------
      
      %% check the input argument
      if ~isnumeric(Mx) && ~issym(Mx)
        error('Mx must be a numeric or symbolic expression');
      end
      if issymfun(Mx)
        convert2symfun = true;
        args = argnames(Mx);
        Mx = formula(Mx);
      else
        convert2symfun = false;
      end
      %% compute the ratio
      subsonic = (isnumeric(Mx) & Mx < 1) | ...
                 (issym(Mx) & isAlways(Mx < 1, 'Unknown', 'false'));
      expr = (Mx.^2+2/(g.gamma-1))./(2*g.gamma/(g.gamma-1)*Mx.^2-1);
      answer = sqrt(expr);
      answer(subsonic) = nan;
      answer(isinf(Mx)) = sqrt((g.gamma-1)/(2*g.gamma));
      if convert2symfun
        answer(args) = answer;
      end      
    end
    function ratio = py_px(g, Mx)
      % -------------------------------------
      % - computes the ratio of the
      %   downstream to upstream
      %   static temperatures
      %   of a normal shock for the ideal gas
      % -------------------------------------      
      
      %% check the input argument
      if ~isnumeric(Mx) && ~issym(Mx)
        error('Mx must be a numeric or symbolic expression');
      end
      if issymfun(Mx)
        convert2symfun = true;
        args = argnames(Mx);
        Mx = formula(Mx);
      else
        convert2symfun = false;
      end
      %% compute the ratio
      subsonic = (isnumeric(Mx) & Mx < 1) | ...
                 (issym(Mx) & isAlways(Mx < 1, 'Unknown', 'false'));
      ratio = (1+g.gamma*Mx.^2)./(1+g.gamma*g.My(Mx).^2);
      ratio(subsonic) = nan;
      if convert2symfun
        ratio(args) = ratio;
      end
    end
    function ratio = rhoy_rhox(g, Mx)
      % -------------------------------------
      % - computes the ratio of the
      %   downstream to upstream
      %   static densities
      %   of a normal shock for the ideal gas
      % -------------------------------------      
      
      %% check the input argument
      if ~isnumeric(Mx) && ~issym(Mx)
        error('Mx must be a numeric or symbolic expression');
      end      
      %% compute the ratio
      ratio = g.py_px(Mx)./g.Ty_Tx(Mx);
      ratio(isinf(Mx)) = (g.gamma+1)/(g.gamma-1);
    end
    function ratio = Ty_Tx(g, Mx)
      % --------------------------------------
      % - computes the ratio of the
      %   downstream to upstream
      %   static temperatures temperatures
      %   of a normal shock for the ideal gas
      % --------------------------------------     
      
      %% check the input argument
      if ~isnumeric(Mx) && ~issym(Mx)
        error('Mx must be a numeric or symbolic expression');
      end      
      %% compute the ratio
      ratio = g.py_px(Mx).^2.*g.My(Mx).^2./Mx.^2;
      ratio(isinf(Mx)) = inf;
    end
    function ratio = poy_pox(g, Mx)
      % --------------------------------------
      % - computes the ratio of the
      %   downstream to upstream 
      %   stagnation pressures
      %   of a normal shock for the ideal gas
      % --------------------------------------     
      
      %% check the input argument
      if ~isnumeric(Mx) && ~issym(Mx)
        error('Mx must be a numeric or symbolic expression');
      end      
      %% compute the ratio
      ratio = g.py_px(Mx).*g.p_po(Mx)./g.p_po(g.My(Mx));
      ratio(isinf(Mx)) = 0;
    end
    function ratio = poy_px(g, Mx)
      % --------------------------------------
      % - computes the ratio of the
      %   downstrem stagnation pressure
      %   to the upstream static pressure      
      %   of a normal shock for the ideal gas
      % --------------------------------------     
      
      %% check the input argument
      if ~isnumeric(Mx) && ~issym(Mx)
        error('Mx must be a numeric or symbolic expression');
      end      
      %% compute the ratio
      ratio = g.poy_pox(Mx)./g.p_po(Mx); 
      ratio(isinf(Mx)) = inf;
    end
  end
  methods % airfoil functions
    % ==
    function [f c] = airfoil(g, Mi, fy, fx, alpha, pic)
      if nargin == 5
        pic = 1;
      end
      if isnumscalar(Mi)
        Mi(abs(Mi) < 0) = 0;
        if Mi < 1
          error('all M values must be positive');
        end        
      elseif ~issymscalar(Mi)
        error('Mi must be a numeric or symbolic scalar');
      end
      if isnumvector(fy)
        fy(abs(fy) <= 1e-5) = 0;
        if any(fy < 0)
          error('all pyypi values must be positive');
        end        
      elseif ~issymvector(fy)
        error('pxxpi must be a numeric or symbolic vector');
      end
      if isnumvector(fx)
        fx(abs(fx) <= 1e-5) = 0;
        if any(fx < 0)
          error('all fxpi values must be positive');
        end        
      elseif ~issymvector(fx)
        error('fxpi must be a numeric or symbolic vector');
      end
      if isnumscalar(alpha)
        alpha(abs(alpha) < 0) = 0;
        if alpha < 1
          error('all alpha values must be positive');
        end        
      elseif ~issymscalar(alpha)
        error('alpha must be a numeric or symbolic scalar');
      end
      if ~iscolumn(Mi)
        Mi = Mi.';
      end
      if ~isrow(fy)
        fy = fy.';
      end
      if ~isrow(fx)
        fx = fx.';
      end
      alpha = alpha*pi/180;
      A = [cos(alpha) -sin(alpha); sin(alpha) cos(alpha)];
      B = [fy; fx];
      f = A*B;
      c = f/(0.5*g.gamma*Mi^2*pic);
    end
    % ==
  end
  methods (Static) % Prandtl-Meyer functions
    % ==
    function val = mu(M)
      % ------------------------------
      % - don't remember this function
      % ------------------------------
      
      %% check the input arguments
      if ~isnumeric(M) && ~issym(M)
        error('M must be a numeric or symbolic expression');
      end
      M = sym(M);
      if any(isAlways(M(:) < 0, 'Unknown', 'false'))
        error('M values must be positive');
      end
      %% compute mu
      val = asind(1./M)*symunit('deg');
      val(isAlways(M(:) < 1, 'Unknown', 'false')) = nan;
    end
    % ==
  end
  methods % Prandtl-Meyer functions
    % ==
    function val = nu(g, M)
      % ------------------------------
      % - don't remember this function
      % ------------------------------
      
      %% check the input arguments
      if ~isnumeric(M) && ~issym(M)
        error('M must be a numeric or symbolic expression');
      end
      M = sym(M);
      if any(isAlways(M(:) < 0, 'Unknown', 'false'))
        error('M values must be positive');
      end
      %% compute nu
      a = sqrt((g.gamma+1)/(g.gamma-1));
      b = sqrt(M.^2-1);
      b(isAlways(M(:) < 1, 'Unknown', 'false')) = nan;
      val = (a.*atand(b./a)-atand(b))*symunit('deg');      
    end
    % ==
    function val = numax(g)
      a = sqrt((g.gamma+1)/(g.gamma-1))-1;
      val = 90*a*symunit('deg');
    end
    % ==
  end
  methods % oblique shock functions
    % ==
    function val = theta1(g, Mx)
      if isnumvector(Mx)
        Mx(abs(Mx-1) <= 1e-5) = 1;
        if any(Mx < 1)
          error('all Mx values must be >= 1');
        end        
      elseif ~issymvector(Mx)
        error('Mx must be a numeric or symbolic vector');
      end            
      if ~iscolumn(Mx)
        Mx = Mx.';
      end
      a = 1./(g.gamma*Mx.^2);
      b = (g.gamma+1)/4*Mx.^2-(3-g.gamma)/4;
      c = g.gamma+1;
      d = (g.gamma+1)/16*Mx.^4+(g.gamma-3)/8*Mx.^2+(g.gamma+9)/16;
      e = b+sqrt(c*d);
      val = asin(sqrt(a.*e))*180/pi;
    end
    % ==
    function val = phi1(g, Mx)
      if isnumvector(Mx)
        Mx(abs(Mx-1) <= 1e-5) = 1;
        if any(Mx < 1)
          error('all Mx values must be >= 1');
        end        
      elseif ~issymvector(Mx)
        error('Mx must be a numeric or symbolic vector');
      end            
      if ~iscolumn(Mx)
        Mx = Mx.';
      end
      if any(Mx < 1)
        error('all Mx values must be >= 1');
      end    
      theta1 = g.theta1(Mx);
      val = g.phi(Mx, theta1);      
    end
    % ==
    function val = thetamax(g, Mx)
      if isnumvector(Mx)
        Mx(abs(Mx-1) <= 1e-5) = 1;
        if any(Mx < 1)
          error('all Mx values must be >= 1');
        end        
      elseif ~issymvector(Mx)
        error('Mx must be a numeric or symbolic vector');
      end            
      if ~iscolumn(Mx)
        Mx = Mx.';
      end
      a = 1./(g.gamma*Mx.^2);
      b = (g.gamma+1)/4*Mx.^2-1;
      c = g.gamma+1;
      d = (g.gamma+1)/16*Mx.^4+(g.gamma-1)/2*Mx.^2+1;
      e = b+sqrt(c*d);
      val = asin(sqrt(a.*e))*180/pi;
    end
    % ==
    function val = phimax(g, Mx)
      if isnumvector(Mx)
        Mx(abs(Mx-1) <= 1e-5) = 1;
        if any(Mx < 1)
          error('all Mx values must be >= 1');
        end       
      elseif ~issymvector(Mx)
        error('Mx must be a numeric or symbolic vector');
      end      
      if ~iscolumn(Mx)
        Mx = Mx.';
      end     
      thetamax = g.thetamax(Mx);
      val = g.phi(Mx, thetamax);
    end
    % ==
    function val = theta(g, Mx, phi)
      %% check the Mx argument
      if isnumvector(Mx)
        Mx(abs(Mx-1) <= 1e-5) = 1;
        if any(Mx < 1)
          error('all Mx values must be >= 1');
        end        
      elseif ~issymvector(Mx)
        error('Mx must be a numeric or symbolic vector');
      end            
      if ~iscolumn(Mx)
        Mx = Mx.';
      end
      n = length(Mx);
      %% check the phi argument
      if ~isnumeric(phi) && ~issym(phi)
        str = stack('phi must be one of these values:', ...
                    '--------------------------------', ...
                    '1.) a numeric or symbolic array', ...
                    '2.) a cell column vector containing', ...
                    '    numeric or symbolic row vectors');
        if iscellcol(phi)
          numrow = cellfun(@isnumrow, phi);
          if ~all(numrow)
            error(str);
          end
        else
          error(str);
        end        
      end
      rows = size(phi,1);      
      %% check for out of range phi values
      if n ~= rows
        error('Mx and phi must have equal rows');
      end
      phimax = g.phimax(Mx);
      for k = 1:n
        if ~iscell(phi)
          phivec = phi(k,:);
        else
          phivec = phi{k};
        end
        if ~issym(phi)
          inrange = 0 <= phivec & phivec <= phimax(k);
          if ~all(inrange)
            str = stack('detached shock solutions are found...', ...
                        'cannot compute theta');
            error(str);
          end
        end        
      end      
      %% compute the theta values
      val.weak = phi;
      val.strong = phi;      
      for k = 1:n
        if ~iscell(phi)
          phivec = phi(k,:)*pi/180;
        else
          phivec = phi{k}*pi/180;
        end
        a = Mx(k)^4*sec(phivec).^2;
        b = g.gamma*Mx(k)^4*tan(phivec).^2+(Mx(k)^4+2*Mx(k)^2)*sec(phivec).^2;
        c = ((g.gamma+1)*Mx(k)^2+2)^2/4*tan(phivec).^2+2*Mx(k)^2+1;        
        soln = real(cubic(a, -b, c, -1));
        soln(1,:) = [];
        rhs = asin(sqrt(soln))*180/pi;        
        if ~iscell(phi)
          val.weak(k,:) = rhs(1,:);
          val.strong(k,:) = rhs(2,:);
        else
          val.weak{k} = rhs(1,:);
          val.strong{k} = rhs(2,:);
        end     
      end      
    end
    % ==
    function val = phi(g, Mx, theta)
      %% check the Mx argument
      if isnumvector(Mx)
        Mx(abs(Mx-1) <= 1e-5) = 1;
        if any(Mx < 1)
          error('all Mx values must be >= 1');
        end        
      elseif ~issymvector(Mx)
        error('Mx must be a numeric or symbolic vector');
      end            
      if ~iscolumn(Mx)
        Mx = Mx.';
      end
      n = length(Mx);
      %% check the theta argument
      if ~isnumeric(theta) && ~issym(theta)
        str = stack('theta must be one of these values:', ...
                    '----------------------------------', ...
                    '1.) a numeric or symbolic array', ...
                    '2.) a cell column vector containing', ...
                    '    numeric or symbolic row vectors');
        if iscellcol(theta)
          numrow = cellfun(@isnumrow, theta);
          if ~all(numrow)
            error(str);
          end
        else
          error(str);
        end        
      end     
      rows = size(theta,1);
      %% check for out of range theta values
      if n ~= rows
        error('Mx and phi must have equal rows');
      end
      mu = g.mu(Mx);
      for k = 1:n
        if ~iscell(theta)
          thetavec = theta(k,:);
        else
          thetavec = theta{k};
        end
        if ~issym(thetavec)
          inrange = mu(k) <= thetavec & thetavec <= 90;
          if ~all(inrange)
            str = stack('all theta values', ...
              'must be in the range of', ...
              'mu to 90 degrees');
            error(str);
          end
        end
      end
      %% compute the phi values
      val = theta;      
      for k = 1:n
        if ~iscell(theta)
          thetavec = theta(k,:)*pi/180;
        else
          thetavec = theta{k}*pi/180;
        end        
        K = cot(thetavec).*(Mx(k)^2*sin(thetavec).^2-1);
        L = (g.gamma+1)/2*Mx(k)^2-Mx(k)^2*sin(thetavec).^2+1;
        rhs = atan(K./L)*180/pi;
        if ~issym(theta)
          rhs(rhs <= 1e-5) = 0;
          rhs(abs(rhs-90) <= 1e-5) = 90;
        end
        if ~iscell(theta)
          val(k,:) = rhs;
        else
          val{k} = rhs;
        end        
      end
    end
    % ==
    function nose(g, Mx)
      nargs = nargin-1;
      %% check the Mx argument
      if nargs == 0
        Mx = (1.5:0.5:4)';
      end
      if ~isnumvector(Mx)
        error('Mx must be a numeric vector');
      end
      if ~iscolumn(Mx)
        Mx = Mx';
      end
      Mx(Mx-1 <= 1e-5) = [];
      if any(Mx <= 1)
        error('all Mx values must be > 1');
      end      
      n = length(Mx);
      %% obtain the phi and theta values
      tbl = g.oblique(Mx, 'theta');
      phi = cell(1,n);
      theta = cell(1,n);
      for k = 1:n
        phi{k} = tbl{tbl.Mx == Mx(k), 'phi'};
        theta{k} = tbl{tbl.Mx == Mx(k), 'theta'};        
      end
      phi = horzcat(phi{:});
      theta = horzcat(theta{:});
      %% plot the nose profile
      figure;
      plot(phi, theta);
      title('nose profiles');
      xlabel('phi');
      ylabel('theta');
      legstr = cell(n,1);
      legstr(:) = {'Mx = %.1f'};
      legstr = cellfun(@sprintf, legstr, num2cell(Mx), ...
                       'UniformOutput', false);
      legend(legstr);
    end
    % ==
  end 
  methods % ratio tables
    % ==
    function t = isentropic(g)
      % ------------------------------------
      % - returns the isentropic flow ratios
      %   for an ideal gas with a
      %   mach number 'M' and specific heat
      %   ratio 'g' (g == 1.4 by default)
      % ------------------------------------
      persistent tbl;
      if isempty(tbl)
        M = [0:0.1:3 3.5:0.5:5 6:10 inf].';
        Ms = g.Ms(M);
        A_As = g.A_As(M);
        p_po = g.p_po(M);
        rho_rhoo = g.rho_rhoo(M);
        T_To = g.T_To(M);
        tbl = table(M, Ms, A_As, p_po, rho_rhoo, T_To);
      end
      t = tbl;
    end    
    % ==
    function t = normal_shock(g)
      % ------------------------------------
      % - returns the isentropic flow ratios
      %   for an ideal gas with a
      %   mach number 'M' and specific heat
      %   ratio 'g' (g == 1.4 by default)
      % ------------------------------------
      persistent tbl;
      if isempty(tbl)
        Mx = [1:0.05:2.6 2.7:0.1:3 4:5 10 inf].';
        My = g.My(Mx);
        py_px = g.py_px(Mx);
        rhoy_rhox = g.rhoy_rhox(Mx);
        Ty_Tx = g.Ty_Tx(Mx);
        poy_pox = g.poy_pox(Mx);
        poy_px = g.poy_px(Mx);
        tbl = table(Mx, My, py_px, rhoy_rhox, Ty_Tx, poy_pox, poy_px);
      end
      t = tbl;
    end
    % ==
    function tbl = fanno(g)
      nargs = nargin-1;      
      %% check the M argument
      if nargs == 0
        M = [0:0.02:5 6:10]';
      end
      if isnumvector(M)
        M(abs(M) <= 1e-5) = 0;
        if any(M < 0)
          error('all M values must be >= 0');
        end        
      elseif ~issymvector(M)
        error('M must be a numeric or symbolic vector');
      end            
      if ~iscolumn(M)
        M = M.';
      end 
      %% compute the Fanno table
      % ====================================================
      a = (g.gamma+1)./(2+(g.gamma-1)*M.^2);
      b = (g.gamma+1)/(2*g.gamma);
      c = 1./M.^2;
      % ----------------------------
      tts = a;
      pps = sqrt(a)./M;
      popos = (1./a).^((g.gamma+1)/(2*(g.gamma-1)))./M;
      rrs = sqrt(1./a)./M;           
      fLmaxD = b.*log(a./c)-(1-c)/g.gamma;
      % ====================================================
      a = (g.gamma+1)/(2*(g.gamma-1));
      b = (2+(g.gamma-1)*M.^2)/(g.gamma+1);
      % ---------------------------
      ss_s_R = a*log(b)-log(M);      
      % ====================================================
      tbl = table(M, tts, pps, popos, rrs, fLmaxD, ss_s_R);
      if ~issym(tbl{:,:})
        tbl{:,:}(abs(tbl{:,:}) <= 1e-5) = 0;
        tbl{:,:}(abs(imag(tbl{:,:})) <= 1e-5) = real(tbl{:,:});
      end
    end
    % ==
    function tbl = rayleigh(g, M)
      nargs = nargin-1;      
      %% check the M argument
      if nargs == 0
        M = [0:0.02:5 6:10]';
      end
      if isnumvector(M)
        M(abs(M) <= 1e-5) = 0;
        if any(M < 0)
          error('all M values must be >= 0');
        end        
      elseif ~issymvector(M)
        error('M must be a numeric or symbolic vector');
      end            
      if ~iscolumn(M)
        M = M.';
      end 
      %% compute the Rayleigh table
      % ==================================================
      a = (1+g.gamma)^2*M.^2./(1+g.gamma*M.^2).^2;
      b = (2+(g.gamma-1)*M.^2)/(g.gamma+1);
      c = (1+g.gamma)./(1+g.gamma*M.^2);
      % --------------------------
      totos = a.*b;
      tts = a;
      popos = c.*b.^(g.gamma/(g.gamma-1));
      pps = c;
      VVs = sqrt(a).*M;
      % ==================================================
      a = 1/(g.gamma-1);
      b = 1./M.^(2*g.gamma);
      c = ((1+g.gamma*M.^2)/(1+g.gamma)).^(g.gamma+1);
      % ----------------------------------
      ss_s_R = a*log(b.*c);   
      % ==================================================
      tbl = table(M, totos, tts, popos, pps, VVs, ss_s_R);
      if ~issym(tbl{:,:})
        tbl{:,:}(abs(tbl{:,:}) <= 1e-5) = 0;
        tbl{:,:}(abs(imag(tbl{:,:})) <= 1e-5) = real(tbl{:,:});
      end
    end
    
    function varargout = oblique_shock(g, Mx, what, angle)
      % ----------------------------------
      % - returns the oblique shock ratios
      %   for an ideal gas with an upstram
      %   mach number 'Mx', turn angle
      %   'phi' and specific heat
      %   ratio 'g' (g == 1.4 by default)
      % ----------------------------------
      nargs = nargin-1;      
      %% check the Mx argument
      if isnumvector(Mx)
        Mx(abs(Mx-1) <= 1e-5) = 1;
        if any(Mx < 1)
          error('all Mx values must be >= 1');
        end        
      elseif ~issymvector(Mx)
        error('Mx must be a numeric or symbolic vector');
      end            
      if ~iscolumn(Mx)
        Mx = Mx.';
      end  
      n = length(Mx);
      %% check the angle argument
      switch lower(scalar(what))
        case {'phi' 'theta'}          
        otherwise
          str = stack('second argument must be', ...
                      'one of these strings:', ...
                      '---------------------', ...
                      '1.) ''phi''', ...
                      '2.) ''theta''');
          error(str);
      end
      if nargs == 2
        angle = zeros(n,100);
        switch lower(scalar(what))
          case 'phi'
            minvals = zeros(size(Mx));
            maxvals = g.phimax(Mx);
          case 'theta'
            minvals = asin(1./Mx)*180/pi;
            maxvals = 90*ones(size(Mx));
        end
        for k = 1:n
          angle(k,:) = linspace(minvals(k), maxvals(k));
        end
      end
      if ~isnumeric(angle) && ~issym(angle)
        str = stack('angle must be one of these values:', ...
                    '----------------------------------', ...
                    '1.) a numeric or symbolic array', ...
                    '2.) a cell column vector containing', ...
                    '    numeric or symbolic row vectors');
        if iscellcol(angle)
          numrow = cellfun(@isnumrow, angle);
          if ~all(numrow)
            error(str);
          end
        else
          error(str);
        end        
      end                        
      rows = size(angle,1);
      %% compute the oblique shock table
      if n ~= rows
        error('Mx and phi must have equal rows');
      end
      if ~iscell(angle)
        cols = size(angle,2);
      else
        cols = cellfun('length', angle);
      end
      varnames = {'Mx' 'phi' 'theta'};
      switch what
        case 'phi'
          nargoutchk(0,2);
          phi = angle;
          theta = g.theta(Mx, phi);
          varargout = {cell(n,1) cell(n,1)};          
          for k = 1:rows
            if ~iscell(phi)
              Mxkvec = Mx(k)*ones(cols,1);
              phivec = phi(k,:).'*pi/180;
            else
              Mxkvec = Mx(k)*ones(cols(k),1);
              phivec = phi{k}.';
            end
            for v = {'weak' 'strong'; 1 2}
              if ~iscell(phi)
                thetavec = theta.(v{1})(k,:).'*pi/180;
              else
                thetavec = theta.(v{1}){k}.'*pi/180;
              end
              % -------------------------------------------
              Mxn = Mx(k)*sin(thetavec);
              shock = g.shock(Mxn);                            
              Myn = shock.My;
              Mxt = Mx(k)*cos(thetavec);
              Myt = Myn./tan(thetavec-phivec);
              My = Myn./sin(thetavec-phivec);
              pypx = shock.pypx;
              tytx = shock.tytx;
              ryrx = shock.ryrx;
              poypox = shock.poypox;
              sy_sx = shock.sy_sx;             
              % -------------------------------------------
              phivec = phivec*180/pi;
              thetavec = thetavec*180/pi;
              tbl = table(Mxkvec, phivec, thetavec, ...
                          Mxn, Myn, Mxt, Myt, ...
                          My, pypx, tytx, ryrx, ...
                          poypox, sy_sx);
              tbl.Properties.VariableNames(1:3) = varnames;              
              % -------------------------------------------
              if ~issym(tbl{:,:})
                tbl{:,:}(abs(tbl{:,:}) < 1e-5) = 0;
                tbl{:,:}(abs(imag(tbl{:,:})) < 1e-5) = real(tbl{:,:});
              end
              varargout{v{2}}{k} = tbl;
              phivec = phivec*pi/180;
            end            
          end                   
        case 'theta'
          nargoutchk(0,1);
          theta = angle;          
          phi = g.phi(Mx, theta);
          varargout = {cell(n,1)};
          for k = 1:rows
            if ~iscell(phi)
              Mxkvec = Mx(k)*ones(cols,1);
              phivec = phi(k,:).'*pi/180;
              thetavec = theta(k,:).'*pi/180;
            else
              Mxkvec = Mx(k)*ones(cols(k),1);
              phivec = phi{k}.'*pi/180;
              thetavec = theta{k}.'*pi/180;
            end            
            % -------------------------------------------            
            Mxn = Mxkvec.*sin(thetavec);
            shock = g.shock(Mxn);            
            Myn = shock.My;
            Mxt = Mxkvec.*cos(thetavec);
            Myt = Myn./tan(thetavec-phivec);
            My = Myn./sin(thetavec-phivec);
            pypx = shock.pypx;
            tytx = shock.tytx;
            ryrx = shock.ryrx;
            poypox = shock.poypox;
            sy_sx = shock.sy_sx;
            % -------------------------------------------
            phivec = phivec*180/pi;
            thetavec = thetavec*180/pi;
            tbl = table(Mxkvec, phivec, thetavec, ...
                        Mxn, Myn, Mxt, Myt, ...
                        My, pypx, tytx, ryrx, ...
                        poypox, sy_sx);
            tbl.Properties.VariableNames(1:3) = varnames;
            % -------------------------------------------
            if ~issym(tbl{:,:})
              tbl{:,:}(abs(tbl{:,:}) < 1e-5) = 0;
              tbl{:,:}(abs(imag(tbl{:,:})) < 1e-5) = real(tbl{:,:});
            end
            varargout{1}{k} = tbl;            
          end
      end
      for k = 1:length(varargout)
        varargout{k} = vertcat(varargout{k}{:});
      end
    end
    % ==
  end  
  methods (Static) % property table
    % ==
    function t = props(units)
      % ----------------------------
      % - returns a table containing
      %   the properties of various
      %   ideal gases
      % ----------------------------
      
      %% check the input arguments
      if nargin == 0
        units = 'SI';
      elseif ~isTextScalar(units, 'CheckEmptyText', true) || ...
             ~any(strcmpi(units, {'SI' 'US'}))
        str = stack('input argument must be', ...
                    'one of these strings:', ...
                    '---------------------', ...
                    '1.) ''SI''', ...
                    '2.) ''US''');
        error(str);
      end      
      %% construct the ideal gas table
      persistent t_SI;
      persistent t_US;
      if isempty(t_SI)
        args = {'Range' 'A2:H31' ... 
                'ReadVariableNames' false ...
                'ReadRowNames' true};
        varnames = {'chemical_formula';
                    'molar_mass';
                    'R';
                    'rho';
                    'cp';
                    'cv';
                    'gamma'};
        t_SI = readtable(which('Table H.1 (SI).xlsx'), args{:});
        t_SI.Properties.VariableNames = varnames;
        t_SI.Properties.VariableUnits = {'1';
                                         'kg/kmol';
                                         'kJ/(kg*K)';
                                         'kg/m^3';
                                         'kJ/(kg*K)';
                                         'kJ/(kg*K)';
                                         '1'};
      end
      if isempty(t_US)
        t_US = readtable(which('Table H.1 (US).xlsx'), args{:});
        t_US.Properties.VariableNames = varnames;
        t_US.Properties.VariableUnits = {'1';
                                         'lbm/kmol';
                                         'ft*lbf/(lbm*Rankine)';
                                         'lbm/ft^3';
                                         'Btu/(lbm*Rankine)';
                                         'Btu/(lbm*Rankine)';
                                         '1'};
      end
      if strcmpi(units, 'SI')
        t = t_SI;
      else
        t = t_US;
      end                                     
    end    
    % ==
  end
end
