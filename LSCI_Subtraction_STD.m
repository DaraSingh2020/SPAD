% convolution filter and multiple CPUs and gpuArray

close all
clc
clear all
warning off
tic;
%rootDirectory='F:\Test_Data_SPAD_Dec9th2021\output_images';
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

for jj=0:50
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
TT1=strcat('T',num2str(jj),' :averaged over image number: ',num2str(jj),' of ',num2str(folderN2),' foldersBL');
TT2=strcat('Image_',num2str(jj),'_Averaged',num2str(jj),'_Of_',num2str(folderN2),'_Folders')
title(TT1)
colormap default
caxis([0 2.0]);
colorbar
figureName1=strcat('Image_',num2str(jj),'_Averaged',num2str(jj),'_Of_',num2str(folderN2),'_Folders_BL')
saveas(gcf,figureName1);
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