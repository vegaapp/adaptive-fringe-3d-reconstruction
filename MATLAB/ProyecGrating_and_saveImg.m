function  ProyecGrating_and_saveImg(vid,fc_img, go,GratingToProyect,RutaFile)
 % vid   Video object to capture Images
 % Hfig   de la figura para colocar data
 % GratingToProyect   rejilla a proyectar
 % RutaFile Ruta a guardar
 % go   grenerador de rejillas
 % go.ns  numero de corrimientos
 % go.ng  numero de rejillas
 % fc_img  Matriz factor de correccion

 screens = get(0,"MonitorPositions");

 f = figure(1); f.Position = screens(2,:);
 f.MenuBar = "none"; f.WindowState = "fullscreen";
 set(gca,'Position',[0 0 1 1]); drawnow
 clim( [0, 1] )

 figure(f); Hfig = imshow( go.grating( 1));
 pause(0.1);
 f.Position = screens(2,:);
 f.MenuBar = "none"; f.WindowState = "fullscreen";
 set(gca,'Position',[0 0 1 1]); drawnow
 
  %----------------------------------
     

  start(vid)
  
  % generando  rejillas  en xxxxxxxxxxxxxxxxxxxxxxxxxx
    offset=(GratingToProyect-1)*go.ns;
    for k = 1:go.ns
        
        disp("Grating X:" + num2str(GratingToProyect) + ...
            " shift: " + num2str(k) + "/" +num2str(go.ns) + ... 
            " k: " + num2str(k+offset) + "/" + num2str(2*go.ns*go.ng) );
        
       
        % proyecta rejilla
        Hfig.CData = (go.grating(k+offset).*fc_img);
        
        drawnow
        pause(0.3)
        
        % Acquire image
        Ik = getsnapshot(vid);
        
        % Save image
        imwrite(Ik, strcat(RutaFile,num2str(k+offset),'.jpg') )
    end

% generando  rejillas  en yyyyyyyyyyyyyyyyyyyyyyyy
    offsetImg_y = (go.ns*go.ng); % inicio de franjas en Y

    for k = 1:go.ns
        
        disp("Grating Y:" + num2str(GratingToProyect) + ...
            " shift: " + num2str(k) + "/" +num2str(go.ns) + ... 
            " k: " + num2str(k+offsetImg_y+offset) + "/" + num2str(2*go.ns*go.ng) );

         
        
        % proyecta rejilla
        Hfig.CData = (go.grating(k + offsetImg_y + offset).*fc_img);
        
        drawnow
        pause(0.3)
        
        % Acquire image
        Ik = getsnapshot(vid);
        
        % Save image
        imwrite(Ik, strcat(RutaFile,num2str(k + offsetImg_y + offset),'.jpg') )
    end
   disp('Fin proyección ');
stop(vid)

%delete(vid)

