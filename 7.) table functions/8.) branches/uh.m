function val = uh(x)
  % ------------------------
  % - the unit step function
  %   in heaviside form
  % ------------------------
  arguments
    x {mustBeA(x, ["numeric" "sym"])};
  end  
  val = 2*heaviside(x)^2-heaviside(x);
