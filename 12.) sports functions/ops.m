function percentage = ops(h, bb, hbp, sf, ...
                          singles, doubles, triples, hr, ab)
  % -------------------------------
  % - on-base plus slugging formula
  %   used in MLB
  % -------------------------------
  narginchk(9,9);
  percentage = obp(h, bb, hbp, sf, ab)+...
               slg(singles, doubles, triples, hr, ab);
