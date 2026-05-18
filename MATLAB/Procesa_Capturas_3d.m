clear all;
 close all;
 clc;
%--------------------- Librerias necesarias
addpath("D:\FABIO\Doctorado\Pasantia\MATLAB\dpdevice");
addpath("D:\FABIO\Doctorado\Pasantia\MATLAB\dpdevice\aux_code");
addpath("D:\FABIO\Doctorado\Pasantia\MATLAB");

%--------- Datos Imagenes
RutaImg="D:\FABIO\OPSE\MATLAB\15-may-upc\ObjMe\";
filename="fp_";
load("D:\FABIO\OPSE\MATLAB\15-may-upc\cal\cp_params.mat");


Npasos = 6;
Nrejillas = 4;

offsetImg_y= (Npasos*(Nrejillas)); % inicio de franjas en Y


MNc = [2178, 3860];  % resolucion de la camara MNc = [y,x];
MNp = [800, 1280];  % [filas, columnas] Checkerboard resolution patron proyector DELL UPC

% ---------- setup Objeto de generacion de franjas
ppf = 10;   % Maximum fringe frequency 20  numero minim de pixeles  10-24
ns  = Npasos;	% Number of phase shift steps 6
ng  = Nrejillas;    % Number of gratings
gam = 1.0;  % Gamma
gt  = 'f';      % Grating type:       'f' |  'c'  | 'c2'
mt  = 'exp';    % Multipliers type: 'lin' | 'exp' | 'log'


GratingGen = mfpg(MNp, ppf, ns, ng, gam, gt);

alpx = GratingGen.fmx;
alpy = GratingGen.fmy;
alpx = [1,alpx]; % agrego frecuencia 1 a multiplicacode de frecuencias
alpy = [1,alpy]; % agrego frecuencia 1 a multiplicacode de frecuencias

%---------------- Caturas UPC
% alpx = [1,5.039684199579492,5.039684199579492,5.039684199579492];
% aply = [1,4.308869380063767,4.308869380063767,4.308869380063767];

for i=1:Nrejillas
    disp(strcat("Analizando Grupo de Rejillas:  ",num2str(i)));
   %-------------------------------- procesa franjas x
   offset=(i-1)*Npasos;
   f = prod(alpx(1:i));
   Ix = Load_images(RutaImg,filename,offset,Npasos,".jpg");
   [Ax,Bx,Pex] = phase_shifting_Nstep(Ix,Npasos);
   pro_x =prod(alpx(1:i)) ; % productorio en pro_x = alpx(1)*alpx(2)*alpx(3);
   if (i==1)
       Pdx = Pex;      
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
  
   disp(strcat("Rejilla:  ",num2str(i),'  Analizada'));
end

disp("Creando Objeto 3D");
% recosntruyo y muestro objeto
%Vcrop = [700 1850 906 2900];
[Totalpoint,Totalresolve,Porcentaje] =ReconstruyeObjeto(RutaImg,filename,dpc,...
    dpp,MNp,Npasos,Ix,Bx,Pdx,pro_x,Pdy,pro_y,i );
    dat = sprintf('Me,3D Obj Ite.%d Np=%d Tpoint =%d %0.2f%% T.resolve =%d  ',i, Npasos,Totalpoint,Porcentaje,Totalresolve);
   title(dat);

   %-------------Guardo Pz en carpeta
   save(strcat(RutaImg,'Ptos3D.mat'),'Px','Py','Pz');
   % guardo imagen
   pause(1);
   view(0,90)
   axis equal
   camproj orthographic
   set(gcf,'WindowState','maximized');
   pause(0.1);
   exportgraphics(gcf, fullfile(RutaImg,'obj.png'),'Resolution',300);

   %% ---------------- Punto es X1,Y1, X2,Y2
   % 906,809   2954,1681
   % Vcrop=[Y1,Y2,X1,X2];
   addpath("D:\FABIO\Doctorado\Pasantia\MATLAB");
   Npasos = 6;
   
   RutaImg="D:\FABIO\OPSE\MATLAB\15-may-upc\ObjNormal";
   id ="N";  % Id para crear archivos
   filename="fp_";

   % SubImg=Load_imageFondo(RutaImg,filename,0,Npasos,".jpg");
   % figure(1);
   % imshow(SubImg);
   % Vcrop = [700 1850 906 2900];
   % SubImg = SubImg (Vcrop(1):Vcrop(2),Vcrop(3):Vcrop(4));
   % figure(2);
   % imshow(SubImg);

   
  
   % recorte Imagen Objeto
   Vcrop = [518 1183 370 1873];

   iobj = imread(strcat(RutaImg,'\obj.png'));   
   iobj = iobj (Vcrop(1):Vcrop(2),Vcrop(3):Vcrop(4),:);
   iobj = rot90(iobj);
   %imshow(iobj)
   imwrite(iobj,strcat(RutaImg,'\',id,'_obj.png'));

   % recorte Fc  130,166  772 450
    Vcrop = [166 450 130 772];
   ifc = imread(strcat(RutaImg,'\Fc.png'));   
   ifc = ifc (Vcrop(1):Vcrop(2),Vcrop(3):Vcrop(4),:);
   ifc = rot90(ifc);
   %imshow(ifc)
   imwrite(ifc,strcat(RutaImg,'\',id,'_Fc.png'));

   % recorte St  130,166  772 450
    Vcrop = [166 450 130 772];
   ist= imread(strcat(RutaImg,'\St.png'));   
   ist = ist (Vcrop(1):Vcrop(2),Vcrop(3):Vcrop(4),:);
   ist = rot90(ist);
   %imshow(ist)
   imwrite(ist,strcat(RutaImg,'\',id,'_St.png'));

   % proceso error
   % clear;
   % RutaImg="D:\FABIO\OPSE\MATLAB\15-may-upc\ObjMe";
    load(strcat(RutaImg,'\Pz.mat'));
    load('D:\FABIO\OPSE\MATLAB\15-may-upc\Objok24\Pz.mat');

   Vcrop = [700 1850 906 2900];
   Pz_ref= Pz_ref(Vcrop(1):Vcrop(2),Vcrop(3):Vcrop(4));
   Pz = Pz(Vcrop(1):Vcrop(2),Vcrop(3):Vcrop(4));
   error = abs(Pz_ref-Pz);
   error = rot90(error);
   surf(error)

shading interp
colormap turbo

view(45,30)
axis tight
lighting gouraud
camlight headlight
material shiny
lighting phong
camlight
Error_med= mean(abs(error(:)),'omitnan');
desv = std(error(:),'omitnan');

mensaje = sprintf('Med = %.4f   |   Desv = %.4f',Error_med,desv);
disp(mensaje);

%------------------ calulo error recostruccion
s= size(Pz);
Tp = s(1)*s(2)
nan_elements = isnan(Pz);
TotalNoresolve = sum(nan_elements(:), 'all');
Np = Tp-TotalNoresolve;
Porcentaje = (Np/Tp)*100
save(strcat(RutaImg,'\','Metricas.mat'),'Error_med','desv','Tp','Np','Porcentaje');

pause(0.1);
exportgraphics(gcf, strcat(RutaImg,'\',id,'_error.png'),'Resolution',300);

disp('Termino con exito');