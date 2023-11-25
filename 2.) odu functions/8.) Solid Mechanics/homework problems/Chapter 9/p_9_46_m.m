%% beam
u = symunit;
x = sym('x');
E = sym('E');

old_assum = assumptions;
clearassum;

b = beam; %(kip,ft)
b = b.add('reaction', 'force', 'R1', 0);
b = b.add('reaction', 'force', 'R2', 6*u.ft);
b = b.add('applied', 'force', -10*u.kip, 2*u.ft);
b = b.add('applied', 'force', -4*u.kip, 4*u.ft);
b.L = 6*u.ft;

%% section properties
yc = [3/2; 2/2; -2/2; -3/2]*u.in;
Ac = [6*3; -4*2; -4*2; 6*3]*u.in^2;
Ic = [6*3^3; -4*2^3; -4*2^3; 6*3^3]*u.in^4/12;

[yn Qn In] = beam.neutral_axis(yc, Ac, Ic);
b.I = rewrite(sum(In), u.ft);

%% elastic curve
[y(x,E) dy(x,E) m v w r] = b.elastic_curve(x, 'factor');

%% shear and moment diagrams
beam.shear_moment(m, v, [0 6], {'kip' 'ft'});
subplot(2,1,1);
axis([0 6 -8 10]);
subplot(2,1,2);
axis([0 6 0 18]);

%% loads at point B
M_B = m(3.5*u.ft);
V_B = v(3.5*u.ft);

%% stresses at point B
b.I = rewrite(b.I, u.in);
sigma_B = sym(0);

Q_B = sum(Qn(1:2));
t_B = 2*u.in;
tau_B = rewrite(-V_B*Q_B/(b.I*t_B), u.psi);

%% mohr stresses at point B
sigmax = sym(0);
sigmay = sym(0);
tauxy = tau_B;

[sigmaxp sigmayp tauxyp thetap] = beam.principal(sigmax, sigmay, tauxy);
[sigmaxs sigmays tauxys thetas] = beam.max_shear(sigmax, sigmay, tauxy);

%% mohr's circle
beam.mohr_plot(sigmax, sigmay, tauxy, {'psi'});
axis([-255 255 -255 255])
xvals = double(separateUnits([sigmaxp sigmaxs]));
yvals = double(separateUnits([tauxyp tauxys]));
thetavals = double(separateUnits([thetap thetas]));
hold on;
plot(xvals, yvals, 'o', 'MarkerFaceColor', 'r');
for k = 1:4
  switch k
    case 1
      x1 = 150;
      y1 = 0;
    case 2
      x1 = -150;
      y1 = 0;
    case 3
      x1 = xvals(3);
      y1 = 150;
    case 4
      x1 = xvals(4);
      y1 = -150;
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