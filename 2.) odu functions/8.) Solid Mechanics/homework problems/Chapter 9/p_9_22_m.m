%% beam
u = symunit;
x = sym('x');
E = sym('E');

old_assum = assumptions;
clearassum;

b = beam;
b = b.add('reaction', 'force', 'R', 1.5*u.m);
b = b.add('reaction', 'moment', 'M', 1.5*u.m);
b = b.add('distributed', 'force', -100*u.kN/u.m, [0 1.5]*u.m);
b.L = 1.5*u.m;

%% section properties
yc = [75/2; 75+(200-75)/2; 200+20/2]*u.mm;
Ac = [20*75; 20*(200-75); 200*20]*u.mm^2;
Ic = [20*75^3; 20*(200-75)^3; 200*20^3]*u.mm^4/12;

[yn Qn In] = beam.neutral_axis(yc, Ac, Ic);
b.I = rewrite(sum(In), u.m);

%% elastic curve
[y(x,E) dy(x,E) m v w r] = b.elastic_curve(x, 'factor');

%% shear and moment diagram
beam.shear_moment(m, v, [0 1.5], {'kN' 'm'});
subplot(2,1,1);
axis([0 1.5 -170 15]);
subplot(2,1,2);
axis([0 1.5 -125 15]);

%% loads at point A
M_A = m(u.m);
V_A = v(u.m);

%% stresses at point A
y_A = 75*u.mm-yn;
b.I = rewrite(b.I, u.m);
sigma_A = rewrite(-M_A*y_A/b.I, u.MPa);

Q_A = abs(Qn(1));
t_A = 20*u.mm;
tau_A = rewrite(-V_A*Q_A/(b.I*t_A), u.MPa);

%% mohr stresses at point A
sigmax = sigma_A;
sigmay = sym(0);
tauxy = tau_A;

[sigmaxp sigmayp tauxyp thetap] = beam.principal(sigmax, sigmay, tauxy);
[sigmaxs sigmays tauxys thetas] = beam.max_shear(sigmax, sigmay, tauxy);

%% mohr's circle
beam.mohr_plot(sigmax, sigmay, tauxy, {'MPa'});
axis([-120 15 -65 65]);
xvals = double(separateUnits([sigmaxp sigmaxs]));
yvals = double(separateUnits([tauxyp tauxys]));
thetavals = double(separateUnits([thetap thetas]));
hold on;
plot(xvals, yvals, 'o', 'MarkerFaceColor', 'r');
for k = 1:4
  switch k
    case 1
      x1 = -100;
      y1 = 0;
    case 2
      x1 = -20;
      y1 = 0;
    case 3
      x1 = xvals(3);
      y1 = 40;
    case 4
      x1 = xvals(4);
      y1 = -40;
  end
  [x1 y1] = ds2nfu(x1, y1);
  [x2 y2] = ds2nfu(xvals(k), yvals(k));
  text_str = {['(' num2str(xvals(k)) ', ' num2str(yvals(k)) ')']
              [num2str(thetavals(k)) ' deg']};
  annotation('textarrow', [x1 x2], [y1 y2], 'String', text_str);
end

%% clean up
setassum(old_assum);
clear old_assum;
clear xvals yvals thetavals k x1 y1 x2 y2 text_str;