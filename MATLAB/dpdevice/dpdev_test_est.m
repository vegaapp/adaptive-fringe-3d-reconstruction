clear; clc; close all

addpath("aux_code\")

fpath = "fisheye\cb_";
load( fpath + "pts.mat" )
n = size( imagePoints, 3);

% Test image
I0 = imread( fpath + "1.jpg" );

% Image size
MN = [size(I0,1), size(I0,2)];

% Normalization matrix
[~,~,x,y,Kn] = gcoord( MN );

% Reference checkerboard points
rs =  9.2;              % Square size (millimeters)
rx =  rs * (-4.0:4.0);  % x-axis checkerboard points
ry = -rs * (-2.5:2.5);  % y-axis checkerboard points
[Rx, Ry] = meshgrid( rx, ry );
rho = [Rx(:), Ry(:)]';

% Image checkerboard points
dec = 1;
pxl = nan( 2, size(imagePoints,1), n );
subplot(3,3,1); colormap gray
for k = 1:n
    
    I0 = imread( fpath + num2str(k) + ".jpg" );
    pxl(:,:,k) = proj( Kn, imagePoints(:,:,k)' );
    
    imagesc(x, y, I0); title( "Image " + num2str(k) )
    hold on
        plot( pxl(1,:,k), pxl(2,:,k), 'or' )
    hold off
    drawnow
end


%% Calibration

h = subplot(3,3,4); title("Reprojection Error")
% h = figure(1);
cdev = dpdev.estimate(rho, pxl, MN, h);

disp("K0 = ");      disp( cdev.K          )
disp("Rh(end) = "); disp( cdev.R(:,:,end) )
disp("th(end) = "); disp( cdev.t(:,  end) )



%% Illustrating the calibrated device

idx = 17; % Select a checkerboard image

ROI = [-60, 60, 800
       -50, 50, 600];

I0 = imread( fpath + num2str(idx) + ".jpg" );
[J0,u,v] = cdev.imgtransf( {'proj', idx}, I0, [], [], ROI);

subplot(3,3,1); imagesc(x,y,I0)
title( "Input Image " + num2str(idx) )

subplot(3,3,7); imagesc(u,v,J0)
title( "Output Image " + num2str(idx) )
set(gca,"YDir","normal")

%%
subplot(1,3,2:3)
cdev.draw({'proj',idx},[],I0,[],[],20)
axis([-60, 60,-50,50])
axis off

