% mach numbers and pressures
M2 = 3.8119;
M3 = 2.2896;
p2p1 = 1.6555;
p3p1 = 7.5555;
p2 = 165.5546; %kPa
p3 = 755.5537; %kPa

% turning angles
phi_12 = 5;
phi_13 = 25;

% equations
g = 1.4;
pp2 = @(theta_24) (2*g*M2^2*sind(theta_24)^2-g+1)/(g+1);
pp3 = @(theta_35) (2*g*M3^2*sind(theta_35)^2-g+1)/(g+1);

% solve for p
error = 10;
tol = 0.02;
inc = 0.1;
p = 1050; %kPa
k = 1;
while error > tol
  % upper shock  
  theta_24 = fzero(@(x)p/p2-pp2(x), [asind(1/M2) 66]);
  num = cotd(theta_24)*(M2^2*sind(theta_24)^2-1);
  den = (g+1)/2*M2^2-M2^2*sind(theta_24)^2+1;
  phi_24 = atand(num/den);
  alpha_upper = phi_24-phi_12;
  % lower shock  
  theta_35 = fzero(@(x)p/p3-pp3(x), [asind(1/M3) 66]); 
  num = cotd(theta_35)*(M3^2*sind(theta_35)^2-1);
  den = (g+1)/2*M3^2-M3^2*sind(theta_35)^2+1;
  phi_35 = atand(num/den);
  alpha_lower = phi_13-phi_35;
  % tabulation 
  error = abs(alpha_upper-alpha_lower);  
  data(k).p = p;
  data(k).theta_24 = theta_24;
  data(k).theta_35 = theta_35;
  data(k).phi_24 = phi_24;
  data(k).phi_35 = phi_35;
  data(k).alpha_upper = alpha_upper;
  data(k).alpha_lower = alpha_lower;
  data(k).error = error;
  if error > tol
    p = p+inc;
    k = k+1;
  end
end
data = struct2table(data);
writetable(data, 'prob1.xlsx');
