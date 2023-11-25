G = 3.6*zpk([],[0 -36 -100],100);
req = req2('trans', {'os', 20}, 'ssef', 40*req2.sse(G));
[Gun Tun un] = un2(G, req);
[Glead Tlead lead] = lead2(Gun, req);
titlestr = {'Example 11.3', '', 'Step Response'};
legendlist = {'un', 'lead'};
plotlist1 = {'title', titlestr, 'legend', legendlist};
plotlist2 = {'legend', legendlist};
figure;
subplot(2,1,1);
req1.plot('step', Tun, Tlead, plotlist1{:});
subplot(2,1,2);
req1.plot('ramp', Tun, Tlead, plotlist2{:}, 'sse');