function x = ihom(y,s)
% Inverse Homogeneous Coordinate Operator (scale s)
% 
% Syntax:
%   y = ihom(x)    Homogeneous coordinates of x (s = 1 is assumed).
%   y = ihom(x,s)  Homogeneous coordinates of x with scale s.
% 
% See also: hom
% 

    if size(y,1) < 2
        disp('Error: "y" must to have at least two rows')
    else
        if nargin < 2
            s = 1;
        end
        
        x0 = y(1:end-1,:);
        if s == 0
            x = x0;
        else
            x = s*x0 ./ ...
                repmat( y(end,:), size(x0,1), 1 );
        end
    end
end
