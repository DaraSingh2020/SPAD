% convolution filter and multiple CPUs and gpuArray

close all
clc
clear all
warning off
tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%rootDirectory='F:\Test_Data_SPAD_Dec9th2021\output_images';

%LSCI for Faraneh
%rootDirectory='F:\test_9weekmouse_1stmouse_LSCI_publication_SPAD_sharedpath_polarizer_zoomedIn_01182022\LSCI\1_P400mw_exp5_Intensity_F8_mouse_Pol_NOConcave_Pellicle_ZoomedIn_Withpad';



imagePrifix='image_';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% for selecting image numbers changes the below variables
fileN1=0;
fileN2=19;
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

X=double(gpuArray(imread(imageNames(1))))*0;
WindowSize=7;
Kernel=ones(WindowSize,WindowSize,'gpuArray')/WindowSize^2;

%% Running the parfor-loop

parfor counter=1:fileQuantity
    
    image = double(gpuArray(imread(imageNames(counter))));
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