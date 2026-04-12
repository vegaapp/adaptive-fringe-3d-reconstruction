function St = FuncionSaturacion(rejilla, Ax,Bx,Ay,By)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
Lk=[3,2,1,0.5];  % factor de correcion.

   Ax1 = Ax/255;
   Bx1 = Bx/255;
   Sx = Lk(rejilla)*((Ax1 .*(1-Bx1)).^3);
   Ay1 = Ay/255;
   By1 = By/255;
   Sy = Lk(rejilla)*((Ay1 .*(1-By1)).^3);
   St = (Sx + Sy)/2;

end