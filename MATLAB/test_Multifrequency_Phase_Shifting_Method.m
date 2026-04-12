clear all;clc;
% datos Nefertiti
RutaImg="D:\FABIO\Doctorado\Pasantia\Proyecto\Nefertiti\patterns";
filename="fp_";


Ix = Load_images(RutaImg,filename,0,4);
Iy = Load_images(RutaImg,filename,16,4);
Npasos = 4; % pasos de corrimiento de fase

% figure(1)
% for i=1:Npasos
%     subplot(2,2,i); imagesc(Ix(:,:,i));title( strcat('imagen x ',num2str(i)));
% end
% colormap(gray)
% figure(2)
% for i=1:Npasos
%     subplot(2,2,i); imagesc(Iy(:,:,i));title( strcat('imagen y ',num2str(i)));
% end
% colormap(gray)

% Ax Luz de Fondo
% Bx Intensidad de Modulacion
% Pex  Fase envuelta x

% la primera iteracion la fase envuelta y desenvuelta Pd_ son la misma
% porque la frecuencia es menor a 1 en el sensor de la camara
[Ax,Bx,Pex] = phase_shifting_Nstep(Ix,Npasos);
Pdx = Pex;
[Ay,By,Pey] = phase_shifting_Nstep(Iy,Npasos);
Pdy = Pey;
%  alpx  factor multiplicador de frecuencia en x, puede cambiar entre fraja y
%        franja, esta en archivo fp_fmul.mat
%  alpy  factor multiplicador de frecuencia en y, puede cambiar entre fraja y
%        franja, esta en archivo fp_fmul.mat
load("D:\FABIO\Doctorado\Pasantia\Proyecto\Nefertiti\patterns\fp_fmul.mat");
load("D:\FABIO\Doctorado\Pasantia\Proyecto\Nefertiti\params\cp_params.mat");

% hacemos forma automatica

for i=1:3
    %----------------- en x
   Ix = Load_images(RutaImg,filename,4*i,4);
   [Ax,Bx,Pex] = phase_shifting_Nstep(Ix,Npasos);

   %hx =  round ( (alpx(i)*Pdx-Pex)/(2*pi));
   %Pdx = Pex + 2*pi*hx; % correccion multifrecuencia
   Pdx = UnwrapMultifrecuence(Pex,Pdx,alpx(i));

   figure(3);
   subplot(2,3,i); imagesc(Pex); title(strcat( 'ite ',num2str(i) ,' Fase Envuelta x'));  
   subplot(2,3,i+3); imagesc(Pdx);title(strcat( 'ite ',num2str(i) ,' Fase desenvuelta x'));   
   colormap(gray);

   Iy = Load_images(RutaImg,filename,16 + 4*i,4);
   [Ay,By,Pey] = phase_shifting_Nstep(Iy,Npasos);
   %hy =  round ( (alpy(i)*Pdy-Pey)/(2*pi));
   %Pdy = Pey + 2*pi*hy; % correccion multifrecuencia
   Pdy = UnwrapMultifrecuence(Pey,Pdy,alpy(i));

   figure(4);
   subplot(2,3,i); imagesc(Pey); title(strcat( 'ite ',num2str(i) ,' Fase Envuelta y'));  
   subplot(2,3,i+3); imagesc(Pdy);title(strcat( 'ite ',num2str(i) ,' Fase desenvuelta y'));   
   colormap(gray);

end

figure;title("Vx");
%  hacemos normalizacion de la fase. 
pro_x =prod(alpx) ; % productorio en pro_x = alpx(1)*alpx(2)*alpx(3);
Fx = 1; % fase inicio es de uno
Vx = Pdx / (pi*Fx*pro_x);  % escala datos entre -1 y 1
% eliminando ruido
Mskx = abs(Vx)>1;
Vx(Mskx)=nan;
mesh(Vx);


figure;title("Vy");
pro_y =prod(alpy) ; % productorio en pro_y = alpy(1)*alpy(2)*alpy(3);
Fy = 1; % fase inicio es de uno
Vy = Pdy/(pi*Fy*pro_y);  % escala datos entre -1 y 1

MNp = [480-23,  640];
Vy = Vy * MNp(1)/MNp(2);  % escala datos entre relacion de aspecto proyector

% eliminando ruido
Msky = abs(Vy)>1;
Vy(Msky)=nan;
mesh(Vy);title("Vy");

% Eliminar ruido usando luz de modulacion
msk = Bx < 8;
Vx(msk) = NaN;
Vy(msk) = NaN;

% phase to point
% los puntos u estan escalados entre -1 y 1, por eso se crea grilla asi
M = size(Iy,1);
N = size(Iy,2);
x = linspace(-1,1,N);      % revisar
y = linspace(-1,1,M)*M/N;  % revisar
[X,Y]=meshgrid(x,y);
mu=[X(:),Y(:)]';

nv=[Vx(:), Vy(:)]';
Hmu = hom(mu);
Hnv = hom(nv);
dc = Rc*(Kc\Hmu);
dv = Rp*(Kp\Hnv);
pto = nan( size(dc) );
for k = 1:size(Hmu,2)
    if ~isnan( sum(dv(:,k)) )
        Dc = eye(3) - ( (dc(:,k) * dc(:,k)' ) / ...
                        (dc(:,k)'* dc(:,k)  ) );
    
        Dv = eye(3) - ( (dv(:,k) * dv(:,k)' ) / ...
                        (dv(:,k)'* dv(:,k)  ) );
        % \ es traspuesta en MATLAB
        pto(:,k) = (Dc + Dv) \ (Dc*tc + Dv*tp );
    end
end


pcshow( pto' )

Px = reshape( pto(1,:), size(X) );
Py = reshape( pto(2,:), size(X) );
Pz = reshape( pto(3,:), size(X) );

surf( Px(1:2:end, 1:10:end), ...
      Py(1:2:end, 1:10:end), ...
      Pz(1:2:end, 1:10:end), 'EdgeColor','None' )

light
daspect([1,1,1])

return

%% hacemos de forma manual x iteracion 1
Ix = Load_images(RutaImg,filename,4,4);
[Ax,Bx,Pex] = phase_shifting_Nstep(Ix,Npasos);
h =  round ( (alpx(1)*Pdx-Pex)/(2*pi));
Pdx1 = Pex + 2*pi*h; % correccion multifrecuencia

figure(3);
subplot(2,1,1); imagesc(Pex); title('ite 1 Fase Envuelta x');
subplot(2,1,2); imagesc(Pdx1);title('ite 1 Fase desenvuelta x');
colormap(gray);

% hacemos de forma manual x iteracion 2
Pdx = Pdx1;
Ix = Load_images(RutaImg,filename,8,4);
[Ax,Bx,Pex] = phase_shifting_Nstep(Ix,Npasos);
%[Ax,Bx,Pex] = phase_shifting_4step(Ix);
h =  round ( (alpx(1)*Pdx-Pex)/(2*pi));
Pdx1 = Pex + 2*pi*h; % correccion multifrecuencia

figure(4);
subplot(2,1,1); imagesc(Pex); title('ite 2 Fase Envuelta x');
subplot(2,1,2); imagesc(Pdx1);title('ite 2 Fase desenvuelta x');
colormap(gray);

% hacemos de forma manual x iteracion 3
Pdx = Pdx1;
Ix = Load_images(RutaImg,filename,12,4);
[Ax,Bx,Pex] = phase_shifting_Nstep(Ix,Npasos);
%[Ax,Bx,Pex] = phase_shifting_4step(Ix);
h =  round ( (alpx(1)*Pdx-Pex)/(2*pi));
Pdx1 = Pex + 2*pi*h; % correccion multifrecuencia

figure(5);
subplot(2,1,1); imagesc(Pex); title('ite 3 Fase Envuelta x');
subplot(2,1,2); imagesc(Pdx1);title('ite 3 Fase desenvuelta x');
colormap(gray);

%% hacemos de forma manual y iteracion 1  yyyyyyyyyyyyyyyyyy
 Iy = Load_images(RutaImg,filename,20,4);
 [Ay,By,Pey] = phase_shifting_Nstep(Iy,Npasos);
 hy =  round ( (alpy(1)*Pdy-Pey)/(2*pi));
 Pdy = Pey + 2*pi*hy; % correccion multifrecuencia

figure(3);
subplot(2,1,1); imagesc(Pey); title('ite 1 Fase Envuelta y');
subplot(2,1,2); imagesc(Pdy);title('ite 1 Fase desenvuelta y');
colormap(gray);

% hacemos de forma manual y iteracion 2 y
 Iy = Load_images(RutaImg,filename,24,4);
 [Ay,By,Pey] = phase_shifting_Nstep(Iy,Npasos);
 hy =  round ( (alpy(1)*Pdy-Pey)/(2*pi));
 Pdy = Pey + 2*pi*hy; % correccion multifrecuencia

figure(4);
subplot(2,1,1); imagesc(Pey); title('ite 2 Fase Envuelta y');
subplot(2,1,2); imagesc(Pdy);title('ite 2 Fase desenvuelta y');
colormap(gray);

% hacemos de forma manual y iteracion 3 y
 Iy = Load_images(RutaImg,filename,24,4);
 [Ay,By,Pey] = phase_shifting_Nstep(Iy,Npasos);
 hy =  round ( (alpy(1)*Pdy-Pey)/(2*pi));
 Pdy = Pey + 2*pi*hy; % correccion multifrecuencia

figure(5);
subplot(2,1,1); imagesc(Pey); title('ite 3 Fase Envuelta y');
subplot(2,1,2); imagesc(Pdy);title('ite 3 Fase desenvuelta y');
colormap(gray);
