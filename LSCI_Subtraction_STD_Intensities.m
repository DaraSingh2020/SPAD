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

jj=1;
kk=jj+1;
% change numbers to jj for the test

fileN1_1=jj;  %default 0 for image number 1
fileN2_1=jj;  %change it to 19 to get LSCI of the first 20 images
fileLength=fileN2_1-fileN1_1+1;

fileN1_2=kk;  %default 0 for image number 1
fileN2_2=kk;  %change it to 19 to get LSCI of the first 20 images

%
%% for selecting folder numbers changes the below variables
folderN1=1;
folderN2=80;
folderLenght=folderN2-folderN1+1;
fileQuantity=fileLength*folderLenght;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reading image directories
% There are two sets of Images now.
imageNames_1=strings(1,fileQuantity);
i=0;
for folderNumber=folderN1:folderN2
    folderName=strcat(rootDirectory,num2str(folderNumber),'\');
    for fileNumber=fileN1_1:fileN2_1
        i=i+1;
        imageNames_1(i)=strcat(folderName,imagePrifix,num2str(fileNumber),'.tiff');
    end
end

imageNames_2=strings(1,fileQuantity);
i=0;
for folderNumber=folderN1:folderN2
    folderName=strcat(rootDirectory,num2str(folderNumber),'\');
    for fileNumber=fileN1_2:fileN2_2
        i=i+1;
        imageNames_2(i)=strcat(folderName,imagePrifix,num2str(fileNumber),'.tiff');
    end
end


%% Create an empty holder for the final image and select the window size

X=double(imread(imageNames_1(1)))*0;
WindowSize=7;
Kernel=ones(WindowSize,WindowSize)/WindowSize^2;

WindowSize1=9;
outlierConvolver=ones(WindowSize1,WindowSize1,'gpuArray')/WindowSize1^2;

%% Running the parfor-loop


subFactorConst=.1; %It can vary from zero to one.

for i=0:10
    subFactor=i*subFactorConst;
parfor counter=1:fileQuantity
    
    image_1 = double(imread(imageNames_1(counter)));
    image_2 = double(imread(imageNames_2(counter)));
    
    image=abs(image_2-image_1*subFactor);

    
    imageInOneColumn=reshape(image,[],1);
    Outliers = prctile(imageInOneColumn,[0.5 97.0]);
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
  
%%
figure(1)
imagesc(normalizedFlow)
TT1=strcat('[Image ',num2str(kk),' - (',num2str(subFactor),'*image',num2str(jj),')] Intensity averaged over ',num2str(folderN2),' foldersBL');
TT2=strcat('Image ',num2str(kk),'Minus',num2str(subFactor*1000),'By1000Ximage',num2str(jj),'Over',num2str(folderN2),'FoldersBL');
title(TT1)
colormap default
caxis([0 2.0]);
colorbar
figureName1=TT2
pngFigureName=strcat(TT2, '.png');
saveas(gcf,figureName1);
saveas(gcf,pngFigureName);

end

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