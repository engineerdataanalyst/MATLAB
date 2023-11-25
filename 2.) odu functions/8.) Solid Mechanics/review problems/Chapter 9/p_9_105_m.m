%% beam
u = symunit;
x = sym('x');
E = sym('E');

old_assum = assumptions;
clearassum;

b = beam; %(N,mm)
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rb', 1000*u.mm);
b = b.add('applied', 'force', -50*u.N, 200*u.mm);
b = b.add('applied', 'force', -50*u.N, 400*u.mm);
b = b.add('applied', 'force', -40*u.N, 600*u.mm);
b = b.add('applied', 'force', -40*u.N, 800*u.mm);
b.L = 1000*u.mm;

%% section properties
B = 25*u.mm;
H = 100*u.mm;
b.I = B*H^3/12;
A = B*H;

%% elastic curve
[y(x,E) dy(x,E) m v w r] = b.elastic_curve(x, 'factor');

%% shear and moment diagram
beam.shear_moment(m, v, [0 1000], {'N' 'mm'});
subplot(2,1,1);
axis([0 1000 -115 125]);
subplot(2,1,2);
axis([0 1000 0 31500]);

%% loads at point C
M_C = m(300*u.mm);
V_C = v(300*u.mm);

%% stresses at point C
sigma_C = sym(0);
tau_C = rewrite(-3*V_C/(2*A), u.kPa);

%% mohr stresses at point C
sigmax = sigma_C;
sigmay = sym(0);
tauxy = tau_C;

[sigmaxp sigmayp tauxyp thetap] = beam.principal(sigmax, sigmay, tauxy);
[sigmaxs sigmays tauxys thetas] = beam.max_shear(sigmax, sigmay, tauxy);

%% mohr's circle
beam.mohr_plot(sigmax, sigmay, tauxy, {'kPa'});
axis([-30 30 -30 30]);
xvals = double(separateUnits([sigmaxp sigmaxs]));
yvals = double(separateUnits([tauxyp tauxys]));
thetavals = double(separateUnits([thetap thetas]));
hold on;
plot(xvals, yvals, 'o', 'MarkerFaceColor', 'r');
for k = 1:4
  switch k
    case 1
      x1 = 20;
      y1 = 0;
    case 2
      x1 = -20;
      y1 = 0;
    case 3
      x1 = xvals(3);
      y1 = -20;
    case 4
      x1 = xvals(4);
      y1 = 20;
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