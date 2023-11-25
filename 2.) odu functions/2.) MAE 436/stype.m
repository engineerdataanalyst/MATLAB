function type = stype(G)
% returns the system type of
% the open loop transfer function (G)
  if isa(G, 'zpk')
    G = tf(G);
  end
  den = cell2mat(G.den);
  n = length(den);
  type = 0;
  for k = 1:n
    if den(k) == 0
      type = type+1;
    end
  end    