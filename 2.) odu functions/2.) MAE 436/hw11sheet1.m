function hw11sheet1(Gun, Gcomp, pnum, ctype, t)
%%----------------------------------------------
if nargin == 4
  t = 0:0.001:10';
end
Tun = feedback(Gun,1);
Tcomp = feedback(Gcomp,1);
%%----------------------------------------------
figure;
titlestr = sprintf('problem #%d', pnum);
legendvals = {'uncompensated system', [ctype ' compensated system']};
%%----------------------------------------------
subplot(2,1,1);
ramp(Tun, Tcomp, 't', t, 'title', {titlestr, '', 'ramp response'}, 'legend', legendvals);
subplot(2,1,2);
sse(Tun, Tcomp, 't', t, 'legend', legendvals);