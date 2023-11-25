%Project 1
N=13; %11 data points
r0=0.05; dr=r0/(N-1);
r=(10e-10:dr:0.05)'; r(N)=r0;
dt=1; limit=3; h=13.6; k=0.17;
alpha=1.28e-7; T=zeros(N,limit); T(1:N,1)=25; Ts=600;
lambda=alpha*dt/dr^2;

%@ i=1
n=2;rhs=zeros(N,N); lhs=zeros(N,1);
while n<=limit
rhs(1,1:2)=[(2*r(1)/lambda+dr/2) -r(1)];
j=1; m=2; l=3;
for i=2:N  
  if i==N
    rhs(i,i-1:i)=[(-j*dr/2-r0) (2*r0/lambda+m*dr+(2*h*dr*r0/k))];
  else
    rhs(i,i-1:i+1)=[-j*dr/2 (2*r(i)/lambda+m*dr) -l*dr/2];
  end
  j=j+2; m=m+2; l=l+2;  
end

lhs(1)=[(T(1,n-1)*(2*r(1)/lambda-dr/2)-(T(2,n-1)*r(1)))];
j=1; m=2; l=3;
for i=2:N  
  if i==N
    lhs(i)=[(j*dr/2+r0)*T(i-1,n-1)+(2*r(i)/lambda-m*dr-2*h*dr*r0/m)*T(i,n-1)+(4*h*dr*r0/m)*Ts];
  else
    lhs(i)=[(j*dr/2)*T(i-1,n-1)+(2*r(i)/lambda-m*dr)*T(i,n-1)+(l*dr/2)*T(i+1,n-1)];
  end
  j=j+2; m=m+2; l=l+2;
end

 x=(rhs\lhs)';
T(1:N,n)=x;
n=n+1;
end
    