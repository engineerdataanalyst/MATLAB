function Ge = Gef(G, H)
% --------------------------------------------------
% -given G & H for a non unity feedback
% system, returns equivalent forward path 
% transfer corresponding to a unity feedback system.
% -input arguments:
% G: forward path transfer function
% H: feedback transfer function
% -output arguments:
% G(s): open loop transfer function
% T(s): closed loop transfer function.
% --------------------------------------------------
Ge = minreal(G/(1+G*(H-1)));