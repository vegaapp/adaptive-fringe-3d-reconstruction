% paper:Ref2024
% An adaptive fringe projection method for 3D measurement with
% high-reflective surfaces
% https://doi.org/10.1016/j.optlastec.2023.110062

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

% setup figura de proyeccion
screens = get(0,"MonitorPositions");
f = figure(1); f.Position = screens(2,:);
f.MenuBar = "none"; f.WindowState = "fullscreen";
set(gca,'Position',[0 0 1 1]); drawnow

Hfig = imshow( CrearPatron(MNp,320,Npasos,3,0));
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
RutaImg="D:\FABIO\Doctorado\Pasantia\MATLAB\adq-13-sep-tnegra\obj24\";
filename="fp_";
RutaFilesfull = 'D:\FABIO\Doctorado\Pasantia\MATLAB\adq-13-sep-tnegra\obj24\fp_';
load("D:\FABIO\Doctorado\Pasantia\MATLAB\adq-13-sep-tnegra\cal\cp_params.mat");


offsetImg_y= (Npasos*Nrejillas); % inicio de franjas en Y
alpx = [1,alpx]; % agrego frecuencia 1 a multiplicacode de frecuencias
alpy = [1,alpy]; % agrego frecuencia 1 a multiplicacode de frecuencias
MNc = [2076, 3088]; % resolucion de la camara MNc = [y,x];
%preview(vid);

%calculo funcion 
%----------------- proyecto y proceso
start(vid)

% proyecto imag 255 imagen 
Imgp = uint8( 255 * ones(MNp));
Hfig.CData = Imgp;        
drawnow
pause(0.5)  
Ic = getsnapshot(vid);  
Ic = im2gray(Ic);
St =   Ic > 250; 
Imgr  = ones(MNc);
Imgmax = ones(MNc);
ImgFinal = ones(MNc);
ImgFinal(St)=Ic(St);


[y, x] = find(St);   % busco coordenadas x,y

for p=1:length(x)
    Inow = 255; Imin =0;
    Imax=255;
    pixelval = ImgFinal(y(p),x(p));

if ( pixelval >250)
     pixelval
      for i =1:7          
           if( abs(Imax-Imin) <5)
               break;
           end    
           Imgp = uint8( Inow * ones(MNp));
           Hfig.CData = Imgp;        
           drawnow
           pause(0.3)        
           % Acquire image
           Ic = getsnapshot(vid);
           Ic = im2gray(Ic);
           
           msk = Ic > 250;
           cnt = sum( msk(:));
           if( Ic(y(p),x(p)) >250 ) %cnt > 1)  % Ic(y(p),x(p)
               Imax = Inow;
               Inow = (Imax+Imin)/2;
               disp(">250");
           else
                Imin = Inow;
                Inow = (Imax+Imin)/2;
                disp("<250");
           end        
      end    

       msk = ImgFinal==pixelval;
       ImgFinal(msk)=Inow/255;
      %-----------------
       % obtiene las dimensiones de la imagen
    % [alto, ancho, canales] = size(ImgFinal);
    % % recorre cada píxel de la imagen
    % for i = 1:alto
    %     for j = 1:ancho
    %         % si la imagen es en color (rgb), hay tres canales: rojo, verde y azul
    %         if (ImgFinal(i,j) == pixelval )
    %             ImgFinal(i,j) = Inow/255;
    %         end             
    %     end
    % end
     
end

end   
stop(vid)
%-------------

 fig=figure(3);
 imshow(ImgFinal); title('Image a mapear');
 saveas(fig,strcat(RutaImg,"St.fig"));
%------------
%----------------------
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
 pro_x=1.0;pro_y=1.0;
 Fc_Art2024 = ImgCameraToProyector_Fc(ImgFinal,Pdx,pro_x,Pdy,pro_y,MNp);
 fig=figure(4);
 imshow(Fc_Art2024);title('Fc Mapeada');
 saveas(fig,strcat(RutaImg,"Fc.fig"));
 
for i=1:Nrejillas    
   
   % Paso 1) Proyecto rejillas y guardo imagenes   
   disp(strcat('rejilla:',num2str(i),' Paso 1 Proyecto rejillas y guardo imagenes '));
   ProyecGrating_and_saveImg(vid,Fc_Art2024, GratingGen,i,RutaFilesfull);

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
     dat = sprintf('3D Obj Ite.%d Np=%d Tpoint =%d %0.2f%% T.resolve =%d  ',i, Npasos,Totalpoint,Porcentaje,Totalresolve);
    title(dat);
 saveas(gcf,strcat(RutaImg,"obj.fig"));

%save( strcat(RutaImg, 'alldata.mat'));
%--------------- deleto obj
delete(vid)


%Ic = getsnapshot(vid);
%Ic = im2gray(Ic);
%St =   Ic > 250; 
% Imgp = ones(MNc);
% Imgp(St) = Inow/255;
% figure(2);
% subplot(2,2,1);imshow(Ic); title("Gray Img");
% subplot(2,2,2);imshow(St); title("Saturate areas");
% subplot(2,2,3);imshow(ImgFinal); title("Fc");
% subplot(2,2,4);imshow(Imgr); title("Imgr");

%%  resta superficies

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

Zerr = abs(Pz1-Pz);
msk = ~isnan(Zerr);
med = mean(Zerr(msk));
dev = std(Zerr(msk));
dat = sprintf('art ref16,3D Obj Np=%d Error Med= %0.4f std %0.4f   ', Npasos,med,dev);


fig=figure(2);

 surf( Px(1:2:end, 1:10:end), ...
      Py(1:2:end, 1:10:end), ...
      Zerr(1:2:end, 1:10:end), ...
      'EdgeColor','None')
colormap lines;
title(dat);
 saveas(fig,strcat(RutaImg,"error.fig"));