%Project 1
r0=0.05; dr=r0/12; r=zeros(1,13);
r=10e-10:dr:0.05;r(13)=r0; i=1:1:13;
dt=1; t=0:dt:1911; n=2000; h=13.6; k=0.17;
alpha=1.28e-7;T=zeros(2000,13); T(1,1:13)=25; Ts=600;
lambda=alpha*dt/dr^2;

%@ i=1
n=2;rhs=zeros(13,13); lhs=zeros(13,1);
while n<=2000
rhs(1,1:2)=[(2*r(1)/lambda+dr/2) -r(1)];
rhs(2,1:3)=[-dr/2 (2*r(2)/lambda+2*dr) -3*dr/2];
rhs(3,2:4)=[-3*dr/2 (2*r(3)/lambda+4*dr) -5*dr/2];
i=4; j=5; m=6;l=7;
rhs(i,i-1:i+1)=[-j*dr/2 (2*r(i)/lambda+m*dr) -l*dr/2];
i=i+1; j=l; m=m+2; l=l+2;
rhs(i,i-1:i+1)=[-j*dr/2 (2*r(i)/lambda+m*dr) -l*dr/2];
i=i+1; j=l; m=m+2; l=l+2;
rhs(i,i-1:i+1)=[-j*dr/2 (2*r(i)/lambda+m*dr) -l*dr/2];
i=i+1; j=l; m=m+2; l=l+2;
rhs(i,i-1:i+1)=[-j*dr/2 (2*r(i)/lambda+m*dr) -l*dr/2];
i=i+1; j=l; m=m+2; l=l+2;
rhs(i,i-1:i+1)=[-j*dr/2 (2*r(i)/lambda+m*dr) -l*dr/2];
i=i+1; j=l; m=m+2; l=l+2;
rhs(i,i-1:i+1)=[-j*dr/2 (2*r(i)/lambda+m*dr) -l*dr/2];
i=i+1; j=l; m=m+2; l=l+2;
rhs(i,i-1:i+1)=[-j*dr/2 (2*r(i)/lambda+m*dr) -l*dr/2];
i=i+1; j=l; m=m+2; l=l+2;
rhs(i,i-1:i+1)=[-j*dr/2 (2*r(i)/lambda+m*dr) -l*dr/2];
i=i+1; j=l; m=m+2; l=l+2;
rhs(i,i-1:i+1)=[-j*dr/2 (2*r(i)/lambda+m*dr) -l*dr/2];
i=i+1; j=l; m=m+2; l=l+2;
rhs(i,i-1:i)=[(-j*dr/2-r0) (2*r0/lambda+m*dr+(2*h*dr*r0/k))];


lhs(1)=[(T(n-1,1)*(2*r(1)/lambda-dr/2)-(T(n-1,2)*r(1)))];
i=2; j=1; m=2; l=3;
lhs(i)=[(j*dr/2)*T(n-1,i-1)+(2*r(i)/lambda-m*dr)*T(n-1,i)+(l*dr/2)*T(n-1,i+1)];
i=i+1; j=l; m=m+2; l=l+2;
lhs(i)=[(j*dr/2)*T(n-1,i-1)+(2*r(i)/lambda-m*dr)*T(n-1,i)+(l*dr/2)*T(n-1,i+1)];
i=i+1; j=l; m=m+2; l=l+2;
lhs(i)=[(j*dr/2)*T(n-1,i-1)+(2*r(i)/lambda-m*dr)*T(n-1,i)+(l*dr/2)*T(n-1,i+1)];
i=i+1; j=l; m=m+2; l=l+2;
 lhs(i)=[(j*dr/2)*T(n-1,i-1)+(2*r(i)/lambda-m*dr)*T(n-1,i)+(l*dr/2)*T(n-1,i+1)];
i=i+1; j=l; m=m+2; l=l+2;
 lhs(i)=[(j*dr/2)*T(n-1,i-1)+(2*r(i)/lambda-m*dr)*T(n-1,i)+(l*dr/2)*T(n-1,i+1)];
i=i+1; j=l; m=m+2; l=l+2;
 lhs(i)=[(j*dr/2)*T(n-1,i-1)+(2*r(i)/lambda-m*dr)*T(n-1,i)+(l*dr/2)*T(n-1,i+1)];
i=i+1; j=l; m=m+2; l=l+2;
 lhs(i)=[(j*dr/2)*T(n-1,i-1)+(2*r(i)/lambda-m*dr)*T(n-1,i)+(l*dr/2)*T(n-1,i+1)];
i=i+1; j=l; m=m+2; l=l+2;
 lhs(i)=[(j*dr/2)*T(n-1,i-1)+(2*r(i)/lambda-m*dr)*T(n-1,i)+(l*dr/2)*T(n-1,i+1)];
i=i+1; j=l; m=m+2; l=l+2;
 lhs(i)=[(j*dr/2)*T(n-1,i-1)+(2*r(i)/lambda-m*dr)*T(n-1,i)+(l*dr/2)*T(n-1,i+1)];
i=i+1; j=l; m=m+2; l=l+2;
 lhs(i)=[(j*dr/2)*T(n-1,i-1)+(2*r(i)/lambda-m*dr)*T(n-1,i)+(l*dr/2)*T(n-1,i+1)];
i=i+1; j=l; m=m+2; l=l+2;
 lhs(i)=[(j*dr/2)*T(n-1,i-1)+(2*r(i)/lambda-m*dr)*T(n-1,i)+(l*dr/2)*T(n-1,i+1)];
i=i+1; j=l; m=m+2; l=l+2;
 lhs(i)=[(j*dr/2+r0)*T(n-1,i-1)+(2*r(i)/lambda-m*dr-2*h*dr*r0/m)*T(n-1,i)+(4*h*dr*r0/m)*Ts];

 x=(rhs\lhs)';
T(n,1:13)=x;
n=n+1;
end
    