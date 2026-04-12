function [fc_img] = FactorCorreccionImg(St,Pdx,pro_x,Pdy,pro_y,MNp)
% Rejilla de rejilla; 
% Npasos de corrimientp de fase
% St img de saturacion
% Pdx  fase desenvuelta en x
% pro_x  proudctorio en  x
% Pdy fase desenvuelta en y
% pro_y  proudctorio en  y
% MNp   size del proyector


 fc_img = ones(MNp);  %zeros(MNp); 

 level = 250;
 % if (IsMetal==1)
 %     level = 178;
 % else
 %     level = 250;
 % end

 msk = St >= level;

 % dilate encontrado
 % SE = strel("disk",5);
 % msk = imdilate(msk,SE);
 % msk = imclose(msk,SE);

 %----
 [y, x] = find(msk);   % busco coordenadas x,y

 
% [Pescx,Pescy] = Normaliza_InterpolaPhasesXY(MNp,Pdx,pro_x, Pdy,pro_y);

 % se escala Fases entre -1 y 1 para correspondencia correcta a pixeles del
 %  proyecto

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

   
 %-----------------  corrige
 maxfc = 0.3 ;% 3*(1-(mean(St(mskpro))/255)); 

  fmax = 0.8;  % factor de correccion maximo valor  0.6
  fmin = maxfc;  % factor de correccion minimo valor  0.3
  smin = level; 
  smax = 255;
  m = (fmax-fmin)/(smin-smax);
  %fc = m*vi + fmin - m*smax;

     % calculo correcciones
      for p=1:length(x) % recorrro cada punto           
       % Vcpto(p) = 1-( ve(p) / (2*Bx(y(p),x(p))) ); 
     
     
      %Vcpto(p) =1.3-(St(y(p),x(p))/levelmax); 
      
       vi = St(y(p),x(p)) ; %/levelmax;
       fc = m*vi + fmin - m*smax;      
        if(fc>0.95)
            fc=0.95;
        end
       
        Vcpto(p) = fc; 

       %Vbx(p)=2*Bx(y(p),x(p));
       ux = Pescx(y(p), x(p));
       uy = Pescy(y(p), x(p));
       po = 5; % pixel offset
       if (ux >=1 && uy >=1 )  % garantizo indices mayores que 0
           % if ( fc_img(uy,ux) < Vcpto(p))
           %     fc = fc_img(uy,ux);
           % end
           fc_img(uy,ux)= fc ;
           try
                if( (uy-po) >1 && (uy+po) <MNp(1) && ux-po >1 && ux+po < MNp(2) )
                    fc_img(uy-po:uy+po,ux-po:ux+po)= fc ;
                end 
                
            catch exception

            end
       end   

     end  
   
      % assignin('base', 'Vcpto', Vcpto); 
      % assignin('base', 'Vbx', Vbx); 



end