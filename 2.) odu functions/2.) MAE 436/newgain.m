function [Gnew Tnew] = newgain(G, Knew)
  [zeros poles Kold] = zpkdata(G);  
  Gzpk = zpk(zeros, poles, Knew/Kold);
  switch class(G)
    case 'tf'      
      Gnew = tf(Gzpk);      
    case 'zpk'
      Gnew = Gzpk;
  end
  Tnew = feedback(Gnew,1);