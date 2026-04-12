function [I] = Load_images(Filepath,Filename,offset,Nimages,extension)
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
            img = imread(fullFileName);  
            %img = im2double(img);
            if size(img, 3) == 3
                img = rgb2gray(img);
            end
           
            I = zeros(size(img,1),size(img,2),Nimages);
           
      else
            warning('Archivo %s no existe. Saltando...', fullFileName);
            return;
  end

    for k = 1:Nimages
        % Construir el nombre del archivo
        fullFileName =  strcat(RutaImg,num2str(k + offset) , extension);
        
        % Verificar si el archivo existe
        if exist(fullFileName, 'file')
            % Leer la imagen
            img = imread(fullFileName);
            
            % Convertir la imagen a escala de grises si no lo está ya
            if size(img, 3) == 3
                img = rgb2gray(img);
            end
            
            % Almacena la imagen en el array
            I(:,:,k) = img;
        else
            warning('Archivo %s no existe. Saltando...', fullFileName);
            exit ;
        end
    end

end