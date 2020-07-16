%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%----------------RECONHECIMENTO DE PLACAS DE AUTOMÓVEIS---------------%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Este programa visa fazer o reconhecimento do número em placas de
%automóveis

%Exemplo: Dada uma foto de um automóvel com a placa visível

%Resultado: Número inscrito da placa em formato de texto

clear
close all

carro = imread('ODR1828.jpeg');

%Carregando a imagem do automóvel
a = imread('ODR1828.jpeg');

% a = imread('luz\ODR1828.jpeg');

%Redimensionando a imagem a fim de caber na figura
b = imresize(a,[400 NaN]); %NaN mantém a proporção da imagem inicial


figure
imshow(b), title('Imagem Redimensionada da Imagem Original')

%Conversão da img redimensionada para níveis de cinza
g1 = rgb2gray(b); %uint8, 2 dimensões (x,y), níveis 0 a 255


figure
imshow(g1), title('Imagem em tons de cinza')


%threshold, intensidade acima de 50 vira 1 e abaixo vira 0

ajuste_sol = imsubtract(g1,50); %fotos com sol na placa
ajuste_sol = ajuste_sol>60; 

ajuste = g1>60; %para fotos com sombra na placa

figure
imshow(ajuste_sol), title('Ajuste de Instensidade na imagem sol na placa')

figure
imshow(ajuste), title('Ajuste de Instensidade na imagem sombra na placa')


%img negativa, complemento: 1 vira 0 e 0 vira 1
ajuste_inverso_sol = imcomplement(ajuste_sol);
ajuste_inverso = imcomplement(ajuste);

figure
imshow(ajuste_inverso_sol), title('Imagem Negativa Sol na Placa')

figure
imshow(ajuste_inverso), title('Imagem Negativa Sombra na Placa')

%determinando a resolução da imagem
[i j] = size(ajuste_inverso); %i=400 j=712

width =1/2*j;
hight = i-3/8*i; 

%recortando a imagem de um modo central, onde a placa se encontra
%imcrop(img,[xmin ymin width hight])
recorte = imcrop(ajuste_inverso,[1/4*j 3/8*i width hight]);
recorte_sol = imcrop(ajuste_inverso_sol,[1/4*j 3/8*i width hight]);


%%
%IDENTIFICAÇÃO DO FILTRO MAIS ADEQUADO SOBRE A FOTO

%Propiedades geométricas das regiões da imagem
Iprops_sol = regionprops(recorte_sol,'BoundingBox','Image');

%Localização das formas geométricas na imagem com sol sobre a placa
u = 1; xbox_sol = [0 0 0 0];
for n = 1:size(Iprops_sol,1)
    box_sol = Iprops_sol(n).BoundingBox;
    if box_sol(3)>2 && box_sol(3)<40 && box_sol(4)>10 && box_sol(4)<40 && box_sol(4)>box_sol(3)
       xbox_sol(u,:) = box_sol;
       u = u+1; %representa cada box da img
    end
end

%Propiedades geométricas das regiões da imagem
Iprops = regionprops(recorte,'BoundingBox','Image');

%Localização das formas geométricas na imagem com sombra sobre a placa
u = 1; xbox = [0 0 0 0];
for n = 1:size(Iprops,1)
    box = Iprops(n).BoundingBox;
    if box(3)>2 && box(3)<40 && box(4)>10 && box(4)<40 && box(4)>box(3)
       xbox(u,:) = box;
       u = u+1; %representa cada box da img
    end
end

%%
%LOCALIZAÇÃO DOS CARACTERES NA PLACA DO VEICULO

%Cálculo do ponto mediano (my), proporção altura e largura (razao) e as
%dimensões geométricas (xbox) de cada box dentro das especificações desejada

if size(xbox,1)>=7
    u = 1;
    for n = 1:size(Iprops,1)
        box = Iprops(n).BoundingBox;
        if box(3)>2 && box(3)<40 && box(4)>10 && box(4)<40 && box(4)>box(3)
           my(u,1) = 0.5*(2*box(2)+box(4));
           razao(u,:) = box(4)/box(3);
           xbox(u,:) = box;

           u = u+1; %representa cada box da img
        end
    end
end


if size(xbox_sol,1)>=7
    u = 1;
    for n = 1:size(Iprops_sol,1)
        box = Iprops_sol(n).BoundingBox;
        if box(3)>2 && box(3)<40 && box(4)>10 && box(4)<40 && box(4)>box(3)
           my_sol(u,1) = 0.5*(2*box(2)+box(4));
           razao_sol(u,:) = box(4)/box(3);
           xbox_sol(u,:) = box;

           u = u+1; %representa cada box da img
        end
    end
end

%Localização dos box que tenham pontos medianos próximos e quando um box é
%comparado a outros boxs, deve ser aproximadamente igual a 6 outros boxs
xbox2 = [0 0 0 0];

if size(xbox,1)>=7
    h = 0;
    u = 1;
    for n = 1:size(xbox,1)
       h = 0;
        for m = 1:size(xbox,1)
            if m~=n
              if abs(my(m)-my(n))>=0 && abs(my(m)-my(n))<15 
                   h = h+1;
              end
                  if h == 6
                    xbox2(u,:) = xbox(n,:);
                    u = u+1;
                  end
           end
        end
    end
end

xbox2_sol = [0 0 0 0];

if size(xbox_sol,1)>=7
    h = 0;
    u = 1;
    for n = 1:size(xbox_sol,1)
       h = 0;
        for m = 1:size(xbox_sol,1)
            if m~=n
              if abs(my_sol(m)-my_sol(n))>=0 && abs(my_sol(m)-my_sol(n))<15 
                   h = h+1;
              end
                  if h == 6
                    xbox2_sol(u,:) = xbox_sol(n,:);
                    u = u+1;
                  end
           end
        end
    end
end

%Matriz sem repetição das propiedades geométricas das boxs quem tenham pontos medianos
%próximos
if size(xbox,1)>=7 || size(xbox2,1)>=7
   xbox2 = unique(xbox2,'rows');
end

if size(xbox_sol,1)>=7 || size(xbox2_sol,1)>=7
   xbox2_sol = unique(xbox2_sol,'rows');
end

%Identificando a origem em x das boxs (ax), e a coordenada do final da box
%em x (dx) e a coordenada em y do canto inferior das boxs (pe)
if size(xbox,1)>=7 || size(xbox2,1)>=7
    u = 1;
    for n = 1:size(xbox2,1)
        box = xbox2(n,:);
        ax(u,1) = box(1);
        dx(u,1) = box(1)+box(3);
        pe(u,1) = box(2)+box(4);
        u = u+1;
    end
end

if size(xbox_sol,1)>=7 || size(xbox2_sol,1)>=7
    u = 1;
    for n = 1:size(xbox2_sol,1)
        box = xbox2_sol(n,:);
        ax_sol(u,1) = box(1);
        dx_sol(u,1) = box(1)+box(3);
        pe_sol(u,1) = box(2)+box(4);
        u = u+1;
    end
end
       
%Cálculo da distância entre os boxs em x (dx-ax), da diferença entre as alturas dos boxs (xbox2(n,4)-xbox2(m,4)),
% e a diferença entre os cantos inferiores dos boxs (pe(m)-pe(n)),
%Identificando as propriedas geométricas de cada box (xbox3)
%Enquadrando cada box que estejam dentro dos intervalos desejados
xbox3 = [0 0 0 0];
xb3 = [0 0 0 0]; 
if size(xbox,1)>=7 || size(xbox2,1)>=7
    h = 0; u = 1;
    for n = 1:size(xbox2,1)
        h = 0;
        for m = 1:size(xbox2,1)
            if m~=n
                if abs(dx(n)-ax(m))>=0 && abs(dx(n)-ax(m))<20 && abs(xbox2(n,4)-xbox2(m,4))>=0 && abs(xbox2(n,4)-xbox2(m,4))<=7 ...
                   && abs(pe(m)-pe(n))>=0 && abs(pe(m)-pe(n))<8
                   xbox3(u,:) = xbox2(n,:); xb3(u,:) = xbox2(m,:);
                   u = u+1;
                end
            end
        end
    end
end

xbox3_sol = [0 0 0 0];
xb3_sol = [0 0 0 0]; 
if size(xbox_sol,1)>=7 || size(xbox2_sol,1)>=7
    h = 0; u = 1;
    for n = 1:size(xbox2_sol,1)
        h = 0;
        for m = 1:size(xbox2_sol,1)
            if m~=n
                if abs(dx_sol(n)-ax_sol(m))>=0 && abs(dx_sol(n)-ax_sol(m))<20 && abs(xbox2_sol(n,4)-xbox2_sol(m,4))>=0 && abs(xbox2_sol(n,4)-xbox2_sol(m,4))<=7 ...
                   && abs(pe_sol(m)-pe_sol(n))>=0 && abs(pe_sol(m)-pe_sol(n))<8
                   xbox3_sol(u,:) = xbox2_sol(n,:); xb3_sol(u,:) = xbox2_sol(m,:);
                   u = u+1;
                end
            end
        end
    end
end

%Juntando todas as boxs da placa
if size(xbox,1)>=7 || size(xbox2,1)>=7 || size(xbox3,1)>=7
   xbox3 = [xbox3;xb3];
end

if size(xbox_sol,1)>=7 || size(xbox2_sol,1)>=7 || size(xbox3_sol,1)>=7
   xbox3_sol = [xbox3_sol;xb3_sol];
end

%Matriz sem repetição das propiedades geométricas das boxs da placa
if size(xbox,1)>=7 || size(xbox2,1)>=7 || size(xbox3,1)>=7
   xbox3 = unique(xbox3,'rows');
end

if size(xbox_sol,1)>=7 || size(xbox2_sol,1)>=7 || size(xbox3_sol,1)>=7
   xbox3_sol = unique(xbox3_sol,'rows');
end

%%
%AJUSTE DE BOXS PARAFUSADOS

%Esse loop só rodará caso o parafuso se junte ao caracter da placa
%Ajuste das dimensões dos boxs com parafusos
if size(xbox3,1)>=7
   for g = 1:size(xbox3,1)
        if xbox3(g,4)>=xbox3(4,4)+2 || xbox3(g,3)>=xbox3(1,3)+3

          %se a largura de qualquer box for maior que a largura do primeiro box
          %mais 3, ajuste da altura do box e identificação do box parafusado
          u = 1; parafuso = [0 0 0 0]; screw = 1;
          for n = 1:size(xbox3,1)
              if xbox3(n,3)>=xbox3(1,3)+3 || xbox3(n,4)>=xbox3(4,4)+3

                parafuso(u,:) = xbox3(n,:);
                screw(u,1) = n;
                xbox3(n,4) = xbox3(1,4);
                u = u+1;
              end
          end
                %Verificando se o box parafusado está invadindo o box do caracter anterior
                %Se positivo, ajuste da origem em x do box parafusado e de sua largura
                if parafuso ~= [0 0 0 0];
                    u = 1;
                    for n = 1:size(parafuso,1)
                        b = screw(n,1);
                        if parafuso(n,1) > xbox3(b-1,1) && parafuso(n,1) < xbox3(b-1,1)+xbox3(b-1,3)
                           q = b;
                           xbox3(q,1) = xbox3(q,1)+xbox3(q,3)-xbox(1,3); %deslocando a box para origem correta de x, box é deslocada para a direita
                           xbox3(q,3) = xbox3(1,3); %igualando a largura do primeiro caracter
                           xbox3(q,4) = xbox3(1,4); %igualando a altura do primeiro caracter
                        end
                    end
                end
                        %Verificando se o box parafusado está invadindo o box
                        %do caracter posterior
                        %Se positivo, ajuste da largura do box parafusado
                        u = 1;
                        for n = 1:size(parafuso,1)
                            b = screw(n,1);
                            if parafuso(n,1)+parafuso(n,3) >= xbox3(b+1,1) && parafuso(n,1)+parafuso(n,3) <= xbox3(b+1,1)+xbox3(b+1,3)
                               w = b;
                               xbox3(w,3) = xbox3(1,3); %igualando a largura do primeiro caracter
                               xbox3(w,4) = xbox3(1,4);  %igualando a altura do primeiro caracter
                            end
                        end

        end
    end
end

if size(xbox3_sol,1)>=7
   for g = 1:size(xbox3_sol,1)
        if xbox3_sol(g,4)>=xbox3_sol(4,4)+2 || xbox3_sol(g,3)>=xbox3_sol(1,3)+3

          %se a largura de qualquer box for maior que a largura do primeiro box
          %mais 3, ajuste da altura do box e identificação do box parafusado
          u = 1;
          for n = 1:size(xbox3_sol,1)
              if xbox3_sol(n,3)>=xbox3_sol(1,3)+3 || xbox3_sol(n,4)>=xbox3_sol(4,4)+3

                parafuso_sol(u,:) = xbox3_sol(n,:);
                screw_sol(u,1) = n;
                xbox3_sol(n,4) = xbox3_sol(1,4);
                u = u+1;
              end
          end
                %Verificando se o box parafusado está invadindo o box do caracter anterior
                %Se positivo, ajuste da origem em x do box parafusado e de sua largura
                u = 1;
                for n = 1:size(parafuso_sol,1)
                    b = screw_sol(n,1);
                    if parafuso_sol(n,1) >= xbox3_sol(b-1,1) && parafuso_sol(n,1) <= xbox3_sol(b-1,1)+xbox3_sol(b-1,3)
                       q = b;
                       xbox3_sol(q,1) = xbox3_sol(q,1)+xbox3_sol(q,3)-xbox_sol(1,3); %deslocando a box para origem correta de x, box é deslocada para a direita
                       xbox3_sol(q,3) = xbox3_sol(1,3); %igualando a largura do primeiro caracter
                       xbox3_sol(q,4) = xbox3_sol(1,4); %igualando a altura do primeiro caracter
                    end
                end
                        %Verificando se o box parafusado está invadindo o box
                        %do caracter posterior
                        %Se positivo, ajuste da largura do box parafusado
                        u = 1;
                        for n = 1:size(parafuso_sol,1)
                            b = screw_sol(n,1);
                            if parafuso_sol(n,1)+parafuso_sol(n,3) >= xbox3_sol(b+1,1) && parafuso_sol(n,1)+parafuso_sol(n,3) <= xbox3_sol(b+1,1)+xbox3_sol(b+1,3)
                               w = b;
                               xbox3_sol(w,3) = xbox3_sol(1,3); %igualando a largura do primeiro caracter
                               xbox3_sol(w,4) = xbox3_sol(1,4);  %igualando a altura do primeiro caracter
                            end
                        end

        end
    end
end

if size(xbox3,1)<size(xbox3_sol,1)
   xbox3 = xbox3_sol;
   recorte = recorte_sol;
   
   figure
   imshow(recorte_sol), title('Imagem Recortada Sol')
else
   figure
   imshow(recorte), title('Imagem Recortada Sombra')  
end

    
%%
%ENQUADRAMENTO SOBRE OS CARACTERES DA PLACA

%Propriedades geométricas dos caracteres (origem(x,y),largura e altura)
xbox3 = xbox3(:,1:4);

%Enquadramento final dos caracteres da placa
for m = 1:size(xbox3,1)
    rectangle('Position',[xbox3(m,1),xbox3(m,2),xbox3(m,3),xbox3(m,4)],'EdgeColor','g','LineWidth',2);
end

%%
%RECORTE DOS CARACTERES DA PLACA

%Recortar os caracteres enquadrados da placa e gravar em novas variáveis
t = 0;
for b = 1:size(xbox3,1)
       t = t+1;
       caixa = xbox3(b,:); %caixa(1), caixa(2) são as coordenadas x,y e caixa(3), caixa(4) são a largura e altura do retângulo
       eval(sprintf('char%d = recorte(caixa(2):caixa(2)+caixa(4),caixa(1):caixa(1)+caixa(3));',t));
end

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
%CORRELAÇÃO DOS TEMPLATES COM OS CARACTERES DA PLACA

%Função de correlação dos boxs de caracter da foto com os templates

%Correlação com as LETRAS da placa
u = 0;
for n = 1:3 %letras na placa
    u = 0;
    for m = 11:n_templates %template só letras
        u = u+1;
         eval(sprintf('letra = char%d;',n) );
        [l c] = size(letra);
        
        eval( sprintf('temp = imresize(template%d,[l c]);',m) );
        cc_letras(u,n) = corr2(temp,letra);
    end  %linha de cc = template, coluna de cc = box de letra da foto
end

%Verificar as máximas correlações de cada letra da placa

%Máximas correlações de cada box de letra com template
[max_cc_letras,max_index_letras] = max(cc_letras);

%Coordenadas dos cc máximos, numero do template e numero do box
temp_letra = max_index_letras; %1 a 26 letras, A...Z
caixa_letra = 1:size(cc_letras,2);

%Correlação com os NÚMEROS da placa
u = 0;
for n = 4:7 %número na placa (foto)
    u = u+1;
    for m = 1:10 %template só com números
        eval(sprintf('num = char%d;',n) );
        [l c] = size(num);
        
        eval( sprintf('temp = imresize(template%d,[l c]);',m) );
        cc_numeros(m,u) = corr2(temp,num);
        
    end  %linha de cc = template, coluna de cc = box de numero da foto
end

%Verificar as máximas correlações de cada número da placa

%Máximas correlações de cada box com template
[max_cc_num,max_index_num] = max(cc_numeros);

%Coordenadas dos cc máximos, numero do template e numero do box
temp_numero = max_index_num; %1 a 10, 0...9
caixa_numero = 1:size(cc_numeros,2);
%%
%CARREGANDO OS TEMPLATES DO LAYOUT FINAL NA PLACA

%Placa de plano de fundo
layout38 = imread('Layout/layout_placa.png');
%traço entre letras e números
layout37 = imread('Layout/tracinho.png');

%Carregando os Layouts Numéricos
layout1 = imread('Layout/0.png');layout2 = imread('Layout/1.png');layout3 = imread('Layout/2.png');
layout4 = imread('Layout/3.png');layout5 = imread('Layout/4.png');layout6 = imread('Layout/5.png');
layout7 = imread('Layout/6.png');layout8 = imread('Layout/7.png');layout9 = imread('Layout/8.png');
layout10 = imread('Layout/9.png');

%Carregando os Layouts Alfabéticos
layout11 = imread('Layout/A.png');layout12 = imread('Layout/B.png');layout13 = imread('Layout/C.png');
layout14 = imread('Layout/D.png');layout15 = imread('Layout/E.png');layout16 = imread('Layout/F.png');
layout17 = imread('Layout/G.png');layout18 = imread('Layout/H.png');layout19 = imread('Layout/I.png');
layout20 = imread('Layout/J.png');layout21 = imread('Layout/K.png');layout22 = imread('Layout/L.png');
layout23 = imread('Layout/M.png');layout24 = imread('Layout/N.png');layout25 = imread('Layout/O.png');
layout26 = imread('Layout/P.png');layout27 = imread('Layout/Q.png');layout28 = imread('Layout/R.png');
layout29 = imread('Layout/S.png');layout30 = imread('Layout/T.png');layout31 = imread('Layout/U.png');
layout32 = imread('Layout/V.png');layout33 = imread('Layout/W.png');layout34 = imread('Layout/X.png');
layout35 = imread('Layout/Y.png');layout36 = imread('Layout/Z.png');

%%
%FINAL: IDENTIFICAÇÃO DAS LETRAS E NÚMEROS NA PLACA

%Pesquisando as letras da placa
for i = 1:size(temp_letra,2)
    
    cx = caixa_letra(1,i);
       
    L = temp_letra(1,i);

    if L==2
       eval( sprintf('box_DB = char%d;',cx) ); 
       center_DB = size(box_DB)/2+.5;
       x = round(center_DB(1));
       y = round(center_DB(2));
       if box_DB(x,y) == 1
          c = layout12; %B
       else
          c = layout14; %D
       end
    end
    
      if L==15
      eval( sprintf('box_QO = char%d;',cx) ); 
      [lin_QO col_QO] = size(box_QO);
      linha_QO = round(0.75*lin_QO);
          
      box_QO = imcrop(box_QO,[1 linha_QO  lin_QO col_QO]);

      center_QO = size(box_QO)/2+.5;
      y = round(center_QO(2));
          if box_QO(1,y) == 1
              c = layout27; %Q
           else
              c = layout25; %O
          end
      end


    %alfabeto
    if    L==1
       c = layout11; %A
   elseif L==3
       c = layout13; %C
    elseif L==4
       c = layout14; %D
    elseif L==5
       c = layout15; %E
    elseif L==6
       c = layout16; %F
    elseif L==7
       c = layout17; %G
    elseif L==8
       c = layout18; %H
    elseif L==9
       c = layout19; %I
    elseif L==10
       c = layout20; %J
    elseif L==11
       c = layout21; %K
    elseif L==12
       c = layout22; %L
    elseif L==13
       c = layout23; %M
    elseif L==14
       c = layout24; %N
    elseif L==16
       c = layout26; %P
    elseif L==17
       c = layout27; %Q
    elseif L==18
       c = layout28; %R
    elseif L==19
       c = layout29; %S
    elseif L==20
       c = layout30; %T
    elseif L==21
       c = layout31; %U
    elseif L==22
       c = layout32; %V
    elseif L==23
       c = layout33; %W
    elseif L==24
       c = layout34; %X
    elseif L==25
       c = layout35; %Y
    elseif L==26
       c = layout36; %Z
    end
    eval(sprintf('c%d = c;',i));
end
%Letras da placa concatenados
ch = cat(2,c1,c2,c3);

%Pesquisando os números da placa
for i = 1:size(temp_numero,2)
    
    N = temp_numero(1,i);
    
    %números
    if     N==1
       n = layout1; %0
    elseif N==2
       n = layout2; %1
    elseif N==3
       n = layout3; %2
    elseif N==4
       n = layout4; %3
    elseif N==5
       n = layout5; %4
    elseif N==6
       n = layout6; %5
    elseif N==7
       n = layout7; %6
    elseif N==8
       n = layout8; %7
    elseif N==9
       n = layout9; %8
    elseif N==10
       n = layout10; %9
    end
   eval(sprintf('n%d = n;',i));
end
%Números da placa concatenados
num = cat(2,n1,n2,n3,n4);

tracinho = layout37;
%Caracteres concatenados
FINAL_PLATE = cat(2,ch,tracinho,num);

%Inserindo os templates dentro da placa personalizada
[height width rgbsize] = size(FINAL_PLATE);

plano_de_fundo = layout38; %placa de fundo

%Mostrando o resultado do layout final
plano_de_fundo(85:84+height,70:69+width,:) = FINAL_PLATE(:,:,:); 
% figure('name','after'); imshow(plano_de_fundo); 

subplot(1,2,1)
imshow(carro), title('Imagem Original')

subplot(1,2,2)
imshow(plano_de_fundo); title('PLACA FINAL')
