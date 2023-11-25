%Project 1
N=11; %11 data points
r0=0.05; dr=r0/(N-1); r=zeros(1,N);
r=10e-10:dr:0.05;r(N)=r0; i=1:1:N;
dt=1; t=0:dt:1911; limit=3; h=13.6; k=0.17;
alpha=1.28e-7;T=zeros(limit,N); T(1,1:N)=25; Ts=600;
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

lhs(1)=[(T(n-1,1)*(2*r(1)/lambda-dr/2)-(T(n-1,2)*r(1)))];
j=1; m=2; l=3;
for i=2:N  
  if i==N
    lhs(i)=[(j*dr/2+r0)*T(n-1,i-1)+(2*r(i)/lambda-m*dr-2*h*dr*r0/m)*T(n-1,i)+(4*h*dr*r0/m)*Ts];
  else
    lhs(i)=[(j*dr/2)*T(n-1,i-1)+(2*r(i)/lambda-m*dr)*T(n-1,i)+(l*dr/2)*T(n-1,i+1)];
  end
  j=j+2; m=m+2; l=l+2;
end

 x=(rhs\lhs)';
T(n,1:N)=x;
n=n+1;
end
    