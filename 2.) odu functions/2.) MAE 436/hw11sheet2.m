function hw11sheet2(Ggain, Glead, probnum, ctype, logrange)
  if nargin == 4
    logrange = logspace(-4,4,1000);
  end
  %%----------------------------------------------
  subplot(2,1,1);
  probstr = sprintf('problem #%d', probnum);  
  bode(Ggain, logrange); 
  grid;
  title({probstr, '', 'gain compensated system'});
  %%----------------------------------------------
  subplot(2,1,2);
  bode(Glead, logrange); 
  grid;
  title([ctype ' compensated system']);