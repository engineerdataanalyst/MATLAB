%% mohr stresses
u = symunit;
sigmax = 500*u.kPa;
sigmay = sym(0);
tauxy = sym(0);
theta = (90+30)*u.deg;

[sigmaxm sigmaym tauxym] = beam.mohr(sigmax, sigmay, tauxy, theta);
[sigmaxp sigmayp tauxyp thetap] = beam.principal(sigmax, sigmay, tauxy);
[sigmaxs sigmays tauxys thetas] = beam.max_shear(sigmax, sigmay, tauxy);
beam.mohr_plot(sigmax, sigmay, tauxy, {'kPa'});