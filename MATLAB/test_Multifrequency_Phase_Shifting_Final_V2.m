%% Gratings
clear all;
close all;
 clc;
% setup Librerias creacion de rejilla obj de calibracion
addpath("D:\FABIO\Doctorado\Pasantia\MATLAB\dpdevice");
addpath("D:\FABIO\Doctorado\Pasantia\MATLAB\dpdevice\aux_code");
addpath("D:\FABIO\Doctorado\Pasantia\MATLAB");


% ----------- setup  procesado fases
% RutaImg="D:\FABIO\Doctorado\Pasantia\MATLAB\adq-13-sep-tnegra\objme";
% filename="fp_";
% RutaFilesfull = 'D:\FABIO\Doctorado\Pasantia\MATLAB\adq-13-sep-tnegra\objmefp_';
% 
% load("D:\FABIO\Doctorado\Pasantia\MATLAB\adq-13-sep-tnegra\cal\cp_params.mat");
% load("D:\FABIO\Doctorado\Pasantia\MATLAB\adq-13-sep-tnegra\cal\fase_multi.mat");

%RutaImg="D:\FABIO\Doctorado\Pasantia\MATLAB\adq-12-sep-tnegra\objNormal";
RutaImg="D:\FABIO\Doctorado\Pasantia\MATLAB\adq-10-sep-tnegra\obj-normal";


filename="fp_";
%RutaFilesfull = 'D:\FABIO\Doctorado\Pasantia\MATLAB\adq-26-AGO\objmetal\fp_';

load("D:\FABIO\Doctorado\Pasantia\MATLAB\adq-12-sep-tnegra\cal\fase_multi.mat");
load("D:\FABIO\Doctorado\Pasantia\MATLAB\adq-12-sep-tnegra\cal\cp_params.mat");

%------------ creo objteos para aquellos que no tienen objteo dpc, dpp
% dpc.R =Rc ; % Matriz rotacion Camara
% dpp.R= Rp ; % Matriz rotacion proyector
% dpc.t = tc ; % vector traslacion Camara
% dpp.t = tp ; % vector traslacion proyector
% dpc.K = Kc ; % Parametros Instrinsecos de la camara
% dpp.K = Kp ; % Parametros Instrinsecos del proyector.

% no se carga multiplicador de frecuencia ya que el generador de rejilla lo tiene.

Npasos = 6;
Nrejillas = 4; 
offsetImg_y= (Npasos*Nrejillas); % inicio de franjas en Y
MNc = [2076, 3088]; % resolucion de la camara MNc = [y,x];
%MNp  = [1080, 1920]; % Mini-projector KODAK size
MNp = [ 737, 1280]; % Projector Resolution  Libro

if size(alpx,2) < Nrejillas 
alpx = [1,alpx]; % agrego frecuencia 1 a multiplicacode de frecuencias
alpy = [1,alpy]; % agrego frecuencia 1 a multiplicacode de frecuencias
end

for i=1:Nrejillas

   % Paso 2) Extraigo Fase para Reconstruccion y Correccion
   disp(strcat('rejilla:',num2str(i),' Paso 2 Extraigo Fase'));
   %-------------------------------- procesa franjas x
   offset=(i-1)*Npasos;  
   Ix = Load_images(RutaImg,filename,offset,Npasos,".jpg");
   [Ax,Bx,Pex] = phase_shifting_Nstep(Ix,Npasos);
   pro_x =prod(alpx(1:i)) ; % productorio en pro_x = alpx(1)*alpx(2)*alpx(3);
   if (i==1)
       Pdx = Pex;   % con f <=1 ,  Pdx = Pex
   else        
       Pdx = UnwrapMultifrecuence(Pex,Pdx,alpx(i));       
   end   
   
   %-------------------------------- franjas y
   Iy = Load_images(RutaImg,filename,offsetImg_y+offset,Npasos,".jpg");
   [Ay,By,Pey] = phase_shifting_Nstep(Iy,Npasos);  
   pro_y =prod(alpy(1:i)) ; % productorio en pro_y = alpy(1)*alpy(2)*alpy(3);
   if (i==1)
       Pdy = Pey;
   else
       Pdy = UnwrapMultifrecuence(Pey,Pdy,alpy(i)); 
   end
   %-------------------------
   return
     
end


 disp(' Paso 5 Reconstruyo Objeto y Muestro');
%Vcrop=[50,2022,1343,2338]; %BB8
 Vcrop=[110,1954,1183,2203]; %Metal Vcrop=[110,1954,1435,1975]; 
[Totalpoint,Totalresolve,Porcentaje] =ReconstruyeObjeto(RutaImg,filename,dpc,dpp,MNp,Npasos,Ix,Bx,Pdx,pro_x,Pdy,pro_y,i);
    dat = sprintf('Ref_24, 3D Obj Ite.%d Np=%d Tpoint =%d %0.2f%% T.resolve =%d  ',i, Npasos,Totalpoint,Porcentaje,Totalresolve);
   title(dat);


   %%  Test Remove artifact
% az = 0.9;
% el = 90;
% view(az,el);
% pause(0.2);
% saveas(gcf,strcat(RutaImg,"objCrop.fig"));


%  resta superficies

p_m = size(dpc.R,3); % ultima posicion

Rc =dpc.R(:,:,p_m);  % Matriz rotacion Camara
Rp = dpp.R(:,:,p_m);% Matriz rotacion proyector
tc = dpc.t(:,p_m); % vector traslacion Camara
tp = dpp.t(:,p_m); % vector traslacion proyector

Kc = dpc.K; % Parametros Instrinsecos de la camara
Kp = dpp.K; % Parametros Instrinsecos del proyector.
% hacemos forma automatica
sumImg = Load_imageFondo(RutaImg,filename,0,Npasos,".jpg");
[Px,Py,Pz] = PhaseToPointXYZ(Pdx,pro_x,Pdy,pro_y,MNp,Bx,Rc,Rp,Kc,Kp, tc,tp );

Pz = Pz(Vcrop(1):Vcrop(2),Vcrop(3):Vcrop(4));
Zref = Pz1(Vcrop(1):Vcrop(2),Vcrop(3):Vcrop(4));

Zerr = abs(Zref-Pz);
msk = ~isnan(Zerr);
med = mean(Zerr(msk));
dev = std(Zerr(msk));
dat = sprintf('Ref_24,3D Obj Np=%d Error Mean= %0.4f std= %0.4f   ', Npasos,med,dev);


fig=figure(2);
Px = Px(Vcrop(1):Vcrop(2),Vcrop(3):Vcrop(4));
Py = Py(Vcrop(1):Vcrop(2),Vcrop(3):Vcrop(4));
 surf( Px(1:2:end, 1:10:end), ...
      Py(1:2:end, 1:10:end), ...
      Zerr(1:2:end, 1:10:end), ...
      'EdgeColor','None')
colormap lines;
title(dat);
saveas(fig,strcat(RutaImg,"error.fig"));
return;
%%  Visualizacion datos


figure(1);
imagesc(Ax);
colormap gray;
axis off

St = (Ax+Ay)/2;
St1 = St>=250;
figure(2);
imagesc(St1);
colormap gray;
axis off

figure(3);
imagesc(Bx);
colormap gray;
axis off

Bx1 = Bx/max(max(Bx));
St2 = Bx1 > 0.5;
figure(4);
imagesc(St2);
colormap gray;
axis off




%%  
i =4;
Npasos = 6;
Nrejillas = 4;
offset=(i-1)*Npasos;  
offsetImg_y= (Npasos*Nrejillas); % inicio de franjas en Y

RutaImg="D:\FABIO\Doctorado\Pasantia\MATLAB\adq-13-sep-tnegra\objNormal\";
filename="fp_";
RutaFilesfull = 'D:\FABIO\Doctorado\Pasantia\MATLAB\adq-13-sep-tnegra\objNormal\fp_';
sumImg = Load_imageFondo(RutaImg,filename,offset,Npasos,".jpg");

figure(2)
imshow(sumImg);

%%  gama ejemplo
GammaX = Bx ./ Ax;
MaskX = imbinarize(GammaX); % por segmentacion 
MaskX = Ax > 0.05;
figure();
subplot(2,2,1); imshow(GammaX);title("Gamma xx");
subplot(2,2,2); imshow(MaskX);title("ImBinaria");

SE = strel("disk",150);   
Bw = imclose(MaskX,SE);
subplot(2,2,3); imshow(Bw);title("ImClose");
se = strel("disk",50);
Bw = ~imerode(Bw,se);

Px1 = Px;
Px1(Bw)=NaN;
Py1 = Py;
Py1(Bw)=NaN;
Pz1 = Pz;
Pz1(Bw)=NaN;

% elimino 10 pixeles alrededor
Px1([1:10, end-9:end], [1:10, end-9:end]) =NaN;
Py1([1:10, end-9:end], [1:10, end-9:end]) =NaN;
Pz1([1:10, end-9:end], [1:10, end-9:end]) =NaN;


sumImg = Load_imageFondo(RutaImg,filename,0,Npasos,".jpg");
CreateFigure_Obj(Px1,Py1,Pz1,sumImg,"#Gamma ex");

%%

Bw = histeq(uint8(Ax));
Bw= imbinarize(Bw);
SE = strel("disk",150);   
Bw = imclose(Bw,SE);
se = strel("disk",50);
Bw = ~imerode(Bw,se);
figure(2);
imshow(Bw);


Px1 = Px;
Px1(Bw)=NaN;
Py1 = Py;
Py1(Bw)=NaN;
Pz1 = Pz;
Pz1(Bw)=NaN;

% elimino 10 pixeles alrededor
Px1([1:10, end-9:end], [1:10, end-9:end]) =NaN;
Py1([1:10, end-9:end], [1:10, end-9:end]) =NaN;
Pz1([1:10, end-9:end], [1:10, end-9:end]) =NaN;
Pz1(Pz1 < -10)=NaN;

sumImg = Load_imageFondo(RutaImg,filename,0,Npasos,".jpg");
CreateFigure_Obj(Px1,Py1,Pz1,sumImg,"#43");

%%
Bw = CreateMaskArtifact(Ix,Npasos);
% m1 = max(Mask(:));
% Mask = Mask/m1;
% Bw= imbinarize(Mask);
% SE = strel("disk",150);   
% Bw = imclose(Bw,SE);
% se = strel("disk",50);
% Bw = ~imerode(Bw,se);
figure(3);
imshow(Bw);

Px1 = Px;
Px1(Bw)=NaN;
Py1 = Py;
Py1(Bw)=NaN;
Pz1 = Pz;
Pz1(Bw)=NaN;
Pz1(Pz1 < -10)=NaN;
% elimino 10 pixeles alrededor
Px1([1:10, end-9:end], [1:10, end-9:end]) =NaN;
Py1([1:10, end-9:end], [1:10, end-9:end]) =NaN;
Pz1([1:10, end-9:end], [1:10, end-9:end]) =NaN;


sumImg = Load_imageFondo(RutaImg,filename,0,Npasos,".jpg");
CreateFigure_Obj(Px1,Py1,Pz1,sumImg,"#43");

%%  detecccion baja modulacion
% normalizo data
m1 = max(Ax(:));
ax = Ax/m1;
m1 = max(Bx(:));
bx = Bx/m1;

Lm = (1-ax).^2  .* (1-2*bx).^2;
Bw = Lm > 0.7;
Bw = ~bwareaopen(Bw,50);
SE = strel("disk",150);   
Bw = imclose(Bw,SE);
se = strel("disk",50);
Bw = ~imerode(Bw,se);

imshow(Bw);
Px1 = Px;
Px1(Bw)=NaN;
Py1 = Py;
Py1(Bw)=NaN;
Pz1 = Pz;
Pz1(Bw)=NaN;
Pz1(Pz1 < -10)=NaN;
% elimino 10 pixeles alrededor
px =10;
Px1([1:px, end-px-1:end], [1:px, end-px-1:end]) =NaN;
Py1([1:px, end-px-1:end], [1:px, end-px-1:end]) =NaN;
Pz1([1:px, end-px-1:end], [1:px, end-px-1:end]) =NaN;


sumImg = Load_imageFondo(RutaImg,filename,0,Npasos,".jpg");
CreateFigure_Obj(Px1,Py1,Pz1,sumImg,"Lm = (1-ax).^2  .* (1-2*bx).^2");

%%  Procesar por bloques

% busca cuantos pixele estan por determindao porcente 
% si es menor a 5 % los borro
[Nrows, Ncols, ~] = size(Pz); % Dimensiones de la imagen (asumiendo que es RGB)

N =100; % Tamaño de subcuadros NxN
porMayor = 0.7;
pormenor = 0.1;
Pz1 = Pz;
% -------------------- busca picos positivos
% -------------------- busca picos positivos
for row = 1:N:Nrows
    for col = 1:N:Ncols
        % Definir el subcuadro. Asegurarse de no exceder los límites de la imagen
        subframe = Pz(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols));        
        % normalizo
        m1 = max(subframe(:));
        sfn = subframe/m1;
        s =sum( sfn(:) > porMayor);
        numNaN = sum(isnan(subframe(:)));
        val = s/((N*N)-numNaN);
        if (val <= pormenor && val > 0)
             figure();
             subplot(1,3,1);mesh(subframe);
             surf( Px(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols)), ...
                  Py(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols)), ...
                  sfn); title('Normalized surface');
            subplot(1,3,2);mesh(subframe);
             surf( Px(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols)), ...
                  Py(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols)), ...
                  subframe);title('Original surface');
            subframe(sfn > porMayor) =NaN;
            subplot(1,3,3);   
                 surf( Px(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols)), ...
                  Py(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols)), ...
                  subframe);title('Surface without Artifacts');
            Pz1(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols))=subframe;
        end      
    end
end
%-----------------------------
txt = sprintf('Filtro Subcudros N= %d ', N);
sumImg = Load_imageFondo(RutaImg,filename,0,Npasos,".jpg");
CreateFigure_Obj(Px,Py,Pz1,sumImg,txt);
% -------------------- busca picos positivos respecto a la media
% -------------------- busca picos positivos respecto a la media
% porMayor = 0.7;
% pormenor = 0.1;
% for row = 1:N:Nrows
%     for col = 1:N:Ncols
%         %Definir el subcuadro. Asegurarse de no exceder los límites de la imagen
%         subframe = Pz(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols));        
%         %normalizo
%         m = mean(subframe(:));
%         md = subframe-m;
%         m1 = max(md(:));
%         sfn = md/m1;
%         s =sum( sfn(:) > porMayor);
%         numNaN = sum(isnan(subframe(:)));
%         val = s/((N*N)-numNaN);
%         if (val <= pormenor && val > 0)
%             figure();
%              subplot(1,3,1);mesh(subframe);
%              surf( Px(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols)), ...
%                   Py(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols)), ...
%                   sfn); title('Normalized surface');
%             subplot(1,3,2);mesh(subframe);
%              surf( Px(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols)), ...
%                   Py(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols)), ...
%                   subframe);title('Original surface');
%             subframe(sfn > porMayor) =NaN;
%             subplot(1,3,3);   
%                  surf( Px(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols)), ...
%                   Py(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols)), ...
%                   subframe);title('Surface without Artifacts');
%             Pz1(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols))=subframe;
% 
%         end      
%     end
% end
% %-----------------------------------------------------
% 
% txt = sprintf('Filtro Subcudros N= %d ', N);
% sumImg = Load_imageFondo(RutaImg,filename,0,Npasos,".jpg");
% CreateFigure_Obj(Px,Py,Pz1,sumImg,txt);

%%
% Definir las dimensiones de la superficie
rows = 150;
r2 = 0.5*rows;
cols = 150;
c2 = cols*0.5;
px=3;
% Generar una matriz de valores aleatorios
Z = rand(rows, cols); 10*peaks(rows); Z1=rand(rows, cols);

Z(r2-px:r2+px,c2-px:c2+px) = 1000* abs (Z1(r2-px:r2+px,c2-px:c2+px));

% Crear una malla de coordenadas X e Y
[X, Y] = meshgrid(1:cols, 1:rows);

% Graficar la superficie
figure;
surf(X, Y, Z);

% Opcional: Añadir un poco de estilo a la gráfica
shading interp; % Interpolación para suavizar colores
colormap jet;   % Colores de la superficie
%colorbar;       % Añadir barra de color


% busca cuantos pixele estan por determindao porcente 
% si es menor a 5 % los borro
[Nrows, Ncols, ~] = size(Z); % Dimensiones de la imagen (asumiendo que es RGB)

N =100; % Tamaño de subcuadros NxN
porMayor = 0.1;
pormenor = 0.1;
Pz1 = Z;
% -------------------- busca picos positivos
% -------------------- busca picos positivos
for row = 1:N:Nrows
    for col = 1:N:Ncols
        % Definir el subcuadro. Asegurarse de no exceder los límites de la imagen
        subframe = Pz1(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols));        
        % normalizo
        m1 = max(subframe(:));
        sfn = subframe/m1;
        % m = mean(subframe(:));
        % md = abs(subframe-m);
        % m1 = max(md(:));
        % sfn = md/m1;
        s =sum( sfn(:) > porMayor);
        numNaN = sum(isnan(subframe(:)));
        val = s/((N*N)-numNaN);
        if (val <= pormenor && val > 0)
             figure();
             subplot(1,3,1);mesh(subframe);
             surf( X(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols)), ...
                  Y(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols)), ...
                  sfn); title('Normalized surface');
            subplot(1,3,2);
             surf( X(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols)), ...
                  Y(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols)), ...
                  subframe);title('Original surface');
             %--------------------------------------
            subframe(sfn > porMayor) = NaN;
            subplot(1,3,3);   
                 surf( X(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols)), ...
                  Y(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols)), ...
                  subframe);title('Surface without Artifacts');
            Pz1(row:min(row+N-1, Nrows), col:min(col+N-1, Ncols))=subframe;
            
        end      
    end
end

figure;
surf(X, Y, Pz1);

% Opcional: Añadir un poco de estilo a la gráfica
shading interp; % Interpolación para suavizar colores
colormap jet;   % Colores de la superficie

%%
Pz1 = Remove_Artifacts_ByPlane(Pz,1);
txt = sprintf('Filtro plane N= %d ', 100);
sumImg = Load_imageFondo(RutaImg,filename,0,Npasos,".jpg");
CreateFigure_Obj(Px,Py,Pz1,sumImg,txt);