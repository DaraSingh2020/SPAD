% convolution filter and multiple CPUs and gpuArray

close all
clc
clear all
warning off
tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   root directories

%rootDirectory='F:\Test_Data_SPAD_Dec9th2021\output_images';  %Item1

%Item2: 
%Mouse data a acquired late in late december 2021
%rootDirectory='F:\11_GatedMode_Ligation_P600mw_exp5.36_31nsOff_18psdelay_F11_mouse_Pol_NOConcave_Pellicle_ZoomedIn_Withpad\1_BL\output_imagesBL';

%item3:
% phantom

%rootDirectory='F:\test_Phantom_MultipleBatches_GatedMode_01102021\7_P400mw_exp5.36_31nsOff_18psdelay_F11bw22_Ph_MultipleBatches_Pol_NOConcave_Pellicle_ZoomedIn_Withpad\output_imagesTrianglePhan';


%Item4: 
% Mouse data acquired on January 18th 2022

rootDirectory='F:\11_GatedMode_Ligation_P600mw_exp5.36_31nsOff_18psdelay_F11_mouse_Pol_NOConcave_Pellicle_ZoomedIn_Withpad\1_BL\output_imagesBL';
imagePrifix='image_';  

%% Outlier corrector

% firstImageDir=strcat(rootDirectory,num2str(1),'\',imagePrifix,num2str(1),'.tiff');
% imageFirst=gpuArray(single(imread(firstImageDir)));
% imageInOneColumn=reshape(imageFirst,[],1);
% Outliers = prctile(imageInOneColumn,[0.5 99.5]);
% maskNonOutliers = imageFirst>Outliers(2);
% outlierConvolver=ones(3,'gpuArray')/9;


%% for selecting image numbers changes the below variables

jj=5;
% change numbers to jj for the test

fileN1=jj;  %default 0 for image number 1
fileN2=jj;  %change it to 19 to get LSCI of the first 20 images
fileLength=fileN2-fileN1+1;
%
%% for selecting folder numbers changes the below variables
folderN1=1;
folderN2=80;
folderLenght=folderN2-folderN1+1;
fileQuantity=fileLength*folderLenght;
%% reading image directories
imageNames=strings(1,fileQuantity);
i=0;

for folderNumber=folderN1:folderN2
    folderName=strcat(rootDirectory,num2str(folderNumber),'\');
    for fileNumber=fileN1:fileN2
        i=i+1;
        imageNames(i)=strcat(folderName,imagePrifix,num2str(fileNumber),'.tiff');
    end
end

%% Create an empty holder for the final image and select the window size

X=double(imread(imageNames(1)))*0;
WindowSize=7;
Kernel=ones(WindowSize,WindowSize)/WindowSize^2;

WindowSize1=9;
outlierConvolver=ones(WindowSize1,WindowSize1,'gpuArray')/WindowSize1^2;

%% Running the parfor-loop

parfor counter=1:fileQuantity
    
    image = double(imread(imageNames(counter)));
    
    imageInOneColumn=reshape(image,[],1);
    Outliers = prctile(imageInOneColumn,[0.5 99.0]);
    maskNonOutliers = image>Outliers(2);
    
    
    imageCopySmoothened=conv2(image,outlierConvolver,'same');
    image(maskNonOutliers)=imageCopySmoothened(maskNonOutliers);
    
    imageSquareMean=conv2(image.^2,Kernel,'same');
    imageMean=conv2(image,Kernel,'same');
    imageMeanSquare=imageMean.^2;
    Iout=sqrt(abs(imageSquareMean-imageMeanSquare))./imageMean;
    X=X+Iout;   
end

kMean2D = X/fileQuantity;
flow = 1./kMean2D.^2;
normalizedFlow=(flow/mean2(flow));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%copy of lines 22-80
%%%%%%%%%%%%%%%%%%%%


%% for selecting image numbers changes the below variables

kk=jj+1;
% change numbers to jj for the test

fileN1=kk;  %default 0 for image number 1
fileN2=kk;  %change it to 19 to get LSCI of the first 20 images
fileLength=fileN2-fileN1+1;
%
%% for selecting folder numbers changes the below variables
folderN1=1;
folderN2=80;
folderLenght=folderN2-folderN1+1;
fileQuantity=fileLength*folderLenght;
%% reading image directories
imageNames=strings(1,fileQuantity);
i=0;

for folderNumber=folderN1:folderN2
    folderName=strcat(rootDirectory,num2str(folderNumber),'\');
    for fileNumber=fileN1:fileN2
        i=i+1;
        imageNames(i)=strcat(folderName,imagePrifix,num2str(fileNumber),'.tiff');
    end
end

%% Create an empty holder for the final image and select the window size

X=double(imread(imageNames(1)))*0;
WindowSize=7;
Kernel=ones(WindowSize,WindowSize)/WindowSize^2;

WindowSize1=9;
outlierConvolver=ones(WindowSize1,WindowSize1,'gpuArray')/WindowSize1^2;

%% Running the parfor-loop

parfor counter=1:fileQuantity
    
    image = double(imread(imageNames(counter)));
    
    imageInOneColumn=reshape(image,[],1);
    Outliers = prctile(imageInOneColumn,[0.5 99.0]);
    maskNonOutliers = image>Outliers(2);
    
    
    imageCopySmoothened=conv2(image,outlierConvolver,'same');
    image(maskNonOutliers)=imageCopySmoothened(maskNonOutliers);
    
    imageSquareMean=conv2(image.^2,Kernel,'same');
    imageMean=conv2(image,Kernel,'same');
    imageMeanSquare=imageMean.^2;
    Iout=sqrt(abs(imageSquareMean-imageMeanSquare))./imageMean;
    X=X+Iout;   
end

kMean2D = X/fileQuantity;
flow = 1./kMean2D.^2;
normalizedFlow1=(flow/mean2(flow));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
figure(1)
imagesc(normalizedFlow)
TT1=strcat('T',num2str(jj),' :averaged over image number: ',num2str(jj),' of ',num2str(folderN2),' Phantom');
TT2=strcat('Image_',num2str(jj),'_Averaged',num2str(jj),'_Of_',num2str(folderN2),'_FoldersBL')
title(TT1)
colormap default
%caxis([0 10.0]);
colorbar
figureName1=TT2
saveas(gcf,figureName1);
pngFigureName=strcat(TT2,'.png')
saveas(gcf,pngFigureName);
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This is for test:
% figure(2)
% threshhold=1;
% [gradient_X,gradient_Y,maxIndex,originalImageWithMax]=verticleLineWithMaxGradient(normalizedFlow,threshhold);
% 
% 
% 
% imshow(originalImageWithMax);
% 
% TT1=strcat('T',num2str(jj),' :averaged over image number: ',num2str(jj),' of ',num2str(folderN2),' Phantom');
% TT2=strcat('Image_',num2str(jj),'_Averaged',num2str(jj),'_Of_',num2str(folderN2),'_FoldersBL')
% TT3=strcat(num2str(maxIndex),' has the maximum horizontal gradient')
% xlabel(TT3)
% title(TT1)
% colormap default
% %caxis([0 10.0]);
% colorbar
% figureName1=TT2
%saveas(gcf,figureName1);
% pngFigureName=strcat(TT2,'.png')
% saveas(gcf,pngFigureName);
%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2)
threshhold=1;

imageWithMax=verticleLineWithCleaning(normalizedFlow,threshhold);
imshow(imageWithMax);
TT1=strcat('T',num2str(jj),' :averaged over image number: ',num2str(jj),' of ',num2str(folderN2),' Phantom');
TT2=strcat('Image_',num2str(jj),'_Averaged',num2str(jj),'_Of_',num2str(folderN2),'_FoldersBL V_line_360')
TT3=strcat('The line at pixels: 360 has the max horizontal gradient in image 1')
xlabel(TT3)
title(TT1)
colormap default
%caxis([0 10.0]);
colorbar
figureName1=TT2
saveas(gcf,figureName1);
pngFigureName=strcat(TT2,'.png')
saveas(gcf,pngFigureName);

toc