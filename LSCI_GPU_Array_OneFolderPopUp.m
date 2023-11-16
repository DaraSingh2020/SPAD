% Dara August 20th 2021. Modification of original LSCI code using
% convolution filter and multiple CPUs and gpuArray

close all
clc
clear all
warning off


[file,path] = uigetfile('*.tiff', 'MultiSelect', 'on');

tic
fileName     = strcat(path,file);
splittedPath = strsplit(path,'\');
fileQuanty   = size(fileName,2);

m1 = 1080;  
m2= 1440;
X=zeros(m1,m2,'gpuArray');
WindowSize=7;

Kernel=ones(WindowSize,WindowSize,'gpuArray')/WindowSize^2;

parfor counter=1:fileQuanty
    
    image = double(gpuArray(imread(fileName{1,counter})));
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
figure(1)
imagesc(normalizedFlow)
title('Normalized constructed image via LSCI')
colormap default
caxis([0 2.0]);
colorbar
%figureName1 = strcat(splittedPath{end-1},'_Fig1Single.fig');
%saveas(gcf,figureName1);

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