function [Px,Py,Pz] = PhaseToPointXYZ(Phx,pro_x,Phy,pro_y,Size_p,Bw,Bx,Rc,Rp,Kc,Kp,tc,tp)
% basado en el paper: Key concepts for phase-to-coordinate conversion in fringe projection systems
% https://opg.optica.org/ao/abstract.cfm?uri=ao-58-18-4828
%----------------- Parametros de entrada
% Phx fase desenvuelta en x
% pro_x  productorio x
% Phy fase desenvuelta en y
% pro_y  productorio y
% Size_p  Vector de tamaño M x N del proyector relacion de aspecto
% Bw Mascara para Eliminar bordes con artefactos
% Bx luz de modulacion
% Rc Matriz de Rotacion 3X3 de la camara
% Rp Matriz de Rotacion 3X3 del proyector
% Kc Matriz intrinseca 3X3 de la camara
% Kp Matriz intrinseca 3X3 del proyector
% tc  Vector de translacion de la Camara 1X3
% tp  Vector de translacion del proyector 1X3

%  hacemos normalizacion de la fase en x 
% pro_x =prod(alpx) ; % productorio en pro_x = alpx(1)*alpx(2)*alpx(3);
Fx = 1; % fase inicio es de uno
Vx = Phx / (pi*Fx*pro_x);  % escala datos entre -1 y 1
% eliminando ruido
Mskx = abs(Vx)>1;
Vx(Mskx)=nan; % el tamaño del Vx es el mismo de la camara

%  hacemos normalizacion de la fase en y
%pro_y =prod(alpy) ; % productorio en pro_y = alpy(1)*alpy(2)*alpy(3);
Fy = 1; % fase inicio es de uno
Vy = Phy/(pi*Fy*pro_y);  % escala datos entre -1 y 1
%Size_p = [737, 1280]; tamaño imagen del proyector
Vy = Vy * Size_p(1)/Size_p(2);  % escala datos entre relacion de aspecto proyector
% eliminando ruido
Msky = abs(Vy)>1;
Vy(Msky)=nan;

% Eliminar ruido usando luz de modulacion
msk = Bx < 5;
Vx(msk) = NaN;
Vy(msk) = NaN;

% phase to point
% los puntos u estan escalados entre -1 y 1, por eso se crea grilla asi
% se escalan en funcion de la resolucion del sensor de la camara
M = size(Vx,1);
N = size(Vx,2);
x = linspace(-1,1,N);      % revisar
y = linspace(-1,1,M)*M/N;  % revisar
[X,Y]=meshgrid(x,y);
mu=[X(:),Y(:)]';

%--------------------------
nv=[Vx(:), Vy(:)]';
Hmu = hom(mu); % funcion propia de coordenas homogeneas
Hnv = hom(nv);
dc = Rc*(Kc\Hmu); % equacion 5 paper
dv = Rp*(Kp\Hnv); % equacion 7 paper
pto = nan( size(dc) );

%----------------------- convierte cada puntos de fases (Vx,Vy) (ux,uy)
%                        en coordenada x,y,z
for k = 1:size(Hmu,2)
    if ~isnan( sum(dv(:,k)) )
        Dc = eye(3) - ( (dc(:,k) * dc(:,k)' ) / ...
                        (dc(:,k)'* dc(:,k)  ) ); % eq 29 paper
    
        Dv = eye(3) - ( (dv(:,k) * dv(:,k)' ) / ...
                        (dv(:,k)'* dv(:,k)  ) ); % eq 29 paper
        % \ es traspuesta en MATLAB
        pto(:,k) = (Dc + Dv) \ (Dc*tc + Dv*tp );% eq 29 paper
    end
end

Px = reshape( pto(1,:), size(X) );
Py = reshape( pto(2,:), size(X) );
Pz = reshape( pto(3,:), size(X) );

% %-------------------------
% assignin('base','Px',Px);
% assignin('base','Py',Py);
% assignin('base','Pz',Pz);
% return;
%------------------ elimino bordes de ruido
%------------------------ Elimino Bordes

%subplot(2,2,4); imshow(Bw);title("Im Final");
% Px(Bw) = NaN;
% Py(Bw) = NaN;
% Pz(Bw) = NaN;

%---------------------- no reconstruyevalore negativos
%Pz(Pz < -10)=NaN;
% % elimino 10 pixeles alrededor
% px =10;
% Px([1:px, end-px-1:end], [1:px, end-px-1:end]) =NaN;
% Py([1:px, end-px-1:end], [1:px, end-px-1:end]) =NaN;
% Pz([1:px, end-px-1:end], [1:px, end-px-1:end]) =NaN;

%Pz = remove_peaks(Pz);
%Pz = medfilt2(Pz,[4 4]); % filtro mediana

% eliminando ruido
%Pz( Pz > 70 ) = NaN;
%Pz( Pz < -10 ) = NaN;

%-------------------------
assignin('base','Px',Px);
assignin('base','Py',Py);
assignin('base','Pz',Pz);

end