 function  [Totalpoint,Totalresolve,Porcentaje] = ...
     ReconstruyeObjeto(RutaImg,filename,dpc,dpp,MNp,Npasos, ...
     Ix,Bx,Pdx,pro_x,Pdy,pro_y,Iteracion,Vcrop)

     FlagCrop=1;
    
     if nargin < 15
        FlagCrop = 0;
     end
    
% dpc  Objeto de calibracion  camara
% dpp  Objeto de calibracion  proyector
% MNp  Tamaño del Proyector
% cargamos el ultimo
% Vcrop  Vector crop Objeto. para recortarlo

try
p_m = size(dpc.R,3); % ultima posicion
Rc =dpc.R(:,:,p_m);  % Matriz rotacion Camara
Rp = dpp.R(:,:,p_m);% Matriz rotacion proyector
tc = dpc.t(:,p_m); % vector traslacion Camara
tp = dpp.t(:,p_m); % vector traslacion proyector

Kc = dpc.K; % Parametros Instrinsecos de la camara
Kp = dpp.K; % Parametros Instrinsecos del proyector.
% hacemos forma automatica
sumImg = Load_imageFondo(RutaImg,filename,0,Npasos,".jpg");
Bw = CreateMaskArtifact(Ix,Npasos,1);
[Px,Py,Pz] = PhaseToPointXYZ(Pdx,pro_x,Pdy,pro_y,MNp,Bw,Bx,Rc,Rp,Kc,Kp, tc,tp );

%---------------------- recorto objeto si mando vector
if FlagCrop==1
   Px = Px (Vcrop(1):Vcrop(2),Vcrop(3):Vcrop(4));
   Py = Py (Vcrop(1):Vcrop(2),Vcrop(3):Vcrop(4));
   Pz = Pz (Vcrop(1):Vcrop(2),Vcrop(3):Vcrop(4));
   sumImg = sumImg (Vcrop(1):Vcrop(2),Vcrop(3):Vcrop(4),:);
end

%------------------ calulo error recostruccion
s= size(Pz);
Totalpoint = s(1)*s(2);
nan_elements = isnan(Pz);
TotalNoresolve = sum(nan_elements(:), 'all');
Totalresolve = Totalpoint-TotalNoresolve;
Porcentaje = (Totalresolve/Totalpoint)*100;

%-------------------
CreateFigure_Obj(Px,Py,Pz,sumImg,Iteracion);
  
catch exception
   disp("Error al crear Objeto: " + exception.message);
end

end