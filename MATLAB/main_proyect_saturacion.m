%% Gratings
 clear all;
 close all;
 clc;
% setup Librerias creacion de rejilla
addpath("D:\FABIO\Doctorado\Pasantia\MATLAB\dpdevice");
addpath("D:\FABIO\Doctorado\Pasantia\MATLAB\dpdevice\aux_code");
addpath("D:\FABIO\Doctorado\Pasantia\MATLAB");
Npasos = 6;
Nrejillas = 4; 

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
GratingGen24 = mfpg(MNp, ppf, 24, ng, gam, gt);
alpx = GratingGen.fmx;
alpy = GratingGen.fmy;


%alpX = r.fmx;
%alpY = r.fmy;

% setup figura de proyeccion
screens = get(0,"MonitorPositions");
f = figure(1); f.Position = screens(2,:);
f.MenuBar = "none"; f.WindowState = "fullscreen";
set(gca,'Position',[0 0 1 1]); drawnow  
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
RutaImg="D:\FABIO\Doctorado\Pasantia\MATLAB\test_St\";
filename="fp_"; %objnp24
RutaFilesfull = 'D:\FABIO\Doctorado\Pasantia\MATLAB\test_St\fp_';
load("D:\FABIO\Doctorado\Pasantia\MATLAB\adq-13-sep-tnegra\cal\cp_params.mat");

%load("D:\FABIO\Doctorado\Pasantia\MATLAB\adq-1-ago-ptos\calf\fase_multi-2.mat");
% no se carga multiplicador de frecuencia ya que el generador de rejilla lo tiene.

% Npasos = 24;    % arriba esta 
% Nrejillas = 4;  % arriba esta
offsetImg_y= (Npasos*Nrejillas); % inicio de franjas en Y
alpx = [1,alpx]; % agrego frecuencia 1 a multiplicacode de frecuencias
alpy = [1,alpy]; % agrego frecuencia 1 a multiplicacode de frecuencias
MNc = [2076, 3088]; % resolucion de la camara MNc = [y,x];
Lk=[3,2,1,0.5];  % factor de correcion.
fc_img = ones(MNp); % Matrix de correccion
%fcLuz = [0.9,0.8,0.7,0.5]; % factor de correccion Luz de rejilla
fcLuz = [1,1,1,1]; % factor de correccion Luz de rejilla


%---------------------- calculo St con franja de mayor orden  
i=4;
Proy_Base = ones(MNp);
ProyecGrating_and_saveImg(vid,Proy_Base, GratingGen,i,RutaFilesfull);

%-------------------------------- procesa franjas x
   offset=(i-1)*Npasos;  
   Ix = Load_images(RutaImg,filename,offset,Npasos,".jpg");
   [Ax,Bx,Pex] = phase_shifting_Nstep(Ix,Npasos);
   Pdx = Pex;   % con f <=1 ,  Pdx = Pex

 %-------------------------------- franjas y
   Iy = Load_images(RutaImg,filename,offsetImg_y+offset,Npasos,".jpg");
   [Ay,By,Pey] = phase_shifting_Nstep(Iy,Npasos); 
    Pdy = Pey;

 % calcula funcion saturacion   
   St = (Ax+Ay)/2;
   fig=figure(2);
   msk = St>=250;
   imshow(msk); title("St detectada");
   saveas(fig,strcat(RutaImg,"St.fig"));
   return;
% %----------------------
% i=1;Np = 24; 
% off_y= (Np*Nrejillas); % inicio de franjas en Y
% Proy_Base = ones(MNp);
% ProyecGrating_and_saveImg(vid,Proy_Base, GratingGen24,i,RutaFilesfull);
% -------------------------------- procesa franjas x
%    offset=(i-1)*Np;  
%    Ix = Load_images(RutaImg,filename,offset,Np,".jpg");
%    [Ax,Bx,Pex] = phase_shifting_Nstep(Ix,Np);
%    pro_x =prod(alpx(1:i)) ; % productorio en pro_x = alpx(1)*alpx(2)*alpx(3);
%    Pdx = Pex;   % con f <=1 ,  Pdx = Pex
%  -------------------------------- franjas y
%    Iy = Load_images(RutaImg,filename,off_y+offset,Np,".jpg");
%    [Ay,By,Pey] = phase_shifting_Nstep(Iy,Np); 
%    pro_y =prod(alpy(1:i)) ; % productorio en pro_y = alpy(1)*alpy(2)*alpy(3);
%    Pdy = Pey;

  Proy_Base = ones(MNp); 
   i=1;
   % Paso 1) Proyecto rejillas y guardo imagenes   
   disp(strcat('rejilla:',num2str(i),' Paso 1 Proyecto rejillas y guardo imagenes '));
   ProyecGrating_and_saveImg(vid,Proy_Base, GratingGen,i,RutaFilesfull);
   % Paso 2) Extraigo Fase para Reconstruccion y Correccion
   disp(strcat('rejilla:',num2str(i),' Paso 2 Extraigo Fase'));
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
  

 % calcula funcion saturacion
 % St = FuncionSaturacion(i,Ax,Bx,Ay,By);
 % St1 = St;
 % level = 0.7*max(St(:)); 
 % msk = St > level;
 % figure();
 % imshow(msk);

 %------------ calcula funcion saturacion
show_fc=1;

if (show_fc==1)
  % St = ones(MNc)*255;
   fc_img = FactorCorreccionImg(St,Pdx,pro_x,Pdy,pro_y,MNp);
   fig=figure(3);
   imshow(fc_img); title("Me, Fc generada");
   saveas(fig,strcat(RutaImg,"Fc.fig"));
end
 % figure(1) 
 % imshow(fc_img);


 fc_imgCopy = fc_img;
 

for i=1:Nrejillas
    Proy_Base = ones(MNp)*fcLuz(i);   
    fc_img = Proy_Base.*fc_imgCopy;
   % Paso 1) Proyecto rejillas y guardo imagenes   
   disp(strcat('rejilla:',num2str(i),' Paso 1 Proyecto rejillas y guardo imagenes '));
   ProyecGrating_and_saveImg(vid,fc_img, GratingGen,i,RutaFilesfull);

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
   disp(strcat('rejilla:',num2str(i),' Paso 3 Calculo Funcion de saturacion'));
   %---------- funcion saturacion en x, y
   % Escalo matrices
   % Ax1 = Ax/255;
   % Bx1 = Bx/255;
   % Sx = Lk(i)*((Ax1 .*(1-Bx1)).^3);
   % Ay1 = Ay/255;
   % By1 = By/255;
   % Sy = Lk(i)*((Ay1 .*(1-By1)).^3);
   % St = (Sx + Sy)/2;

   % Paso 4) Calculo funcion Correccion
   disp(strcat('rejilla:',num2str(i),' Paso 4 Calculo funcion Correccion'));
  % fc_img = FactorCorreccionImg(i,RutaImg,filename,Npasos,Ax,Bx,St,Pdx,pro_x,Pdy,pro_y,MNp);
       
   % Paso 7) Reconstruyo Objeto y Muestro
   % recosntruyo y muestro objeto
%     disp(strcat('rejilla:',num2str(i),' Paso 5 Reconstruyo Objeto y Muestro'));
% [Totalpoint,Totalresolve,Porcentaje] =ReconstruyeObjeto(RutaImg,filename,dpc,dpp,MNp,Npasos,Bx,Pdx,pro_x,Pdy,pro_y,i);
%      dat = sprintf('3D Obj Ite.%d Np=%d Tpoint =%d %0.2f%% T.resolve =%d  ',i, Npasos,Totalpoint,Porcentaje,Totalresolve);
%     title(dat);
%     pause(0.5);
    % if (i==2)
    %     break;
    % end
    
end

%Vcrop=[150,1990,655,2460];
[Totalpoint,Totalresolve,Porcentaje] =ReconstruyeObjeto(RutaImg,filename,dpc,dpp,MNp,Npasos,Ix,Bx,Pdx,pro_x,Pdy,pro_y,i);
    dat = sprintf('Me,3D Obj Ite.%d Np=%d Tpoint =%d %0.2f%% T.resolve =%d  ',i, Npasos,Totalpoint,Porcentaje,Totalresolve);
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