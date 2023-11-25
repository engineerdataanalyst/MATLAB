%% Analytical Solution
% given
Ti = 40; %(F)
Tinf = 350; %(F)
Tf = 165; %(F)
thetaf = (Tf-Tinf)/(Ti-Tinf); %dimensionless temperature
h = 12.5; %Btu/hr-ft^2-F
k = 0.287; %Btu/hr-ft-F
alpha = 1.40e-6; %ft^2/s
r0 = 0.331; %ft

Bi = h*r0/k;
dr = r0/10; %ft

% lambda values
fb = @(x) 1-x.*cot(x)-Bi;
lambda = zeros(6,1);
lambda(1) = fzero(fb, [2.6 3]);
lambda(2) = fzero(fb, [3 3.2]);
lambda(3) = fzero(fb, [5.7 6]);
lambda(4) = fzero(fb, [6 6.4]);
lambda(5) = fzero(fb, [8.8 9]);
lambda(6) = fzero(fb, [9 9.5]);

% series solution
a = 4*(sin(lambda)-lambda.*cos(lambda))./(2*lambda-sin(2*lambda));
fth1 = @(x) a(1)*exp(-lambda(1)^2*x)-thetaf;
fth2 = @(x) fth1(x)+a(2)*exp(-lambda(2)^2*x);
fth3 = @(x) fth2(x)+a(3)*exp(-lambda(3)^2*x);
fth4 = @(x) fth3(x)+a(4)*exp(-lambda(4)^2*x);
fth5 = @(x) fth4(x)+a(5)*exp(-lambda(5)^2*x);
fth6 = @(x) fth5(x)+a(6)*exp(-lambda(5)^2*x);

% Fourier Numbers
tau = zeros(6,1);
tau(1) = fzero(fth1, 0.1);
tau(2) = fzero(fth2, 0.1);
tau(3) = fzero(fth3, 0.1);
tau(4) = fzero(fth4, 0.1);
tau(5) = fzero(fth5, 0.1);
tau(6) = fzero(fth6, 0.1);

% time values
time = tau*r0^2/alpha;

% plot
r = linspace(0, r0);
t = [time(5) time(5)-1000 time(5)-2000 time(5)-3000];
for j = 1:4
  Fo = alpha*t(j)/r0^2;
  theta = zeros(size(r));
  for k = 1:6
    theta = theta+a(k)*exp(-lambda(k)^2*Fo)*sin(lambda(k)*r/r0)./(lambda(k)*r/r0);
  end    
  T = Tinf+(Ti-Tinf)*theta;
  hold on;
  switch j
    case 1
      line = '-b';      
    case 2
      line = '-r';
    case 3
      line = '-m';
    case 4
      line = '-g';
  end
  plot(r, T, line);
end
plot(r, T0);
str = sprintf('cooking time: %.3f hours', time(5)/3600);
title({'Analytical Solution', str});
xlabel('r (m)');
ylabel('T (F)');
legend({sprintf('time: %.3f hours', t(1)/3600)
        sprintf('time: %.3f hours', t(2)/3600)
        sprintf('time: %.3f hours', t(3)/3600)
        sprintf('time: %.3f hours', t(4)/3600)});

%% Crank Nicolson Method (sample)
% Given: 
% r_0=0.331; %(ft) 
% k=0.287; %Btu/hr-ft-F
% alpha=1.40e-6; %ft^2/s  
% T0=40; %(F) 
% Tinf=350; %(F)
% h=12.5; %Btu/hr-ft^2-F
% Tsur=165; %(F)
% int=10000; 
%   
% dr=r_0/10; 
% dt=0.05; 
% lamda=(alpha*dt)/(dr^2); 
% tetas=(Tsur-Tinf)/(T0-Tinf); 
%   
% n=10; 
% T=ones(n+1,int); 
% r=ones(n+1,1); 
% for i=1:11 
%     r(i)=dr*(i-1); 
% end 
%   
% r(1)=eps; 
% T(1:n+1,1)=T0; %B.C. 
% r32=r(1)+(.5*1*dr); 
% r52=r(1)+(.5*3*dr); 
% r72=r(1)+(.5*5*dr); 
% r92=r(1)+(.5*7*dr); 
% r112=r(1)+(.5*9*dr); 
% r132=r(1)+(.5*11*dr); 
% r152=r(1)+(.5*13*dr); 
% r172=r(1)+(.5*15*dr); 
% r192=r(1)+(.5*17*dr); 
% r212=r(1)+(.5*19*dr); 
% r232=r(1)+(.5*21*dr); 
% r252=r(1)+(.5*23*dr); 
%   
% %Creating the a vector 
% a=-((lamda/2).*((r-(dr/2))./r)).*diag(eye(n+1)); 
% a(n+1)=-(lamda/2)*((r(n+1)-dr/2)/r(n+1))-(lamda/2); 
%   
% % Creating the b vector 
% b=(1+lamda)*diag(eye(n+1)); 
% b(1)=1+(lamda/2)*((r32+r(1))/r(1)); 
% b(n+1)=1+(lamda/2)*((r(n+1)+r252)/r(n+1))+(lamda*h*dr)/k; 
%   
% % Creating the c vector      
% c=-((lamda/2).*((r+(dr/2))./r)).*diag(eye(n+1)); 
% c(1)=-(lamda/2)*(1+r32/r(1)); 
%   
% for i=1:int 
%     
%     if T(11,i)>=Tsur 
%         ifin=i-1; 
%         timefinal=ifin*dt; 
%         break 
%     end 
%   
% % Creating the d vector    
%     d(1)=(lamda/2)*T(2,i)+... 
%         (1-(lamda/2)*(r(1)+r32)/r(1))*T(1,i)+... 
%         ((lamda/2)*(r32/r(1)))*T(2,i); 
%     for j=2:n 
%         d(j)=-a(j)*T(j-1,i)+((1-lamda)*T(j,i))-c(j)*T(j+1,i);  
%     end 
%     d(n+1)=(lamda/2)*((r252/r(n+1))+1)*T(n,i)... 
%         +(1-(lamda/2)*((r252+r(n+1))/r(n+1))-(lamda*h*dr)/k)*T(n+1,i)... 
%         +(2*lamda*h*dr*Tinf)/k; 
%         
%     
% t=Tridiag(a,b,c,d); 
% T(:,i+1)=t; 
%   
% end
% 
% %plot
% plot(r, t, 'o');