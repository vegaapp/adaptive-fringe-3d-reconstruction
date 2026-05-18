clear;clc

% This software can be used freely for academic purposes by citing
% appropriately the two reference papers listed below.
% 
% [1] Rigoberto Juarez-Salazar, Juan Zheng, and Victor H. Diaz-Ramirez,
% “Distorted pinhole camera modeling and calibration,” Applied Optics,
% Vol. 59, Issue 36, pp. 11310-11318 (December 2020).
% DOI: https://doi.org/10.1364/AO.412159
% 
% [2] Rigoberto Juarez-Salazar and Victor H. Diaz-Ramirez, "Distorted
% pinhole camera model for tangential distortion," Proceedings of SPIE,
% Vol. 11841, pp. 118410D, (August 2021).
% DOI: https://doi.org/10.1117/12.2594860


%% Distorted pinhole camera
pars.DT = 'pin';
pars.K  = eye(3);
pars.d  = [0.6, 0.1];
pars.g  = [2, -3, -1];
pars.R  = rmat([pi, pi, 0]);
pars.t  = [0, 0, 1]';
cam = dpdev(pars);

%% Input images
I1 = imread('cameraman.tif');
I2 = imread('circuit.tif');
I3 = imread('peppers.png');
I4 = imread('gantrycrane.png');

%% Image point coordinates
x1 = linspace(-1, 1, size(I1,2) );
y1 = linspace(-1, 1, size(I1,1) );
[X1,Y1] = meshgrid( x1, y1 );

x2 = linspace(-1, 1, size(I2,2) );
y2 = linspace(-1, 1, size(I2,1) );
[X2,Y2] = meshgrid( x2, y2 );

x3 = linspace(-1, 1, size(I3,2) );
y3 = linspace(-1, 1, size(I3,1) );
[X3,Y3] = meshgrid( x3, y3 );

x4 = linspace(-1, 1, size(I4,2) );
y4 = linspace(-1, 1, size(I4,1) );
[X4,Y4] = meshgrid( x4, y4 );

%% Re-projected image point coordinates
ref = cam.dev2rsp( [X1(:), Y1(:)]');
M1  = reshape( ref(1,:), size(X1) );
N1  = reshape( ref(2,:), size(X1) );

ref = cam.dev2rsp( [X2(:), Y2(:)]');
M2  = reshape( ref(1,:), size(X2) );
N2  = reshape( ref(2,:), size(X2) );

ref = cam.dev2rsp( [X3(:), Y3(:)]');
M3  = reshape( ref(1,:), size(X3) );
N3  = reshape( ref(2,:), size(X3) );

ref = cam.dev2rsp( [X4(:), Y4(:)]');
M4  = reshape( ref(1,:), size(X4) );
N4  = reshape( ref(2,:), size(X4) );

%% Plot input images
subplot(2,4,1); imagesc(x1,y1,I1); daspect([1,1,1])
subplot(2,4,2); imagesc(x2,y2,I2); daspect([1,1,1])
subplot(2,4,3); imagesc(x3,y3,I3); daspect([1,1,1])
subplot(2,4,4); imagesc(x4,y4,I4); daspect([1,1,1])
colormap gray

%% Plot re-projected images
subplot(2,4,5); surf( M1, N1, zeros(size(M1)), I1, 'EdgeColor', 'None')
daspect( [1,1,1] ); view(2)

subplot(2,4,6); surf( M2, N2, zeros(size(M2)), I2, 'EdgeColor', 'None')
daspect( [1,1,1] ); view(2)

subplot(2,4,7); surf( M3, N3, zeros(size(M3)), I3, 'EdgeColor', 'None')
daspect( [1,1,1] ); view(2)

subplot(2,4,8); surf( M4, N4, zeros(size(M4)), I4, 'EdgeColor', 'None')
daspect( [1,1,1] ); view(2)
