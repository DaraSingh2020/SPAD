% Dara August 20th 2021. Modification of original LSCI code using
% convolution filter and multiple CPUs and gpuArray

close all
clc
clear all
warning off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reading the images by pop up window
[file,path] = uigetfile('*.tiff', 'MultiSelect', 'on');

tic;
fileName     = strcat(path,file);
splittedPath = strsplit(path,'\');
fileQuanty   = size(fileName,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This section only shows the raw image. Not really important in
% calculations. You may comment it out. I have used it to verify my code to
% read the address.

image = imread(fileName{1,1});
adjustedImage=imadjust(image);
image=double(image);
figure(1)
imshow(adjustedImage)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imageGPU=double(gpuArray(image));
X=imageGPU*0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WindowSize=7;
Kernel=ones(WindowSize,WindowSize,'gpuArray')/WindowSize^2;

parfor counter=1:fileQuanty
    
    image = double(gpuArray(imread(fileName{1,counter})));

    
    %image= log(image);
    imageSquareMean=conv2(image.^2,Kernel,'same');
    imageMean=conv2(image,Kernel,'same');
    imageMeanSquare=imageMean.^2;
    Iout=sqrt(abs(imageSquareMean-imageMeanSquare))./imageMean;
    X=X+Iout;   
end

kMean2D = X/fileQuanty;
flow = 1./kMean2D.^2;
normalizedFlow=(flow/mean2(flow))';
  
%%
figure(2)
imagesc(normalizedFlow)
titleString=strcat('Normalized flow. No. of images:',num2str(fileQuanty),' images');
title(titleString)
colormap default
caxis([0.75 3.0]);
colorbar
figureName = strcat('LSCI_',num2str(fileQuanty),'_Images.png');
saveas(gcf,figureName);

%%
%flow = 1./Kmean_2D(:,:).^2;
% figure(2)
% imagesc(flow)
% title('Not Normalized constructed image via LSCI')
% colormap default
% caxis([0 100.0]);
% colorbar
% figureName2 = strcat(splittedPath{end-1},'_Fig2.fig');
% saveas(gcf,figureName2);
toc
J = imnoise(normalizedFlow,'salt & pepper',0.5);
figure(3)
imagesc(J)
titleString=strcat('Normalized flow. No. of images:',num2str(fileQuanty),' images');
title(titleString)
colormap default
caxis([0.75 3.0]);
colorbar
figureName = strcat('LSCI_',num2str(fileQuanty),'_Images__.png');
saveas(gcf,figureName);

