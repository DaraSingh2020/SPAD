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
maxFileNumber=1500;
if length(file)>maxFileNumber
    file=file(1:maxFileNumber);
end


fileName     = strcat(path,file);
splittedPath = strsplit(path,'\');
fileQuantity   = size(fileName,2);


    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This section only shows the raw image. Not really important in
% calculations. You may comment it out. I have used it to verify my code to
% read the address.

image = imread(fileName{1,50});
adjustedImage=imadjust(image);
image=double(image);
figure(1)
imshow(adjustedImage)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imageGPU=double(gpuArray(image));
X=imageGPU*0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checking boxcox parameters
XX=imageGPU*0;

parfor counter=1:fileQuantity
    image = double(gpuArray(imread(fileName{1,counter})));
    XX=XX+image;   
end
imageMean = XX/fileQuantity;
imageM=reshape(imageMean,[],1);

[transdat,lambda] = boxcox(imageM);
disp(['The BoxCox transformation parameter is:',num2str(lambda)]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WindowSize=7;

Kernel=ones(WindowSize,WindowSize,'gpuArray')/WindowSize^2;

parfor counter=1:fileQuantity
    
    image = double(gpuArray(imread(fileName{1,counter})));
    % transformation start
    image = (image.^lambda-1)/lambda;
    % transformation end
    imageSquareMean=conv2(image.^2,Kernel,'same');
    imageMean=conv2(image,Kernel,'same');
    imageMeanSquare=imageMean.^2;
    Iout=sqrt(abs(imageSquareMean-imageMeanSquare))./imageMean;
    X=X+Iout;   
end

kMean2D = X/fileQuantity;
flow = 1./kMean2D.^2;
normalizedFlow=(flow/mean2(flow))';
  
%%
figure(2)
imagesc(normalizedFlow)
titleString=strcat('Normalized flow. No. of images:',num2str(fileQuantity),' images: Ligation Right Release');
title(titleString)
colormap default
caxis([0.7 2.5]);
colorbar
figureName = strcat('LSCI_',num2str(fileQuantity),'_Images_BoxCoxLig_RightRelease_.png');
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