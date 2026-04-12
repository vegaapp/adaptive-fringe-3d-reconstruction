function [fc_img] = ImgCameraToProyector_Fc(FcIn, Pdx,pro_x,Pdy,pro_y,MNp)
% Rejilla de rejilla; 
% Npasos de corrimientp de fase
% St img de saturacion
% Pdx  fase desenvuelta en x
% pro_x  proudctorio en  x
% Pdy fase desenvuelta en y
% pro_y  proudctorio en  y
% MNp   size del proyector

 fc_img = ones(MNp);  %zeros(MNp); 

 % ya viene listo la correccion para mapera es decir menores que 1
 msk = FcIn < 1;
 
 %----
 [y, x] = find(msk);   % busco coordenadas x,y
% disp("Normalizando, Escalanado e Interpolando Fases x,y");

 %[Pescx,Pescy] = Normaliza_InterpolaPhasesXY(MNp,Pdx,pro_x, Pdy,pro_y);

 % se escala Fases entre -1 y 1 para correspondencia correcta a pixeles del
 %  proyector

 Pescx = Pdx /(pi*pro_x); % fase escalada en x entre -1 a 1
 Mskx = abs(Pescx)>1;
 Pescx(Mskx)=nan; % el tamaño del Vx es el mismo de la camara
 Pescy = Pdy /(pi*pro_y); % fase escalada en y entre -1 a 1
 %Pescy = Pescy *(MNp(1)/MNp(2));
 Msky = abs(Pescy)>1;
 Pescy(Msky)=nan;
 % se escala a tamaño de proyector
 % ahora se escalan a pixeles proyector
 yp=MNp(1)*0.5; % filas de ma camara
 xp=MNp(2)*0.5; % columnas
 Pescx(:,:) = xp + (xp .*Pescx(:,:));
 Pescy(:,:) = yp + (yp .*Pescy(:,:));
 % vuelvo coordenadas enteras
 Pescx = uint16(Pescx);
 Pescy = uint16(Pescy);
 % elimino datos mayores a maximo pixel del proyector
 masx = abs(Pescx) > 2*xp;
 Pescx(masx)= nan;
 masy = abs(Pescy) > 2*yp;
 Pescy(masy)= nan;

     % mapeo de Camara a Proyector
     cntptos=0;
      for p=1:length(x) % recorrro cada punto        

       ux = Pescx(y(p), x(p));
       uy = Pescy(y(p), x(p));
       fc = FcIn(y(p),x(p));
       if (ux >=1 &&  uy >=1  )  % garantizo indices mayores que 0
           cntptos=cntptos+1;
           fc_img(uy,ux)= fc ;         
       end   

     end  
    disp("Total Puntos " +  num2str(cntptos)+"/"+ num2str(length(x)));
    
end