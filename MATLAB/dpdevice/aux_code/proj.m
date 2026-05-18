function B = proj(M,A,d,s)
% PROJ implements the Projection Operator of the
% points A to points B by the matrix M as
%   B = ihom( M*hom(A) )    d = 'dir' (default)
%   B = ihom( M\hom(A) )    d = 'inv'
%
% Written by R. Juarez-Salazar.
%
% Syntax:
%   B = proj(M,A)
%   B = proj(M,A,d)
%   B = proj(M,A,d,s)
%
% d = 'dir' (default) if it is not given or empty.
% d = 'inv' Inverse projection.
% s = 1     (default) if it is not given or empty.
%
%See also: hom, ihom, Gme, Gme_dist
%
    
    if nargin < 4
        s = 1;
        if nargin < 3
            d = 'dir';
        end
    end
    if isempty(d); d = 'dir' ; end
    if isempty(s); s = 1     ; end
    
    % Flattening
    MNK = size(A);
    if numel(MNK) > 2
        F = cflat(A);
    else
        F = A;
    end
    
    % Projective transformation
    if strcmp(d,'inv')
        P = ihom( M\hom(F,s), s );
    else
        P = ihom( M*hom(F,s), s );
    end
    
    % De-flattening
    if numel(MNK) > 2
        B = cflat(P,MNK);
    else
        B = P;
    end
end
