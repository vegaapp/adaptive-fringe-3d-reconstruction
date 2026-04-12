function [SumImg] = Load_imageFondo(Filepath,Filename,offset,Nimages,extension)
%carga las imagenes de un directorio especifico
%   Detailed explanation goes here
  
    
RutaImg = fullfile(Filepath,Filename);
 if nargin < 5 || isempty(extension)
    extension=".png"; % Valor predeterminado de extension
 end
 
 % prepara array
  fullFileName =  strcat(RutaImg,num2str(offset+1) , extension);
  if exist(fullFileName, 'file')
            % Leer la imagen
            img =  imread(fullFileName);           
            SumImg = zeros(size(img,1),size(img,2));           
      else
            warning('Archivo %s no existe. Saltando...', fullFileName);
            exit ;
  end

    for k = 1:Nimages
        % Construir el nombre del archivo
        fullFileName =  strcat(RutaImg,num2str(k + offset) , extension);
        
        % Verificar si el archivo existe
        if exist(fullFileName, 'file')
            % Leer la imagen
            img = im2double( imread(fullFileName));
            
            % suma Imagenes
            SumImg = SumImg +img;            
          
        else
            warning('Archivo %s no existe. Saltando...', fullFileName);
            exit ;
        end
    end

    SumImg = SumImg/Nimages;


end