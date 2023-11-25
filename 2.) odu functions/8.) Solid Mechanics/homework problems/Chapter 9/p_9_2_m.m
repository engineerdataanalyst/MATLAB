%% mohr stresses
u = symunit;
sigmax = -5*u.ksi;
sigmay = 8*u.ksi;
tauxy = -2*u.ksi;
theta = 30*u.deg;

[sigmaxm sigmaym tauxym] = beam.mohr(sigmax, sigmay, tauxy, theta);
[sigmaxp sigmayp tauxyp thetap] = beam.principal(sigmax, sigmay, tauxy);
[sigmaxs sigmays tauxys thetas] = beam.max_shear(sigmax, sigmay, tauxy);
beam.mohr_plot(sigmax, sigmay, tauxy, {'ksi'});