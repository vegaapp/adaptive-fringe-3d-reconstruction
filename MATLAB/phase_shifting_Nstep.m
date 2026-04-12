function [Ax,Bx,Px] = phase_shifting_Nstep(I,Nstep)
% I(:,:,1) = I1
% I(:,:,2) = I2
% I(:,:,3) = I3 .......
% .....
% I(:,:,N) = IN
% Ax -> Luz de Fondo
% Bx -> Intensidad de Modulacion
% Px -> Fase de Modulacion
% I(x) = A(x) + B(x)cos[p(x) + step] + N(x)
% step = (0:Nstep-1)*2*pi/Nstep;
%   cos(A+B) = cos A cosB - Sin A SinB

delta = (0:Nstep-1)*2*pi/Nstep; % Phase shifts uniformly distributed [0,2*pi)
Ax = sum(I,3) / Nstep;

% Modulation light estimation
num = zeros( size(Ax) );
den = zeros( size(Ax) );
for k = 1:Nstep
    num = num + I(:,:,k)*sin( delta(k) );
    den = den + I(:,:,k)*cos( delta(k) );
end

Bx = (2/Nstep)*sqrt(num.^2 + den.^2) ;
Px = -atan2(num,den );

end

