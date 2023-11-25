%% beam
u = symunit;
x = sym('x');
E = sym('E');
I = sym('I');

old_assum = assumptions;
clearassum;
args = {'mode' 'factor'};
wf1 = findpoly(1, 'thru', [0 0], [8*u.ft -250*u.lbf/u.ft], args{:});
wf2 = findpoly(1, 'thru', [8*u.ft -250*u.lbf/u.ft], ...
                          [13*u.ft -400*u.lbf/u.ft], args{:});

b = beam; %(lbf,ft)
b = b.add('reaction', 'force', 'Ra', 13*u.ft);
b = b.add('reaction', 'moment', 'Ma', 13*u.ft);
b = b.add('applied', 'force', -3000*u.lbf, 8*u.ft);
b = b.add('applied', 'force', 15000*u.lbf, 10*u.ft);
b = b.add('distributed', 'force', wf1, [0 8]*u.ft);
b = b.add('distributed', 'force', wf2, [8 13]*u.ft, [false true]);
b.L = 13*u.ft;

%% elastic curve
[y(x,E,I) dy(x,E,I) m v w r] = b.elastic_curve(x, 'factor');

%% shear and moment diagram
beam.shear_moment(m, v, [0 13], {'lbf' 'ft'});
subplot(2,1,1);
axis([0 13 -6500 12500]);
subplot(2,1,2);
axis([0 13 -14000 22000]);

%% clean up
setassum(old_assum);
clear args old_assum;