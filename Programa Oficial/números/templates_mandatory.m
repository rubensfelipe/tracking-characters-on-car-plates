%Convers�o da img redimensionada para n�veis de cinza

a = imread('mandatory1.bmp');

g1 = rgb2gray(a); %uint8, 2 dimens�es (x,y), n�veis 0 a 255

%threshold, intensidade acima de 50 vira 1 e abaixo vira 0
ajuste = logical(g1); %para fotos com sombra na placa
% ajuste = g1>80;
% ajuste = g1>200; %para fotos com sol na placa

figure
imshow(ajuste), title('Ajuste de Instensidade na imagem')

%img negativa, complemento: 1 vira 0 e 0 vira 1
ajuste_inverso = imcomplement(ajuste);

figure
imshow(ajuste_inverso), title('Imagem Negativa')

%Localiza��o das formas geom�tricas na imagem
Iprops = regionprops(ajuste_inverso,'BoundingBox','Image');

%Cria��o de caixas retangulares para cada regi�o da imagem
for n = 1:size(Iprops,1)
    box = Iprops(n).BoundingBox;
    if box(3)>3 && box(3)<60 && box(4)>10 && box(4)<60
       rectangle('Position',[box(1),box(2),box(3),box(4)],'EdgeColor','g','LineWidth',2);
    end
end

%Recortar as regi�es enquadradas para novas vari�veis
t = 0;
 for q=1:size(Iprops,1)
     box = Iprops(q).BoundingBox;
     if box(3)>3 && box(3)<60 && box(4)>10 && box(4)<60
        t = t+1; %numero de regi�es enquadradas
        eval(sprintf('font%d = ajuste_inverso(box(2):box(2)+box(4),box(1):box(1)+box(3));',t));
     end
 end
