%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Arin Can Ulku
%%% arin.ulku@epfl.ch
%%% EPFL, 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% modified by Siavash for contineous measurement determined by x1 (line 13) 
clear all
clc
close all
currentFolder=pwd;

delete([currentFolder '/output_images/*.tiff'])
for x1=1:5; 
% BEGIN user parameters

bits_10 = 1; % 1: 10-bit images, 0: 8-bit images
no_gate_pos = 200; % number of gate positions per gate set

% END user parameters

if bits_10==1
    no_gate_pos_m=(no_gate_pos*4);
else
    no_gate_pos_m=no_gate_pos;
end

disp('PROCESSING DATA...')

 %Sia- load([currentFolder '\raw_data\raw_data.mat'],'SS2_DATA');
 load([currentFolder '\raw_data',int2str(x1),'\raw_data.mat'] ,'SS2_DATA'); 
disp('GENERATING AND SAVING GATE IMAGES...')

tic

B=zeros(no_gate_pos_m,131072,'uint16');
A=zeros(no_gate_pos,256,512,'uint16');

for i=0:no_gate_pos_m-1
    B(i+1,:)=uint16(SS2_DATA(i*256*512+1:(i+1)*256*512));
end

j=0;

if bits_10==1
    for i=1:no_gate_pos_m
        i_str=int2str(i);
        j_str=int2str(j);
        for row = 1:256
            for col = 1:512
                temp=floor((col-1)/128);
                col1=4*(col-temp*128)-3+temp;
                A(j+1,row,col1) = A(j+1,row,col1) + B(i,(row-1)*512+col);
            end
        end
        if mod(i,4)==0
            j=j+1;
        end
    end

else
    for i=1:no_gate_pos_m
        i_str=int2str(i);
        for row = 1:256
            for col = 1:512
                temp=floor((col-1)/128);
                col1=4*(col-temp*128)-3+temp;
                A(i,row,col1) = B(i,(row-1)*512+col);
            end
        end
    end
end

for k=0:no_gate_pos-1
    k_str=int2str(k);
    % imwrite(squeeze(A(k+1,:,:)),[currentFolder '\output_images\image_' k_str '.tiff'],'Compression','none');
    mkdir(strcat(currentFolder, '\output_images',int2str(x1),'\'))
    imwrite(squeeze(A(k+1,:,:)),[currentFolder '\output_images',int2str(x1),'\image_' k_str '.tiff'],'Compression','none');
end

    toc
    disp(['GATE IMAGES SAVED.' 10])
beep
end
beep
disp('DONE.')