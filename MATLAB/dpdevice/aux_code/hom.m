function y = hom(x,s)
% Homogeneous Coordinate Operator (scale s)
% 
% Syntax:
%   y = hom(x)    Homogeneous coordinates of x (s = 1 is assumed).
%   y = hom(x,s)  Homogeneous coordinates of x with scale s.
% 
% See also: ihom
% 
    
    if nargin < 2
        s = 1;
    end
    
    if numel(s) == 1
        y = [ x
              s*ones(1,size(x,2)) ];
    else
        y = [ x
              s(:)' ];
    end
end
