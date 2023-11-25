function [v]=Tridiag(a,b,c,d) 
%Routine to solve a tri-diagonal matrix equation with a b c as lower 
% main and upper diagonals and d as load vector 
n=length(b); 
%Eliminate lower diagonal 
c(1)=c(1)/b(1); 
d(1)=d(1)/b(1); 
for i=2:n 
  denom=1/(b(i)-a(i).*c(i-1)); 
  c(i)=c(i)*denom; 
  d(i)=(d(i)-a(i).*d(i-1))*denom; 
end 
%Backsubstitute 
v(n)=d(n); 
for i=n-1:-1:1 
  v(i)=d(i)-c(i).*v(i+1); 
end 