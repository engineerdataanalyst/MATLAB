%% beam
b = beam('triangular');

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

setassum(old_assum);
clear old_assum;

%% shear and bending moment diagrams
beam.shear_moment(m, v, [0 1], [wo L], 1);
subplot(2,1,1);
axis([0 1 -0.40 0.25]);
subplot(2,1,2);
axis([0 1 0 0.073]);

%% maximum deflection
old_assum = assumptions;
setassum(0 < x & x < b.L & in(x, 'real'), 'clear');
assumeAlso(b.E > 0 & b.I > 0);

xmax(L) = simplify(solve(dy == 0, x));
ymax(wo, L, E, I) = simplify(y(xmax));

setassum(old_assum, 'clear');
clear old_assum;