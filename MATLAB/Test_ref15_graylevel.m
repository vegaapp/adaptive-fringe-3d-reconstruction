%% Gratings
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
RutaImg="D:\FABIO\Doctorado\Pasantia\MATLAB\adq-13-sep-tnegra\obj15\";
filename="fp_";
RutaFilesfull = 'D:\FABIO\Doctorado\Pasantia\MATLAB\adq-13-sep-tnegra\obj15\fp_';
load("D:\FABIO\Doctorado\Pasantia\MATLAB\adq-12-sep-tnegra\cal\cp_params.mat");

%load("D:\FABIO\Doctorado\Pasantia\MATLAB\adq-1-ago-ptos\calf\fase_multi-2.mat");
% no se carga multiplicador de frecuencia ya que el generador de rejilla lo tiene.

offsetImg_y= (Npasos*Nrejillas); % inicio de franjas en Y
alpx = [1,alpx]; % agrego frecuencia 1 a multiplicacode de frecuencias
alpy = [1,alpy]; % agrego frecuencia 1 a multiplicacode de frecuencias
MNc = [2076, 3088]; % resolucion de la camara MNc = [y,x];

%------------------------- calculo correccion
 Icref15 = zeros(MNc);
 Ip = uint8(ones(MNp)*255);
 Hfig = imshow(Ip);
 Thresold = 250;
for level = 255:-5:5
    disp(level);
    Ip = uint8(ones(MNp)*level);
    Hfig.CData = Ip;
    drawnow
    pause(0.3)
    % Acquire image
    Ik = getsnapshot(vid);
    Ik = im2gray(Ik);
    
    % obtiene las dimensiones de la imagen
    [alto, ancho, canales] = size(Icref15);
    % recorre cada píxel de la imagen
    for i = 1:alto
        for j = 1:ancho
            % si la imagen es en color (rgb), hay tres canales: rojo, verde y azul
            if (Icref15(i,j) == 0 && Ik(i,j) < Thresold )
                Icref15(i,j) = level;
            end             
        end
    end
    % msk = Ik < Thresold ;
    % msk2 = Icref15(msk)==0;
    % Icref15(msk2)=level; 
    
end
 % escalo 0-1
 Icref15 = Icref15/255;
 fig= figure(3);
 imshow (Icref15); title('Art ref15 Ic para mapear');
 stop(vid);
 saveas(fig,strcat(RutaImg,"St.fig"));
%---------------------- busco fase
i=1;
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

 
 % mapeo correccio a proyector
 pro_x=1;pro_y=1;
 Fc_ref15 = ImgCameraToProyector_Fc(Icref15,Pdx,pro_x,Pdy,pro_y,MNp);
 fig=figure(2);
 imshow (Fc_ref15);title("Art ref15 Fc Mapeada");
 saveas(fig,strcat(RutaImg,"Fc.fig"));

for i=1:Nrejillas    
   
   % Paso 1) Proyecto rejillas y guardo imagenes   
   disp(strcat('rejilla:',num2str(i),' Paso 1 Proyecto rejillas y guardo imagenes '));
   ProyecGrating_and_saveImg(vid,Fc_ref15, GratingGen,i,RutaFilesfull);

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
    % disp(strcat('rejilla:',num2str(i),' Paso 5 Reconstruyo Objeto y Muestro'));
    % [Totalpoint,Totalresolve,Porcentaje] =ReconstruyeObjeto(RutaImg,filename,dpc,dpp,MNp,Npasos,Bx,Pdx,pro_x,Pdy,pro_y,i);
    %  dat = sprintf('3D Obj Ite.%d Np=%d Tpoint =%d %0.2f%% T.resolve =%d  ',i, Npasos,Totalpoint,Porcentaje,Totalresolve);
    % title(dat);
    % pause(0.5);
   
    
end

 [Totalpoint,Totalresolve,Porcentaje] =ReconstruyeObjeto(RutaImg,filename,dpc,dpp,MNp,Npasos,Bx,Pdx,pro_x,Pdy,pro_y,i);
     dat = sprintf('Art ref15 3D Obj Ite.%d Np=%d Tpoint =%d %0.2f%% T.resolve =%d  ',i, Npasos,Totalpoint,Porcentaje,Totalresolve);
    title(dat);
  saveas(gcf,strcat(RutaImg,"obj.fig"));

%save( strcat(RutaImg, 'alldata.mat'));
%--------------- deleto obj
delete(vid)