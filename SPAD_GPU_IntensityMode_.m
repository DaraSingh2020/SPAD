% Intensity mode has only one directory. All image are in one folder.
% Therefore there is only one folder
%
% SPAD camera has a lot of faulty pixels. In this algorithm, 7by7,5by5 and 
% 3by3 images are reconstructed. Next, median filter is used on the 3by3
% image. Then this modified 3by3 image is used to get rid of faulty pixels
% in 7by7 or 5by5 images.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clc
clear all
warning off
tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% There is only one folder. So choose the files
[file,path] = uigetfile('F:\*.tiff', 'MultiSelect','on');
splittedPath=strsplit(path,'\');
temporaryFolder_=cell2mat(splittedPath(end-1)); % This is different for intensity mode
temporaryFolder=strcat(temporaryFolder_(1:10),'_Intensity_Results');

fileN_Start=1;
fileN_End=length(file);
fileN_End=40;
imageNumber=fileN_End-fileN_Start+1;
currentFolder=pwd;
mkdir(temporaryFolder)
cd(strcat(currentFolder,'\',temporaryFolder))
rotateImage=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxValue=120;
minValue=50;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Choose the right directory
%Item:1
%rootDirectory='F:\test_9weekmouse_1stmouse_LSCI_publication_SPAD_sharedpath_polarizer_zoomedIn_01182022\4_P200mw_exp5_Intensity_F11_mouse_Pol_NOConcave_Pellicle_ZoomedIn_Withpad';
%rootDirectory='F:\test_9weekmouse_1\4_P200mw_exp5_Intensity_F11_mouse_Pol_NOConcave_Pellicle_ZoomedIn_Withpad';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% February 9th 2022 experiment
% Mouse1, Step2
%rootDirectory='F:\SPAD_Mouse_2_10_2022\1stMouse_Data\4_P200mw_exp5_Intensity_F11_B4_CO2';

% Mouse1, Step4
%rootDirectory='F:\SPAD_Mouse_2_10_2022\1stMouse_Data\6_P200mw_exp5_Intensity_F11_B4_After_CO2';

% Mouse1, Step6
%rootDirectory='F:\SPAD_Mouse_2_10_2022\1stMouse_Data\7_P200mw_exp5_Intensity_F11_B4_b4_Ligation_AfterSurgery_b4TakingLigation';

%Mouse2,Step1
%rootDirectory='F:\SPAD_Mouse_2_10_2022\2ndMouse_Data\7_P120mw_exp5_Intensity_F11_FOVadjustment_zoomedIn_1k';

%Mouse2,Step4
%rootDirectory='F:\SPAD_Mouse_2_10_2022\2ndMouse_Data\10_P120mw_exp5_Intensity_F11_After_CO2_zoomedIn_1k';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Folder11
%rootDirectory='F:\test_UKshape_Phantom_SPAD_02182022\11_P1w_exp5_Intensity_F11_roughSurfTop_1mm';

%rootDirectory='F:\test_UKshape_Phantom_SPAD_02182022\14_P1w_exp5_Intensity_F11_roughSurfbottom_2ndPhantomBrightSurface_1mm_afterPolish';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This section only shows the raw image. Not really important in
% calculations. You may comment it out. I have used it to verify my code to
% read the address.

imageName=strcat(path,cell2mat(file(1,fileN_Start)));
image=imread(imageName);
adjustedImage=imadjust(image);
image=double(image);
figure(1)
if rotateImage==1
    adjustedImage=adjustedImage';
end
imshow(adjustedImage)
pngFigureName=strcat('RawImage_1.png');
saveas(gcf,pngFigureName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Don't touch the 3by3 window variables
windowSize_3by3=3;
Kernel_3by3=ones(windowSize_3by3,windowSize_3by3,'gpuArray')/windowSize_3by3^2;

windowSize_5by5=5;
Kernel_5by5=ones(windowSize_5by5,windowSize_5by5,'gpuArray')/windowSize_5by5^2;

windowSize_7by7=7;
Kernel_7by7=ones(windowSize_7by7,windowSize_7by7,'gpuArray')/windowSize_7by7^2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 X_7by7=double(gpuArray(image))*0;
 X_5by5=double(gpuArray(image))*0;
 X_3by3=double(gpuArray(image))*0;
 fileQuantity=fileN_End-fileN_Start+1;

parfor fileNumber=fileN_Start:fileN_End

    imageName=strcat(path,cell2mat(file(1,fileNumber)));
    image=double(imread(imageName));
%% Fixing the skewness: Optional and can be changed
    imageHelp=image;
    imageHelp=imageHelp/1024;
    imageHelp=1-imageHelp;
    image=log(imageHelp);
% Fixing the skewness ends here

     imageSquareMean_3by3=conv2(image.^2,Kernel_3by3,'same');
     imageSquareMean_5by5=conv2(image.^2,Kernel_5by5,'same');
     imageSquareMean_7by7=conv2(image.^2,Kernel_7by7,'same');
            
     imageMean_3by3=conv2(image,Kernel_3by3,'same');
     imageMean_5by5=conv2(image,Kernel_5by5,'same');
     imageMean_7by7=conv2(image,Kernel_7by7,'same');
            
     imageMeanSquare_3by3=imageMean_3by3.^2;
     imageMeanSquare_5by5=imageMean_5by5.^2;
     imageMeanSquare_7by7=imageMean_7by7.^2;
            
     Iout_3by3=sqrt(abs(imageSquareMean_3by3-imageMeanSquare_3by3))./imageMean_3by3;
     Iout_5by5=sqrt(abs(imageSquareMean_5by5-imageMeanSquare_5by5))./imageMean_5by5;
     Iout_7by7=sqrt(abs(imageSquareMean_7by7-imageMeanSquare_7by7))./imageMean_7by7;
            
            
            
     X_3by3=X_3by3+Iout_3by3;
     X_5by5=X_5by5+Iout_5by5;
     X_7by7=X_7by7+Iout_7by7;
end


    Kmean_2D_7by7=X_7by7/fileQuantity;
    flow_7by7 = 1./Kmean_2D_7by7.^2;
    
    Kmean_2D_5by5=X_5by5/fileQuantity;
    flow_5by5 = 1./Kmean_2D_5by5.^2;
    
    Kmean_2D_3by3=X_3by3/fileQuantity;
    flow_3by3 = 1./Kmean_2D_3by3.^2;
%normalizedFlow=(flow/mean2(flow));
    if rotateImage==1
        nFlow_7by7=rot90(flow_7by7,1);
        nFlow_5by5=rot90(flow_5by5,1);
        nFlow_3by3=rot90(flow_3by3,1);
    else
        nFlow_7by7=flow_7by7;
        nFlow_5by5=flow_5by5; 
        nFlow_3by3=flow_3by3;
    end
%normalizedFlow_3by3=(flow_3by3/mean2(flow_3by3));    

    exportImageSize=size(nFlow_3by3);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % 7 by 7 raw
% figure(2)
% set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
% imagesc(nFlow_7by7)
% colormap jet
% 
% caxis([minValue maxValue]);
% colorbar
imageTitle=strcat('Intensity mode averaged over',num2str(fileQuantity),' images, window:[',num2str(windowSize_7by7),' ,',num2str(windowSize_7by7), ']');
%title(imageTitle)
FigureName=strcat('rCBF_image',num2str(imageNumber));
FigureName_=strcat(FigureName,'_',num2str(windowSize_7by7),'by',num2str(windowSize_7by7));
% pngFigureName=strcat(FigureName_,'.png');
% %saveas(gcf,pngFigureName);
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%  % 5 by 5 raw 
% figure(3)
% set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
% imagesc(nFlow_5by5)
% colormap jet
% caxis([minValue maxValue]);
% colorbar
% imageTitle=strcat('Intensity mode averaged over',num2str(fileQuantity),' images, window:[',num2str(windowSize_5by5),' ,',num2str(windowSize_5by5), ']');
% title(imageTitle)
% FigureName=strcat('rCBF_image',num2str(imageNumber));
% FigureName_=strcat(FigureName,'_',num2str(windowSize_5by5),'by',num2str(windowSize_5by5));
% pngFigureName=strcat(FigureName_,'.png');
% %saveas(gcf,pngFigureName);
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure(4)
% set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
% imagesc(nFlow_3by3)
% colormap jet
% caxis([minValue maxValue]);
% colorbar
% imageTitle=strcat('Intensity mode averaged over',num2str(fileQuantity),' images, window:[',num2str(windowSize_3by3),' ,',num2str(windowSize_3by3), ']');
% title(imageTitle)
% FigureName_=strcat(FigureName,'_',num2str(windowSize_3by3),'by',num2str(windowSize_3by3));
% pngFigureName_3by3=strcat(FigureName_,'_3by3.png');
% %saveas(gcf,pngFigureName_3by3);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% nFlow_3by3_Median=medfilt2(nFlow_3by3,[3 3]);
% figure(5)
% set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
% imagesc(nFlow_3by3_Median)
% colormap jet
% caxis([minValue maxValue]);
% colorbar
% imageTitle=strcat('Intensity mode averaged over',num2str(fileQuantity),' images, window:[',num2str(windowSize_3by3),' ,',num2str(windowSize_3by3), '] Median');
% title(imageTitle)
% FigureName_=strcat(FigureName,'_',num2str(windowSize_3by3),'by',num2str(windowSize_3by3));
% pngFigureName_3by3_Median=strcat(FigureName_,'_3by3_Median.png');
% %saveas(gcf,pngFigureName_3by3_Median);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% normalizedFlowHelp=nFlow_3by3_Median;    
% pixelsForChanging=normalizedFlowHelp*0.8>nFlow_7by7;    
% nFlow_7by7(pixelsForChanging)=normalizedFlowHelp(pixelsForChanging);
% figure(6)
% set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
% imagesc(nFlow_7by7)
% colormap jet
% caxis([minValue maxValue]);
% colorbar
% imageTitle=strcat('Intensity mode averaged over',num2str(fileQuantity),' images, window:[',num2str(windowSize_7by7),' ,',num2str(windowSize_7by7), '], New Filter');
% title(imageTitle)
% FigureName_=strcat(FigureName,'_',num2str(windowSize_7by7),'by',num2str(windowSize_7by7));
% pngFigureName_NewFilter=strcat(FigureName_,'_NewFilter.png');
%saveas(gcf,pngFigureName_NewFilter);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
max_nFlow_5by5=max(max(nFlow_5by5))
nFlow_5by5_Median5=medfilt2(nFlow_5by5,[5 5]);

bottomPixels=nFlow_5by5<max_nFlow_5by5/1.7;
highRatioPixels=nFlow_5by5_Median5*0.90>nFlow_5by5;

for ii=1:10  
    nFlow_5by5_Median5=medfilt2(nFlow_5by5,[5 5]);
    highRatioPixels=nFlow_5by5_Median5*0.80>nFlow_5by5;
    nFlow_5by5(bottomPixels & highRatioPixels)=nFlow_5by5_Median5(bottomPixels & highRatioPixels);
end

bottomPixels=nFlow_5by5<max_nFlow_5by5/3;

for ii=1:10  
    nFlow_5by5_Median9=medfilt2(nFlow_5by5,[9 9]);
    highRatioPixels=nFlow_5by5_Median9*0.90>nFlow_5by5;
    nFlow_5by5(bottomPixels & highRatioPixels)=nFlow_5by5_Median9(bottomPixels & highRatioPixels);
end

figure(7)
set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
imagesc(nFlow_5by5)
colormap jet
caxis([minValue maxValue]);
colorbar
imageTitle=strcat('Intensity Total',num2str(fileQuantity),' images, window:[',num2str(windowSize_5by5),' ,',num2str(windowSize_5by5), '], New Filter');
title(imageTitle)
FigureName_=strcat(FigureName,'_',num2str(windowSize_5by5),'by',num2str(windowSize_5by5));
pngFigureName_NewFilter=strcat(FigureName_,'_NewFilter.png');
saveas(gcf,pngFigureName_NewFilter);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

max_nFlow_3by3=max(max(nFlow_3by3))
nFlow_3by3_Median3=medfilt2(nFlow_3by3,[3 3]);

bottomPixels=nFlow_3by3<max_nFlow_3by3/1.7;
highRatioPixels=nFlow_3by3_Median3*0.90>nFlow_3by3;

for ii=1:5  
    nFlow_3by3_Median3=medfilt2(nFlow_3by3,[3 3]);
    highRatioPixels=nFlow_3by3_Median3*0.80>nFlow_3by3;
    nFlow_3by3(bottomPixels & highRatioPixels)=nFlow_3by3_Median3(bottomPixels & highRatioPixels);
end

bottomPixels=nFlow_3by3<max_nFlow_3by3/3;

for ii=1:5  
    nFlow_3by3_Median7=medfilt2(nFlow_3by3,[7 7]);
    highRatioPixels=nFlow_3by3_Median7*0.90>nFlow_3by3;
    nFlow_3by3(bottomPixels & highRatioPixels)=nFlow_3by3_Median7(bottomPixels & highRatioPixels);
end


figure(8)
set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
imagesc(nFlow_3by3)
colormap jet
caxis([minValue maxValue]);
colorbar
imageTitle=strcat('Intensity Total:',num2str(fileQuantity),' images, window:[',num2str(windowSize_3by3),' ,',num2str(windowSize_3by3), '], New Filter');
title(imageTitle)
FigureName_=strcat(FigureName,'_',num2str(windowSize_3by3),'by',num2str(windowSize_3by3));
pngFigureName_NewFilter=strcat(FigureName_,'_NewFilter.png');
saveas(gcf,pngFigureName_NewFilter);



toc