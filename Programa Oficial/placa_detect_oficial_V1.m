%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%----------------RECONHECIMENTO DE PLACAS DE AUTOMÓVEIS---------------%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Este programa visa fazer o reconhecimento do número em placas de
%automóveis

%Exemplo: Dada uma foto de um automóvel com a placa visível

%Resultado: Número inscrito da placa em formato de texto



clear
close all
%%
%CARREGANDO OS TEMPLATES

%Carregando os Templates Numéricos
template1 = imread('números/0.bmp');template2 = imread('números/1.bmp');template3 = imread('números/2.bmp');
template4 = imread('números/3.bmp');template5 = imread('números/4.bmp');template6 = imread('números/5.bmp');
template7 = imread('números/6.bmp');template8 = imread('números/7.bmp');template9 = imread('números/8.bmp');
template10 = imread('números/9.bmp');

%Carregando os Templates Alfabéticos
template11 = imread('números/A.bmp');template12 = imread('números/B.bmp');template13 = imread('números/C.bmp');
template14 = imread('números/D.bmp');template15 = imread('números/E.bmp');template16 = imread('números/F.bmp');
template17 = imread('números/G.bmp');template18 = imread('números/H.bmp');template19 = imread('números/I.bmp');
template20 = imread('números/J.bmp');template21 = imread('números/K.bmp');template22 = imread('números/L.bmp');
template23 = imread('números/M.bmp');template24 = imread('números/N.bmp');template25 = imread('números/O.bmp');
template26 = imread('números/P.bmp');template27 = imread('números/Q.bmp');template28 = imread('números/R.bmp');
template29 = imread('números/S.bmp');template30 = imread('números/T.bmp');template31 = imread('números/U.bmp');
template32 = imread('números/V.bmp');template33 = imread('números/W.bmp');template34 = imread('números/X.bmp');
template35 = imread('números/Y.bmp');template36 = imread('números/Z.bmp');

%número de templates
n_templates = 36;


%Convertendo templates para tipo lógico e armazendo em variáveis
for a = 1:n_templates
    eval( sprintf('temp = template%d;',a) );
    tem = rgb2gray(temp); %escalas de cinza 0..255 em um dimensão
    tem1 = logical(tem); %preto ou branco (0 ou 1)
    eval( sprintf('template%d = tem1;',a) );
end
%%
%FILTRANDO A IMAGEM DO CARRO


%Carregando a imagem do automóvel
% a = imread('luz\ODR1828.jpeg');
a = imread('DWG2037.jpeg');

%Redimensionando a imagem a fim de caber na figura
b = imresize(a,[400 NaN]); %NaN mantém a proporção da imagem inicial

figure
imshow(b), title('Imagem Redimensionada da Imagem Original')

%Conversão da img redimensionada para níveis de cinza
g1 = rgb2gray(b); %uint8, 2 dimensões (x,y), níveis 0 a 255

figure
imshow(g1), title('Imagem em tons de cinza')

[i j] = size(g1); %i=400 j=712

width =1/2*j;
hight = i-3/8*i; 

%impixelinfo: (Xmax,Ymax) = (712,400)
%imcrop(img,[xmin ymin width hight])
g1 = imcrop(g1,[1/4*j 3/8*i width hight]);

figure
imshow(g1), title('Imagem Recortada')

% figure
% histogram(g1), title('histograma tons de cinza');

g_luz = imsubtract(g1,50);

% figure
% imshow(ajuste)

%threshold, intensidade acima de 60 vira 1 e abaixo vira 0
ajuste_luz = g_luz>60; %para fotos com sol na placa
ajuste = g1>60; %para outras fotos

figure
imshow(ajuste_luz), title('Ajuste para imagens com sol sobre a placa')

figure
imshow(ajuste), title('Ajuste para imagens com sombra sobre a placa')

%img negativa, complemento: 1 vira 0 e 0 vira 1
ajuste_inverso_luz = imcomplement(ajuste_luz);
ajuste_inverso = imcomplement(ajuste);

figure
imshow(ajuste_inverso), title('Imagem Negativa sombra sobre a placa')


%%
%EXTRAÇÃO DAS REGIÕES DA IMAGEM

%Localização das formas geométricas na imagem
Iprops = regionprops(ajuste_inverso,'BoundingBox','Image');

%caso não exista box
caixote = [1 1 1 1];
%Criação de caixas retangulares para cada região da imagem
u = 0; 
for n = 1:size(Iprops,1)
    box = Iprops(n).BoundingBox;

    if box(3)>3 && box(3)<60 && box(4)>10 && box(4)<60 && box(4)>box(3)
       rectangle('Position',[box(1),box(2),box(3),box(4)],'EdgeColor','g','LineWidth',2);
    
       u = u+1;
       caixote(u,:) = box;
       
    end
end 

figure
imshow(ajuste_inverso_luz), title('Imagem Negativa luz sobre a placa')

Iprops_luz = regionprops(ajuste_inverso_luz,'BoundingBox','Image');
%caso não exista box
caixote_luz = [1 1 1 1];
u = 0;
for n = 1:size(Iprops_luz,1)
    box_luz = Iprops_luz(n).BoundingBox;
    if box_luz(3)>3 && box_luz(3)<60 && box_luz(4)>10 && box_luz(4)<60 && box_luz(4)>box_luz(3)
       rectangle('Position',[box_luz(1),box_luz(2),box_luz(3),box_luz(4)],'EdgeColor','g','LineWidth',2);
       u = u+1;
       caixote_luz(u,:) = box_luz;
    end
end

if size(caixote,1)<7 && size(caixote_luz,1)<7
   condicao = 0;
   ERRO = 'PLACA ILEGÍVEL';
   errordlg(ERRO,'Problema')
end
if size(caixote,1)>=7 && size(caixote_luz,1)>=7
   condicao = 1;
end

if size(caixote,1)<7 && size(caixote_luz,1)>=7
    condicao = 2;
end

if size(caixote,1)>=7 && size(caixote_luz,1)<7
    condicao = 3;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_caixote = size(caixote,1);
n_caixote_luz = size(caixote_luz,1);

cc_luz = 0;
if condicao == 1
    
%somatória da origem em x da caixa com seu comprimento
caiX = caixote(:,1)+caixote(:,3);
caiX_luz = caixote_luz(:,1)+caixote_luz(:,3);

%somatória da origem em y da caixa com sua altura
caiY = caixote(:,2)+caixote(:,4);
caiY_luz = caixote_luz(:,2)+caixote_luz(:,4);

%Recortar as regiões enquadradas dentro do limite da dimensão da foto
d = 0;   %box(1), box(2) são as coordenadas x,y e box(3), box(4) são os comprimentos do retângulo 
for b = 1:size(caixote,1)
    if caiX(b,1)<size(g1,2) && caiY(b,1)<size(g1,1)
       d = d+1;
       bala = caixote(b,:);
       eval(sprintf('char%d = ajuste_inverso(bala(2):bala(2)+bala(4),bala(1):bala(1)+bala(3));',d));
    end
end

t = 0;
for b = 1:size(caixote_luz,1)
    if caiX_luz(b,1)<size(g1,2) && caiY_luz(b,1)<size(g1,1)
       t = t+1;
       bala = caixote_luz(b,:);
       eval(sprintf('char_luz%d = ajuste_inverso_luz(bala(2):bala(2)+bala(4),bala(1):bala(1)+bala(3));',t));
    end
end

%CORRELAÇÃO DOS TEMPLATES COM OS CARACTERES DA PLACA

%Função de correlação com todos os box da foto
for n = 1:d %numero de caixas
    for m = 1:n_templates %numero de templates
        eval( sprintf('charizard = char%d;',n) );
        [l c] = size(charizard);
        eval( sprintf('temp = imresize(template%d,[l c]);',m) );
        cc(m,n) = corr2(temp,charizard);
    end %linha de cc = template, coluna de cc = box da imagem
end

for n = 1:t %numero de caixas
    for m = 1:n_templates %numero de templates
        eval( sprintf('charizard = char_luz%d;',n) );
        [l c] = size(charizard);
        eval( sprintf('temp = imresize(template%d,[l c]);',m) );
        cc_luz(m,n) = corr2(temp,charizard);
    end %linha de cc = template, coluna de cc = box da imagem
end

%Máximas correlações de cada box com template
[max_cc,max_index] = max(cc);
[max_cc_luz,max_index_luz] = max(cc_luz);

%Coordenadas dos cc máximos, numero do template e numero do box
temp = max_index; temp_luz = max_index_luz;
caixa = 1:size(cc,2); caixa_luz = 1:size(cc_luz,2);

%Máximas correlações e os respectivos templates
MC = [max_cc' temp' caixa'];
MC_luz = [max_cc_luz' temp_luz' caixa_luz'];

%Máximas correlações em ordem decrescente
PL = sortrows(MC,1,'descend');
PL_luz = sortrows(MC_luz,1,'descend');

%As 7 maiores correlações = Aos 7 caracteres na placa do carro
PL = PL(1:7,:);
PL_luz = PL_luz(1:7,:);

%Reordenando os caracteres na ordem escrita da placa
v = 1;
for i = 1:size(MC,1)
    for j = 1:size(PL,1)
        if MC(i,1) == PL(j,1);
           letter(1,v) = MC(i,1); %maxima correlação obtida
           letter(2,v) = MC(i,2); %templates
           letter(3,v) = MC(i,3); %box com caracteres na foto
           v = v+1;
        end
    end
end

v = 1;
for i = 1:size(MC_luz,1)
    for j = 1:size(PL_luz,1)
        if MC_luz(i,1) == PL_luz(j,1);
           letter_luz(1,v) = MC_luz(i,1); %maxima correlação obtida
           letter_luz(2,v) = MC_luz(i,2); %templates
           letter_luz(3,v) = MC_luz(i,3); %box com caracteres na foto
           v = v+1;
        end
    end
end

%coordenadas letras e numeros da foto da placa
letras = letter(3,1:3); letras_luz = letter_luz(3,1:3);
numeros = letter(3,4:7); numeros_luz = letter_luz(3,4:7);

placa = letter(3,:); placa_luz = letter_luz(3,:);

%gravando as box de letras da placa em uma nova variável
for i = 1:3
    n = placa(1,i);
    eval(sprintf('letra = char%d;',n));
    eval(sprintf('letra%d = letra;',i));
end

for i = 1:3
    n = placa_luz(1,i);
    eval(sprintf('letra_luz = char_luz%d;',n));
    eval(sprintf('letra_luz%d = letra_luz;',i));
end

%gravando as box de números da placa em uma nova variável
j = 0;
for i = 4:7
    k = placa(1,i);
    j = j+1;
    eval(sprintf('numero = char%d;',k));
    eval(sprintf('numero%d = numero;',j));
end

j = 0;
for i = 4:7
    k = placa_luz(1,i);
    j = j+1;
    eval(sprintf('numero_luz = char_luz%d;',k));
    eval(sprintf('numero_luz%d = numero_luz;',j));
end

%Função de correlação 2, com apenas os caracteres da placa na foto

%Correlação com as LETRAS da placa
u = 0;
for n = 1:3 %letras na placa
    u = 0;
    for m = 11:n_templates %template só letras
        u = u+1;
         eval(sprintf('lt = letra%d;',n) );
        [l c] = size(lt);
        
        eval( sprintf('temp = imresize(template%d,[l c]);',m) );
        cc_letras(u,n) = corr2(temp,lt);
    end  %linha de cc = template, coluna de cc = box de letra da foto
end

u = 0;
for n = 1:3 %letras na placa
    u = 0;
    for m = 11:n_templates %template só letras
        u = u+1;
         eval(sprintf('lt_luz = letra_luz%d;',n) );
        [l c] = size(lt_luz);
        
        eval( sprintf('temp_luz = imresize(template%d,[l c]);',m) );
        cc_letras_luz(u,n) = corr2(temp_luz,lt_luz);
    end  %linha de cc = template, coluna de cc = box de letra da foto
end

%Máximas correlações de cada box de letra com template
[max_cc_letras,max_index_letras] = max(cc_letras);
[max_cc_letras_luz,max_index_letras_luz] = max(cc_letras_luz);

%Coordenadas dos cc máximos, numero do template e numero do box
temp_letra = max_index_letras; %1 a 26 letras, A...Z
caixa_letra = 1:size(cc_letras,2);
temp_letra_luz = max_index_letras_luz; %1 a 26 letras, A...Z
caixa_letra_luz = 1:size(cc_letras_luz,2);

%Correlação com os NÚMEROS da placa

for n = 1:4 %número na placa (foto)
    for m = 1:10 %template só com números
        
        eval(sprintf('nm = numero%d;',n) );
        [l c] = size(nm);
        
        eval( sprintf('temp = imresize(template%d,[l c]);',m) );
        cc_numeros(m,n) = corr2(temp,nm);
        
    end  %linha de cc = template, coluna de cc = box de numero da foto
end

for n = 1:4 %número na placa (foto)
    for m = 1:10 %template só com números
        
        eval(sprintf('nm_luz = numero_luz%d;',n) );
        [l c] = size(nm_luz);
        
        eval( sprintf('temp_luz = imresize(template%d,[l c]);',m) );
        cc_numeros_luz(m,n) = corr2(temp_luz,nm_luz);
        
    end  %linha de cc = template, coluna de cc = box de numero da foto
end

%Máximas correlações de cada box com template
[max_cc_num,max_index_num] = max(cc_numeros);
[max_cc_num_luz,max_index_num_luz] = max(cc_numeros_luz);

%Coordenadas dos cc máximos, numero do template e numero do box
temp_numero = max_index_num; %1 a 10, 0...9
caixa_numero = 1:size(cc_numeros,2);
temp_numero_luz = max_index_num_luz; %1 a 10, 0...9
caixa_numero_luz = 1:size(cc_numeros_luz,2);

end




aj = 1;
tipo = ajuste_inverso;
for m = 1:2
if condicao == 2
caixote = caixote_luz;
tipo = ajuste_inverso_luz;
end

  
%completar um pixel faltante entre dois pixels branco
% ajust = bwmorph(ajuste_inverso,'bridge');

%somatória da origem em x da caixa com seu comprimento
caiX = caixote(:,1)+caixote(:,3);

%somatória da origem em y da caixa com sua altura
caiY = caixote(:,2)+caixote(:,4);

%Recortar as regiões enquadradas dentro do limite da dimensão da foto
t = 0;
for b = 1:size(caixote,1)
    if caiX(b,1)<size(g1,2) && caiY(b,1)<size(g1,1)
       t = t+1;
       bala = caixote(b,:);
       eval(sprintf('char%d = tipo(bala(2):bala(2)+bala(4),bala(1):bala(1)+bala(3));',t));
    end
end
%box(1), box(2) são as coordenadas x,y e box(3), box(4) são os comprimentos do retângulo 

%%
%CORRELAÇÃO DOS TEMPLATES COM OS CARACTERES DA PLACA

%Função de correlação com todos os box da foto
for n = 1:t %numero de caixas
    for m = 1:n_templates %numero de templates
        eval( sprintf('charizard = char%d;',n) );
        [l c] = size(charizard);
        eval( sprintf('temp = imresize(template%d,[l c]);',m) );
        cc(m,n) = corr2(temp,charizard);
    end %linha de cc = template, coluna de cc = box da imagem
end

%Verificar as máximas correlações de cada caracter da placa

%Máximas correlações de cada box com template
[max_cc,max_index] = max(cc);

%Coordenadas dos cc máximos, numero do template e numero do box
temp = max_index;
caixa = 1:size(cc,2);

%Máximas correlações e os respectivos templates
MC = [max_cc' temp' caixa'];

%Máximas correlações em ordem decrescente
PL = sortrows(MC,1,'descend');

%As 7 maiores correlações = Aos 7 caracteres na placa do carro
PL = PL(1:7,:);

%Reordenando os caracteres na ordem escrita da placa
v = 1;
for i = 1:size(MC,1)
    for j = 1:size(PL,1)
        if MC(i,1) == PL(j,1);
           letter(1,v) = MC(i,1); %maxima correlação obtida
           letter(2,v) = MC(i,2); %templates
           letter(3,v) = MC(i,3); %box com caracteres na foto
           v = v+1;
        end
    end
end

%coordenadas letras e numeros da foto da placa
letras = letter(3,1:3);
numeros = letter(3,4:7);

placa = letter(3,:);

%gravando as box de letras da placa em uma nova variável
for i = 1:3
    n = placa(1,i);
    eval(sprintf('letra = char%d;',n));
    eval(sprintf('letra%d = letra;',i));
end

%gravando as box de números da placa em uma nova variável
j = 0;
for i = 4:7
    k = placa(1,i);
    j = j+1;
    eval(sprintf('numero = char%d;',k));
    eval(sprintf('numero%d = numero;',j));
end

%Função de correlação 2, com apenas os caracteres da placa na foto

%Correlação com as LETRAS da placa
u = 0;
for n = 1:3 %letras na placa
    u = 0;
    for m = 11:n_templates %template só letras
        u = u+1;
         eval(sprintf('lt = letra%d;',n) );
        [l c] = size(lt);
        
        eval( sprintf('temp = imresize(template%d,[l c]);',m) );
        cc_letras(u,n) = corr2(temp,lt);
    end  %linha de cc = template, coluna de cc = box de letra da foto
end

%Máximas correlações de cada box de letra com template
[max_cc_letras,max_index_letras] = max(cc_letras);

%Coordenadas dos cc máximos, numero do template e numero do box
temp_letra = max_index_letras; %1 a 26 letras, A...Z
caixa_letra = 1:size(cc_letras,2);

%Correlação com os NÚMEROS da placa

for n = 1:4 %número na placa (foto)
    for m = 1:10 %template só com números
        
        eval(sprintf('nm = numero%d;',n) );
        [l c] = size(nm);
        
        eval( sprintf('temp = imresize(template%d,[l c]);',m) );
        cc_numeros(m,n) = corr2(temp,nm);
        
    end  %linha de cc = template, coluna de cc = box de numero da foto
end

%Máximas correlações de cada box com template
[max_cc_num,max_index_num] = max(cc_numeros);

%Coordenadas dos cc máximos, numero do template e numero do box
temp_numero = max_index_num; %1 a 10, 0...9
caixa_numero = 1:size(cc_numeros,2);

if condicao == 1
aj = aj+1;
else
    break
end

end



%Identificação das letras da placa
for i = 1:size(temp_letra,2)
    
    L = temp_letra(1,i);
    if mean2(max(cc_luz))>mean2(max(cc))
       L = temp_letra_luz(1,i);
    end
    %alfabeto
    if     L==1
       c(i) = 'A';
   elseif L==2
       c(i) = 'B';
    elseif L==3
       c(i) = 'C';
    elseif L==4
       c(i) = 'D';
    elseif L==5
       c(i) = 'E';
    elseif L==6
       c(i) = 'F';
    elseif L==7
       c(i) = 'G';
    elseif L==8
       c(i) = 'H';
    elseif L==9
       c(i) = 'I';
    elseif L==10
       c(i) = 'J';
    elseif L==11
       c(i) = 'K';
    elseif L==12
       c(i) = 'L';
    elseif L==13
       c(i) = 'M';
    elseif L==14
       c(i) = 'N';
    elseif L==15
       c(i) = 'O';
    elseif L==16
       c(i) = 'P';
    elseif L==17
       c(i) = 'Q';
    elseif L==18
       c(i) = 'R';
    elseif L==19
       c(i) = 'S';
    elseif L==20
       c(i) = 'T';
    elseif L==21
       c(i) = 'U';
    elseif L==22
       c(i) = 'V';
    elseif L==23
       c(i) = 'W';
    elseif L==24
       c(i) = 'X';
    elseif L==25
       c(i) = 'Y';
    elseif L==26
       c(i) = 'Z';
    end
end
c = char(c);

%Identificação dos números da placa
for i = 1:size(temp_numero,2)
    
    N = temp_numero(1,i);
     if mean2(max(cc_luz))>mean2(max(cc))
       N = temp_numero_luz(1,i);
    end
    %números
    if     N==1
       n(i) = '0';
    elseif N==2
       n(i) = '1';
    elseif N==3
       n(i) = '2';
    elseif N==4
       n(i) = '3';
    elseif N==5
       n(i) = '4';
    elseif N==6
       n(i) = '5';
    elseif N==7
       n(i) = '6';
    elseif N==8
       n(i) = '7';
    elseif N==9
       n(i) = '8';
    elseif N==10
       n(i) = '9';
    end
   
end


n = char(n);
w = '-';
PLACA = [c w n];

errordlg(PLACA,'Sua Placa é')