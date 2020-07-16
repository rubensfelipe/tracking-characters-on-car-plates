%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%--------PROGRAMA PARA O LAYOUT COM OS CARACTERES NA PLACA------------%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Este programa visa apresentar o layout para o resultado do reconhecimento 
%das placas de veículos em uma placa

clear
close all

%Carregando os templates dos caracteres da placa
E = imread('E.png');
K = imread('K.png');
Y = imread('Y.png');
tracinho = imread('tracinho.png');
cinco = imread('5.png');
nove = imread('9.png');
dois = imread('2.png');

%Concatenando os templates dos caracteres identificados na placa
plate = cat(2,E,K,Y,tracinho,nove,cinco,nove,dois);


%Inserindo os templates dentro da placa personalizada
[height width rgbsize] = size(plate);

plano_de_fundo = imread('layout_placa.png');

%Mostrando o resultado do layout final
figure('name','original'); imshow(plate); 
plano_de_fundo(85:84+height,60:59+width,:) = plate(:,:,:); 
figure('name','after'); imshow(plano_de_fundo); 