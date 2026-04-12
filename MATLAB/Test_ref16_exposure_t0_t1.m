

% ref-16-A 3D shape measurement method for high-reflective surface based on accurate adaptive fringe projection
% proyecta t1 -> I=255, y captura Img la pasa grayscala
% y usa Fc de arriba. en zonas zaturadas
% t0 se busca en camara
 %Gratings
 clear all;
 close all;
 clc;
% setup Librerias creacion de rejilla
addpath("D:\FABIO\Doctorado\Pasantia\MATLAB\dpdevice");
addpath("D:\FABIO\Doctorado\Pasantia\MATLAB\dpdevice\aux_code");
addpath("D:\FABIO\Doctorado\Pasantia\MATLAB");
Npasos = 6;
Nrejillas = 4; % 0.82

% ---------- setup Objeto de generacion de franjas
ppf = 24;   % Maximum fringe frequency 20  numero minim de pixeles
ns  = Npasos;	% Number of phase shift steps 6
ng  = Nrejillas;    % Number of gratings
gam = 1.0;  % Gamma
gt  = 'f';      % Grating type:       'f' |  'c'  | 'c2'
mt  = 'exp';    % Multipliers type: 'lin' | 'exp' | 'log'

% MNp  = [1200-23,1920]; %Resolution Monitor ASUS
% MNp  = [800-23-40,1280]; %Resolution projector EPSON
% MNp  = [600-23-40, 800]; %Mini-projector 3M-MPro 110
MNp  = [1080, 1920]; % Mini-projector KODAK size

GratingGen = mfpg(MNp, ppf, ns, ng, gam, gt);
alpx = GratingGen.fmx;
alpy = GratingGen.fmy;

%alpX = r.fmx;
%alpY = r.fmy;

% setup figura de proyeccion
screens = get(0,"MonitorPositions");
f = figure(1); f.Position = screens(2,:);
f.MenuBar = "none"; f.WindowState = "fullscreen";
set(gca,'Position',[0 0 1 1]); drawnow
%-------------------
Fcall= ones(MNp)*255;
Fcall = uint8(Fcall);
imshow(Fcall);
 drawnow
 pause(0.5);

%------------- setup adquisicion de video.
vid = videoinput('winvideo', 2); %,'UYVY_3088x2076'
%info = imaqhwinfo('winvideo', 2);
%formats = info.SupportedFormats;
src = getselectedsource(vid);

src.ContrastMode     = 'manual';
src.ExposureMode     = 'manual';
src.GainMode         = 'manual';
src.WhiteBalanceMode = 'manual';
src.VerticalFlip     = 'on';

src.Exposure = -4;
src.Contrast = 0;
src.Gain = 0;

triggerconfig(vid, 'manual'); % Manual trigger mode

% ----------- setup  procesado fases
RutaImg="D:\FABIO\Doctorado\Pasantia\MATLAB\adq-13-sep-tnegra\obj16\";
filename="fp_";
RutaFilesfull = 'D:\FABIO\Doctorado\Pasantia\MATLAB\adq-13-sep-tnegra\obj16\fp_';
load("D:\FABIO\Doctorado\Pasantia\MATLAB\adq-13-sep-tnegra\cal\cp_params.mat");

%load("D:\FABIO\Doctorado\Pasantia\MATLAB\adq-1-ago-ptos\calf\fase_multi-2.mat");
% no se carga multiplicador de frecuencia ya que el generador de rejilla lo tiene.

% Npasos = 24;    % arriba esta 
% Nrejillas = 4;  % arriba esta
offsetImg_y= (Npasos*Nrejillas); % inicio de franjas en Y
alpx = [1,alpx]; % agrego frecuencia 1 a multiplicacode de frecuencias
alpy = [1,alpy]; % agrego frecuencia 1 a multiplicacode de frecuencias
MNc = [2076, 3088]; % resolucion de la camara MNc = [y,x];

%----------------------------------------- calculo correccion

t0=19e-3;
t1=39.99e-3;
level=250;
Lp=255;
MNc = [2076, 3088]; % resolucion de la camara MNc = [y,x];
Fcall= ones(MNc)*(level*t0*Lp)/t1;
Img = getsnapshot(vid);
Imggray =double( im2gray(Img));
msk = Imggray >=level; 
Fcall= Fcall./(Imggray*255);
Icref16= ones(MNc);
Icref16(msk)= Fcall(msk);
fig=figure(3);
 imshow (Icref16); title('art 16 Ic para mapear');
 saveas(fig,strcat(RutaImg,"St.fig"));
%----------------------
 Proy_Base = ones(MNp); 
   i=1;
   % Paso 1) Proyecto rejillas y guardo imagenes   
   disp(strcat('rejilla:',num2str(i),' Paso 1 Proyecto rejillas y guardo imagenes '));
   ProyecGrating_and_saveImg(vid,Proy_Base, GratingGen,i,RutaFilesfull);
   %-------------------------------- procesa franjas x
   offset=(i-1)*Npasos;  
   Ix = Load_images(RutaImg,filename,offset,Npasos,".jpg");
   [Ax,Bx,Pex] = phase_shifting_Nstep(Ix,Npasos);
   pro_x =prod(alpx(1:i)) ; % productorio en pro_x = alpx(1)*alpx(2)*alpx(3);
   Pdx = Pex;   % con f <=1 ,  Pdx = Pex
  
   %-------------------------------- franjas y
   Iy = Load_images(RutaImg,filename,offsetImg_y+offset,Npasos,".jpg");
   [Ay,By,Pey] = phase_shifting_Nstep(Iy,Npasos);  
   pro_y =prod(alpy(1:i)) ; % productorio en pro_y = alpy(1)*alpy(2)*alpy(3);
   Pdy = Pey;

 
 % mapeo correccio a proyector
 Fc_ref16 = ImgCameraToProyector_Fc(Icref16,Pdx,pro_x,Pdy,pro_y,MNp);
 fig=figure(4);
 imshow(Fc_ref16);title('Art 16 Fc Creada');
%Fc_ref16 =Proy_Base;
saveas(fig,strcat(RutaImg,"Fc.fig"));


for i=1:Nrejillas    
   
   % Paso 1) Proyecto rejillas y guardo imagenes   
   disp(strcat('rejilla:',num2str(i),' Paso 1 Proyecto rejillas y guardo imagenes '));
   ProyecGrating_and_saveImg(vid,Fc_ref16, GratingGen,i,RutaFilesfull);

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
  
   % Paso 3) Calculo Funcion de saturacion
   %---------- funcion saturacion en x, y

   % Paso 4) Calculo funcion Correccion
   disp(strcat('rejilla:',num2str(i),' Paso 4 Calculo funcion Correccion'));
  % fc_img = FactorCorreccionImg(i,RutaImg,filename,Npasos,Ax,Bx,St,Pdx,pro_x,Pdy,pro_y,MNp);
       
   % Paso 7) Reconstruyo Objeto y Muestro
   % recosntruyo y muestro objeto
    disp(strcat('rejilla:',num2str(i),' Paso 5 Reconstruyo Objeto y Muestro'));
    %ReconstruyeObjeto(RutaImg,filename,dpc,dpp,MNp,Npasos,Bx,Pdx,pro_x,Pdy,pro_y,i);
    % dat = sprintf('Reconstruccion Obj Iteracion %d Npasos %d fc min =%0.2f ',i, Npasos,fcmin);
   % title(dat);
    pause(0.5);
    % if (i==2)
    %     break;
    % end
    
end
 [Totalpoint,Totalresolve,Porcentaje] =ReconstruyeObjeto(RutaImg,filename,dpc,dpp,MNp,Npasos,Bx,Pdx,pro_x,Pdy,pro_y,i);
     dat = sprintf('art 16 Obj Ite.%d Np=%d Tpoint =%d %0.2f%% T.resolve =%d  ',i, Npasos,Totalpoint,Porcentaje,Totalresolve);
    title(dat);
 saveas(gcf,strcat(RutaImg,"obj.fig"));

%save( strcat(RutaImg, 'alldata.mat'));
%--------------- deleto obj
delete(vid)

%%     Fc fondo  Obtencion de intensidad promedio de imagen
i=4;
ProyecGrating_and_saveImg(vid,fc_img, GratingGen,i,RutaFilesfull);
offset=(i-1)*Npasos; 
sumImg = Load_imageFondo(RutaImg,filename,offset,Npasos,".jpg");
mean(sumImg(:))
% franja 1    0.6302
% franja 2    0.6423
% franja 3    0.6610 
% franja 4    0.7282

%% proyectar mascara negra
msk2 = fc_imgCopy==1;
fc_imgCopy(msk2)=0;
figure(1); Hfig = imshow( fc_imgCopy);
%Ik = getsnapshot(vid);

%% test rejillas
% Nrejillas = 4;

for i=1:4
   offset=(i-1)*Npasos;
   img = GratingGen.grating(offset+1);
   for j=2:Npasos
       img = img + GratingGen.grating(offset+j);
   end
   img = img/Npasos;
   figure();
   imhist(img); title(strcat("Rejilla",num2str(i)));
   dat = sprintf('Rejilla %d  Media %0.5f std %0.5f',i,mean(img(:)),std(img(:)));
   disp(dat);
end

%%  
i =4;
Npasos = 24;
Nrejillas = 4;
offset=(i-1)*Npasos;  
offsetImg_y= (Npasos*Nrejillas); % inicio de franjas en Y

RutaImg="D:\FABIO\Doctorado\Pasantia\MATLAB\adq-13-ago\obj_mf2\";
filename="fp_";
RutaFilesfull = 'D:\FABIO\Doctorado\Pasantia\MATLAB\adq-13-ago\obj_mf2\fp_';
sumImg = Load_imageFondo(RutaImg,filename,offset,Npasos,".jpg");
Ix = Load_images(RutaImg,filename,offset,Npasos,".jpg");
   [Ax,Bx,Pex] = phase_shifting_Nstep(Ix,Npasos);

 St =   Ax >178;
 m1=mean(Ax(St))/255
 m2=mean(Ax(:))/255
maxfc1 = 2*(1-(mean(Ax(St))/255))
maxfc2 = 2*(1-(mean(Ax(:))/255))

%%
% ----------- setup  procesado fases
Npasos =24;

RutaImg="D:\FABIO\Doctorado\Pasantia\MATLAB\adq-10-sep-tnegra\obj-normal\";
filename="fp_";
RutaFilesfull = 'D:\FABIO\Doctorado\Pasantia\MATLAB\adq-10-sep-tnegra\obj-normal\fp_';
sumImg = Load_imageFondo(RutaImg,filename,0,Npasos,".jpg");

figure();
imshow(sumImg);

figure(2);
Imcrop=sumImg(154:1990,659:2438);
imshow(Imcrop);

Vcrop=[58,1950,475,2330];
Vcrop=[154:1990,659:2438];
Vcrop=[50,2022,1343,2338];