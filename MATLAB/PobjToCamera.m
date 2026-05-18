function Pcam = PobjToCamera(pobj,Kc,Rc,tc,MNc)
 % proyecta un punto del objeto al plano camara
    % forma 1  
    % pobj = [Pxx(i),Pyy(i),Pzz(i)]';
    % Pcam =  inv(Rc)*(pobj - tc);   
    % Pcam = Kc *pcam ;
    % Pcam = Pcam(:)/Pcam(3) % normalizo 
    
    % forma 2
     Cc = Kc * [Rc', -Rc'*tc];
     Pcam = ihom( Cc * hom(pobj) ); % ptos entre -1 y 1
     % ahora se escalan a pixeles de la camara
     y=MNc(1)*0.5;
     x=MNc(2)*0.5;
     Pcam(1,:) = x + (x .*Pcam(1,:));
     Pcam(2,:) = y + (y.*Pcam(2,:));
     Pcam = uint16(Pcam);

end