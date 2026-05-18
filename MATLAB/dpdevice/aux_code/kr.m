function [K,R,Rx,Ry,Rz] = kr(G)
% KR performs a "QR"-like decomposition of
% the form
%       G = K*R
% where K is a upper-triangular matrix while
% R is an orthogonal matrix. This function
% follows the QR decomposition algorithm by
% successive application of Givens rotations.
%
% Written by R. Juarez-Salazar
%
% Syntax:
%   [K,R,Rx,Ry,Rz] = kr(G)
%
% Inputs(1)
% (i1) = G is a 3x3 matrix.
%
% Outputs(5)
% (o1) K is a 3x3 upper triangular matrix.
%
% (o2) R is a 3x3 orthogonal matrix.
%
% (o3-o5) Rx, Ry, Rz are 3x3 Givens rotation matrices
%       such that R = Rz'*Ry'*Rx'.
%
% See Also:
% Kme
%
    
    Rx = aux_givens(G,       'x');
    Ry = aux_givens(G*Rx,    'y');
    Rz = aux_givens(G*Rx*Ry, 'z');
    
    R = (Rx*Ry*Rz)';
    K = G*R';

    K( [2,3,6] ) = 0;
end

function Ri = aux_givens(Gi,sel)
% Auxiliar function to obtain a Givens rotation

    switch sel
        case 'x'
            cs = [Gi(3,3), -Gi(3,2)];
            cs = cs/norm(cs);
            Ri = [1, 0, 0; 0, cs(1), -cs(2); 0, cs(2), cs(1)];
        case 'y'
            cs = [Gi(3,3),  Gi(3,1)];
            cs = cs/norm(cs);
            Ri = [cs(1), 0, cs(2); 0, 1, 0; -cs(2), 0, cs(1)];
        case 'z'
            cs = [Gi(2,2), -Gi(2,1)];
            cs = cs/norm(cs);
            Ri = [cs(1), -cs(2), 0; cs(2), cs(1), 0; 0, 0, 1];
    end
end
