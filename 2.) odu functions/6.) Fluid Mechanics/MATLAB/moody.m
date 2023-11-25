function val = moody(f, Re, eD)
  val = 1/f^0.5+2.0*log10(2.5/(Re*f^0.5)+eD/3.7); 