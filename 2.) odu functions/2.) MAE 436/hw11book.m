function hw11book(G, K, probnum, partnum, logrange)
  if nargin == 4
    logrange = logspace(-4,4,1000);
  end
  %%----------------------------------------------
  subplot(2,1,1);
  probstr = sprintf('problem #11.%d', probnum);
  partstr = [['(part ' partnum] ')'];
  bode(G, logrange); 
  grid;
  title({probstr, partstr, '', 'uncompensated system'});
  %%----------------------------------------------
  subplot(2,1,2);
  bode(K*G, logrange); 
  grid;
  title('gain compensated system');