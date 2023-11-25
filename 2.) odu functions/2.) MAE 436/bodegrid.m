function bodegrid(xpowmin, xpowmax, magrange, phaserange)
  if nargin == 2
    magrange = -80:20:80;
    phaserange = -180:45:180;
  elseif nargin == 3
    phaserange = -180:45:180;
  end
  maglen = length(magrange);
  phaselen = length(phaserange);
  for k = 1:2
    subplot(2,1,k);  
    set(gca, 'Xscale', 'log');
    if k == 1
      axis([10^xpowmin 10^xpowmax magrange(1) magrange(maglen)]);
      set(gca, 'Ytick', magrange);
      title('Bode Diagram');
      ylabel('Magnitude (dB)');
    else
      axis([10^xpowmin 10^xpowmax phaserange(1) phaserange(phaselen)]);
      set(gca, 'Ytick', phaserange);
      xlabel('Frequency (rad/s)');
      ylabel('Phase (deg)');
    end
    grid;
  end