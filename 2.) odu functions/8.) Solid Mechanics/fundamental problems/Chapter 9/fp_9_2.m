%% mohr stresses
u = symunit;
sigmax = sym(0);
sigmay = -400*u.kPa;
tauxy = -300*u.kPa;
theta = -45*u.deg;

[sigmaxm sigmaym tauxym] = beam.mohr(sigmax, sigmay, tauxy, theta);
[sigmaxp sigmayp tauxyp thetap] = beam.principal(sigmax, sigmay, tauxy);
[sigmaxs sigmays tauxys thetas] = beam.max_shear(sigmax, sigmay, tauxy);
beam.mohr_plot(sigmax, sigmay, tauxy, {'kPa'});