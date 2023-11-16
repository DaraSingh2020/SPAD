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
% Select folders and files on which the code should run. For a single image
% fileN_start should match the fileN_End variable. folders should be fixed
% only if you want to run a single image.
fileN_Start=0;
fileN_End=190;

folderN_Start=1;
folderN_End=40;
folderQuantity=folderN_End-folderN_Start+1;
rotateImage=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Choosing Folder #1
[file1,path1] = uigetfile('F:\*.tiff', 'MultiSelect','on');
splittedPath1=strsplit(path1,'\');
currentFolder=pwd;
temporaryFolder1_=cell2mat(splittedPath1(end-2));
temporaryFolder1=strcat(temporaryFolder1_(1:10),'_minus_prime_Results');
mkdir(temporaryFolder1)
cd(strcat(currentFolder,'\',temporaryFolder1))

pathCheck1=path1(1:end-2);
Flag=1;
while Flag==1
    if isnan(str2double(pathCheck1(end)))
        rootDirectory1=pathCheck1;
        Flag=0;
    else
        pathCheck1=pathCheck1(1:end-1);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Choosing Folder #2
[file2,path2] = uigetfile('F:\*.tiff', 'MultiSelect','on');
splittedPath2=strsplit(path2,'\');

temporaryFolder2_=cell2mat(splittedPath2(end-2));
%temporaryFolder2=strcat(temporaryFolder2_(1:10),'_delta_',num2str(delta),'_Results');
%mkdir(temporaryFolder)
%cd(strcat(currentFolder,'\',temporaryFolder))

pathCheck2=path2(1:end-2);
Flag=1;
while Flag==1
    if isnan(str2double(pathCheck2(end)))
        rootDirectory2=pathCheck2;
        Flag=0;
    else
        pathCheck2=pathCheck2(1:end-1);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Put the right directory here. image name will be modified with the image
% name prefix. remove the folder numbers. The code takes care of it.

%Item1:
%rootDirectory='F:\test_mouse_LSCI_publication_SPAD_sharedpath_polarizer_zoomedIne_01182022\2_P800mw_exp5.36_31nsOff_18psdelay_F11bw22_mouse_Pol_NOConcave_Pellicle_ZoomedIn_Withpad';
%rootDirectory='F:\test_mouse_LSCI_publication_SPAD\2_P800mw';

%item3: directory to phantom (January 12th scanned)
%rootDirectory='F:\test_Phantom_MultipleBatches_GatedMode_01102021\7_P400mw_exp5.36_31nsOff_18psdelay_F11bw22_Ph_MultipleBatches_Pol_NOConcave_Pellicle_ZoomedIn_Withpad\output_imagesTrianglePhan';


%item3: directory to phantom (January 18th scanned)
%rootDirectory='F:\test_9weekmouse_1stmouse_LSCI_publication_SPAD_sharedpath_polarizer_zoomedIn_01182022\5_P1w_exp5.36_31nsOff_18psdelay_F11_mouse_MultipleBatches_Pol_NOConcave_Pellicle_ZoomedIn_Withpad\output_imagesBLmo';

%item3: directory to phantom (January 18th scanned)
%rootDirectory='F:\test_9weekmouse_1\5_P1w_exp5.36_31nsOff_18psdelay_F11_mouse_MultipleBatches_Pol_NOConcave_Pellicle_ZoomedIn_Withpad\output_imagesBLmo';
%Item2:
%rootDirectory='F:\test_mouse_LSCI_publication_SPAD\5_P1w\output_imagesBLmo';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mouse1 on February 9th
%Mouse1,Step3 
%rootDirectory='F:\SPAD_Mouse_2_10_2022\1stMouse_Data\5_P800mw_exp5.36_31nsOff_18psdelay_F11_CO2_MultipleBatches\output_imagesCO';

%Mouse1,Step7
%rootDirectory='F:\SPAD_Mouse_2_10_2022\1stMouse_Data\8_P800mw_exp5.36_31nsOff_18psdelay_F11_Ligation_CA_MultipleBatches\output_imagesLig';

%Mouse2, Step3
%rootDirectory='F:\SPAD_Mouse_2_10_2022\2ndMouse_Data\9_P500mw_exp5.36_31nsOff_18psdelay_F11_CO2\output_images2ndmiceCO';

%Mouse2,Step7 
%rootDirectory='F:\SPAD_Mouse_2_10_2022\2ndMouse_Data\12_P500mw_exp5.36_31nsOff_18psdelay_F11_Ligation\output_images2ndmiceLigCA';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Phantom on February 18th

%Folder 10
%rootDirectory='F:\test_UKshape_Phantom_SPAD_02182022\10_P2w_exp5.36_31nsOff_18psdelay_F11_RoughTopOnlySolid_1mm_MultipleBatches\output_imagesUKZoomP2w1mm80folder';

%Folder 16
%rootDirectory='F:\test_UKshape_Phantom_SPAD_02182022\16_P2w_exp5.36_31nsOff_18psdelay_F4.5_RoughSurfbottom_2ndPhantomBrightSurface_Polish_1mm_MultipleBatches\output_imagesUKbrightTopPolishP2w1mm80folder';
%rootDirectory='F:\UKshape_Phantom_02182022\output_imagesUKZoomP2w1mm80folder';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UK Phantom 02/21/2022
%Folder 9
%rootDirectory='F:\test_PigletSkull_Phantom_SPAD_02212022\9_P1.5w_exp5.36_31nsOff_18psdelay_F11_UKphantom_NotFlip_NoConc_3cmWD_MultipleBatch80fol200fr\output_imagesUKph3cmNoConc15w80fol';
%Folder 8
%rootDirectory='F:\test_PigletSkull_Phantom_SPAD_02212022\8_P1.5w_exp5.36_31nsOff_18psdelay_F11_UKphantom_Flipped_WConc_thinLayerSiliconOnTop_13cmWD_MultipleBatch40fol200fr\output_imagesUKph13cmflipLayer15w20fol';
%Folder 7
%rootDirectory='F:\test_PigletSkull_Phantom_SPAD_02212022\7_P1w_exp5.36_31nsOff_18psdelay_F11_UKphantom_Flipped_WConc_thinLayerSiliconOnTop_13cmWD_MultipleBatch80fol200fr\output_imagesUKph13cmflipLayer1w80fol';
%Folder 3
%rootDirectory='F:\test_PigletSkull_Phantom_SPAD_02212022\3_P500mw_exp5.36_31nsOff_18psdelay_F11_pigletSkull_WConc_8cmWD_10fol200fr\output_imagespigskConc';
% Folder 2
%rootDirectory='F:\test_PigletSkull_Phantom_SPAD_02212022\2_P500mw_exp5.36_31nsOff_18psdelay_F11_pigletSkull_multipleBatch90fol200fr_NoConc_3cmWD\output_imagespigskull200fr';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%UK Phantom 2/22/2022 (Bright Color)
%Folder1
%rootDirectory='F:\test_UKPhantom_lowerOpticalProperties_Brighter_SPAD_02222022\1_P500mw_exp5.36_31nsOff_18psdelay_F11_UKphantom_LightColor_NoConc_3cmWD\output_imagesUKph3cmBrightNo05w';
%Folder2
%rootDirectory='F:\test_UKPhantom_lowerOpticalProperties_Brighter_SPAD_02222022\2_P1w_exp5.36_31nsOff_18psdelay_13.1nsGateLength_F11_UKphantom_LightColor_WConc_13cmWD\output_imagesUKph13cmBrightConc1w';
%Folder3
%rootDirectory='F:\test_UKPhantom_lowerOpticalProperties_Brighter_SPAD_02222022\3_P1w_exp5.36_31nsOff_18psdelay_10.8nsGateLength_F11_UKphantom_LightColor_WConc_13cmWD\output_imagesUKph13cmBrightConc1w10gl';

%Folder4
%rootDirectory='F:\test_UKPhantom_lowerOpticalProperties_Brighter_SPAD_02222022\4_P1.5w_exp5.36_31nsOff_18psdelay_10.8nsGateLength_F11_UKphantom_LightColor_WConc_heightRaised_17cmWD\output_imagesUKph17cmBrightConc1w10glHraise';
%Folder5
%rootDirectory='F:\test_UKPhantom_lowerOpticalProperties_Brighter_SPAD_02222022\5_P1.5w_exp5.36_31nsOff_18psdelay_13.1nsGateLength_F11_UKphantom_LightColor_WConc_heightRaised_17cmWD\output_imagesUKph17cmBrightConc15w13glHraise';
%Folder 6
%rootDirectory='F:\test_UKPhantom_lowerOpticalProperties_Brighter_SPAD_02222022\6_P1w_exp5.36_31nsOff_18psdelay_F11_UKph_LightColor_3mmSiliconOnTop_WConc_13cmWD\output_imagesUKph13cmBrightConc1wlayer';


imagePrefix='image_';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxValue=1.5;
minValue=0.05; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This section only shows the raw image. Not really important in
% calculations. You may comment it out. I have used it to verify my code to
% read the address.

imageNumber=fileN_Start;
folderNumber=1;

imageName1=strcat(rootDirectory1,num2str(folderNumber),'\',imagePrefix,num2str(imageNumber),'.tiff');
image1=imread(imageName1);
adjustedImage1=imadjust(image1);
image1=double(image1);
figure(1)
if rotateImage==1
    adjustedImage1=adjustedImage1';
end
imshow(adjustedImage1)
title('Phantom Image')
pngFigureName_NewFilter1=strcat('RawImage_Folder_Phantom.png');
saveas(gcf,pngFigureName_NewFilter1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This section only shows the raw image. Not really important in
% calculations. You may comment it out. I have used it to verify my code to
% read the address.

imageNumber=fileN_Start;
folderNumber=1;

imageName2=strcat(rootDirectory2,num2str(folderNumber),'\',imagePrefix,num2str(imageNumber),'.tiff');
image2=imread(imageName2);
adjustedImage2=imadjust(image2);
image2=double(image2);
figure(1)
if rotateImage==1
    adjustedImage2=adjustedImage2';
end
imshow(adjustedImage2)
title('Block Image')
pngFigureName_NewFilter2=strcat('RawImage_Folder_Block.png');
saveas(gcf,pngFigureName_NewFilter2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Don't touch the 3by3 window variables
windowSize_3by3=3;
Kernel_3by3=ones(windowSize_3by3,windowSize_3by3,'gpuArray')/windowSize_3by3^2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fun =@(X) std(X)./mean(X);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for fileNumber=fileN_Start:fileN_End
    % refreshing helper variables before each loop.
    X_3by3_0=double(gpuArray(image1))*0;
    X_3by3_1=double(gpuArray(image1))*0;
    X_3by3_d=double(gpuArray(image1))*0;
    
    fileQuantity=folderN_End-folderN_Start+1;
    imageNumber=fileNumber;
    
    parfor folderNumber=folderN_Start:folderN_End
        imageName_0=strcat(rootDirectory1,num2str(folderNumber),'\',imagePrefix,num2str(imageNumber),'.tiff');
        imageName_1=strcat(rootDirectory2,num2str(folderNumber),'\',imagePrefix,num2str(imageNumber),'.tiff');
        image_0=double(gpuArray(imread(imageName_0)));
        image_1=double(gpuArray(imread(imageName_1)));
        
%         image_0=image_0;
%         image_1=image_1;
        
%         image=log(image_0./image_1);

%% Fixing the skewness: Optional and can be changed
        image_0=pileUpCorrection(image_0);
        image_1=pileUpCorrection(image_1);
        image_d=image_0-image_1;

% Fixing the skewness ends here

            imageSquareMean_3by3_d=conv2(image_d.^2,Kernel_3by3,'same');
            imageSquareMean_3by3_0=conv2(image_0.^2,Kernel_3by3,'same');
            imageSquareMean_3by3_1=conv2(image_1.^2,Kernel_3by3,'same');
            
            imageMean_3by3_d=conv2(image_d,Kernel_3by3,'same');
            imageMean_3by3_0=conv2(image_0,Kernel_3by3,'same');
            imageMean_3by3_1=conv2(image_1,Kernel_3by3,'same');
            
            imageMeanSquare_3by3_d=imageMean_3by3_d.^2;
            imageMeanSquare_3by3_0=imageMean_3by3_0.^2;
            imageMeanSquare_3by3_1=imageMean_3by3_1.^2;
            
            Iout_3by3_d=sqrt(abs(imageSquareMean_3by3_d-imageMeanSquare_3by3_d))./imageMean_3by3_d;
            Iout_3by3_0=sqrt(abs(imageSquareMean_3by3_0-imageMeanSquare_3by3_0))./imageMean_3by3_0;
            Iout_3by3_1=sqrt(abs(imageSquareMean_3by3_1-imageMeanSquare_3by3_1))./imageMean_3by3_1;
            
            
            
            X_3by3_d=X_3by3_d+Iout_3by3_d;
            X_3by3_0=X_3by3_0+Iout_3by3_0;
            X_3by3_1=X_3by3_1+Iout_3by3_1;
        
    end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Kmean_2D_3by3_d=X_3by3_d/fileQuantity;
    flow_3by3_d = 1./Kmean_2D_3by3_d.^2;
    
    Kmean_2D_3by3_0=X_3by3_0/fileQuantity;
    flow_3by3_0 = 1./Kmean_2D_3by3_0.^2;
    
    Kmean_2D_3by3_1=X_3by3_1/fileQuantity;
    flow_3by3_1 = 1./Kmean_2D_3by3_1.^2;
%normalizedFlow=(flow/mean2(flow));
%normalizedFlow_3by3=(flow_3by3/mean2(flow_3by3));    


    if rotateImage==1
        nFlow_3by3_d=rot90(flow_3by3_d,1);
        nFlow_3by3_0=rot90(flow_3by3_0,1);
        nFlow_3by3_1=rot90(flow_3by3_1,1);
    else
        nFlow_3by3_d=flow_3by3_d;
        nFlow_3by3_0=flow_3by3_0; 
        nFlow_3by3_1=flow_3by3_1;
    end
    exportImageSize=size(nFlow_3by3_0);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 7 by 7 raw
% figure(2)
% set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
% imagesc(nFlow_7by7)
% colormap jet
% 
% caxis([minValue maxValue]);
% colorbar
imageTitle=strcat('Gated[',num2str(imageNumber),'] Total:',num2str(fileQuantity),' images, window:[',num2str(windowSize_3by3),' ,',num2str(windowSize_3by3), ']');
% title(imageTitle)
FigureName=strcat('rCBF_image',num2str(imageNumber));
FigureName_=strcat(FigureName,'_',num2str(windowSize_3by3),'by',num2str(windowSize_3by3));
% pngFigureName=strcat(FigureName_,'.png');
%saveas(gcf,pngFigureName);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
 % 5 by 5 raw 
% figure(3)
% set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
% imagesc(nFlow_5by5)
% colormap jet
% caxis([minValue maxValue]);
% colorbar
% imageTitle=strcat('Gated[',num2str(imageNumber),'] Total:',num2str(fileQuantity),' images, window:[',num2str(windowSize_5by5),' ,',num2str(windowSize_5by5), ']');
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
% imageTitle=strcat('Gated[',num2str(imageNumber),'] Total:',num2str(fileQuantity),' images, window:[',num2str(windowSize_3by3),' ,',num2str(windowSize_3by3), ']');
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
% imageTitle=strcat('Gated[',num2str(imageNumber),'] Total:',num2str(fileQuantity),' images, window:[',num2str(windowSize_3by3),' ,',num2str(windowSize_3by3), '] Median');
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
% imageTitle=strcat('Gated[',num2str(imageNumber),'] Total:',num2str(fileQuantity),' images, window:[',num2str(windowSize_7by7),' ,',num2str(windowSize_7by7), '], New Filter');
% title(imageTitle)
% FigureName_=strcat(FigureName,'_',num2str(windowSize_7by7),'by',num2str(windowSize_7by7));
% pngFigureName_NewFilter=strcat(FigureName_,'_NewFilter.png');
%saveas(gcf,pngFigureName_NewFilter);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% max_nFlow_5by5=max(max(nFlow_5by5))
% nFlow_5by5_Median5=medfilt2(nFlow_5by5,[5 5]);
% 
% bottomPixels=nFlow_5by5<max_nFlow_5by5/1.7;
% highRatioPixels=nFlow_5by5_Median5*0.8>nFlow_5by5;
% 
% for ii=1:10  
%     nFlow_5by5_Median5=medfilt2(nFlow_5by5,[5 5]);
%     highRatioPixels=nFlow_5by5_Median5*0.85>nFlow_5by5;
%     nFlow_5by5(bottomPixels & highRatioPixels)=nFlow_5by5_Median5(bottomPixels & highRatioPixels);
% end
% 
% bottomPixels=nFlow_5by5<max_nFlow_5by5/3;
% 
% for ii=1:10  
%     nFlow_5by5_Median9=medfilt2(nFlow_5by5,[9 9]);
%     highRatioPixels=nFlow_5by5_Median9*0.85>nFlow_5by5;
%     nFlow_5by5(bottomPixels & highRatioPixels)=nFlow_5by5_Median9(bottomPixels & highRatioPixels);
% end
% 
% % Normalized with respect to mean
% mean_5by5=mean(nFlow_5by5,'all');
% nFlow_5by5=nFlow_5by5./mean_5by5;
% 
% figure(7)
% set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
% imagesc(nFlow_5by5)
% colormap jet
% caxis([minValue maxValue]);
% colorbar
% imageTitle=strcat('delta-Gated[',num2str(imageNumber),'] Total:',num2str(fileQuantity),' images, window:[',num2str(windowSize_5by5),' ,',num2str(windowSize_5by5), '], New Filter');
% title(imageTitle)
% FigureName_=strcat(FigureName,'_',num2str(windowSize_5by5),'by',num2str(windowSize_5by5));
% pngFigureName_NewFilter=strcat(FigureName_,'_NewFilter.png');
% saveas(gcf,pngFigureName_NewFilter);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

max_nFlow_3by3_d=max(max(nFlow_3by3_d));
nFlow_3by3_Median3_d=medfilt2(nFlow_3by3_d,[3 3]);

bottomPixels_d=nFlow_3by3_d<max_nFlow_3by3_d/1.7;
highRatioPixels_d=nFlow_3by3_Median3_d*0.8>nFlow_3by3_d;

for ii=1:5  
    nFlow_3by3_Median3_d=medfilt2(nFlow_3by3_d,[3 3]);
    highRatioPixels_d=nFlow_3by3_Median3_d*0.85>nFlow_3by3_d;
    nFlow_3by3_d(bottomPixels_d & highRatioPixels_d)=nFlow_3by3_Median3_d(bottomPixels_d & highRatioPixels_d);
end

bottomPixels_d=nFlow_3by3_d<max_nFlow_3by3_d/3;

for ii=1:5  
    nFlow_3by3_Median7_d=medfilt2(nFlow_3by3_d,[7 7]);
    highRatioPixels_d=nFlow_3by3_Median7_d*0.85>nFlow_3by3_d;
    nFlow_3by3_d(bottomPixels_d & highRatioPixels_d)=nFlow_3by3_Median7_d(bottomPixels_d & highRatioPixels_d);
end

% Normalized with respect to mean
mean_3by3_d=mean(nFlow_3by3_d,'all');
nFlow_3by3_d=nFlow_3by3_d/mean_3by3_d;

figure(8)
set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
imagesc(nFlow_3by3_d)
colormap jet

caxis([minValue maxValue]);
colorbar
imageTitle=strcat('Gated[',num2str(imageNumber),'] (Phantom-Block) Total:',num2str(fileQuantity),' images, window:[',num2str(windowSize_3by3),' ,',num2str(windowSize_3by3), '], New Filter');
title(imageTitle)
FigureName_=strcat(FigureName,'_',num2str(windowSize_3by3),'by',num2str(windowSize_3by3));
pngFigureName_NewFilter=strcat(FigureName_,'_d_NewFilter.png');
saveas(gcf,pngFigureName_NewFilter);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

max_nFlow_3by3_0=max(max(nFlow_3by3_0));
nFlow_3by3_Median3_0=medfilt2(nFlow_3by3_0,[3 3]);

bottomPixels_0=nFlow_3by3_0<max_nFlow_3by3_0/1.7;
highRatioPixels_0=nFlow_3by3_Median3_0*0.8>nFlow_3by3_0;

for ii=1:5  
    nFlow_3by3_Median3_0=medfilt2(nFlow_3by3_0,[3 3]);
    highRatioPixels_0=nFlow_3by3_Median3_0*0.85>nFlow_3by3_0;
    nFlow_3by3_0(bottomPixels_0 & highRatioPixels_0)=nFlow_3by3_Median3_0(bottomPixels_0 & highRatioPixels_0);
end

bottomPixels_0=nFlow_3by3_0<max_nFlow_3by3_0/3;

for ii=1:5  
    nFlow_3by3_Median7_0=medfilt2(nFlow_3by3_0,[7 7]);
    highRatioPixels_0=nFlow_3by3_Median7_0*0.85>nFlow_3by3_0;
    nFlow_3by3_0(bottomPixels_0 & highRatioPixels_0)=nFlow_3by3_Median7_0(bottomPixels_0 & highRatioPixels_0);
end

% Normalized with respect to mean
mean_3by3_0=mean(nFlow_3by3_0,'all');
nFlow_3by3_0=nFlow_3by3_0/mean_3by3_0;

figure(8)
set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
imagesc(nFlow_3by3_0)
colormap jet

caxis([minValue maxValue]);
colorbar
imageTitle=strcat('Gated[',num2str(imageNumber),'] (Phantom) Total:',num2str(fileQuantity),' images, window:[',num2str(windowSize_3by3),' ,',num2str(windowSize_3by3), '], New Filter');
title(imageTitle)
FigureName_=strcat(FigureName,'_',num2str(windowSize_3by3),'by',num2str(windowSize_3by3));
pngFigureName_NewFilter=strcat(FigureName_,'_Ph_NewFilter.png');
saveas(gcf,pngFigureName_NewFilter);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

max_nFlow_3by3_1=max(max(nFlow_3by3_1));
nFlow_3by3_Median3_1=medfilt2(nFlow_3by3_1,[3 3]);

bottomPixels_1=nFlow_3by3_1<max_nFlow_3by3_1/1.7;
highRatioPixels_1=nFlow_3by3_Median3_1*0.8>nFlow_3by3_1;

for ii=1:5  
    nFlow_3by3_Median3_1=medfilt2(nFlow_3by3_1,[3 3]);
    highRatioPixels_1=nFlow_3by3_Median3_1*0.85>nFlow_3by3_1;
    nFlow_3by3_1(bottomPixels_1 & highRatioPixels_1)=nFlow_3by3_Median3_1(bottomPixels_1 & highRatioPixels_1);
end

bottomPixels_1=nFlow_3by3_1<max_nFlow_3by3_1/3;

for ii=1:5  
    nFlow_3by3_Median7_1=medfilt2(nFlow_3by3_1,[7 7]);
    highRatioPixels_1=nFlow_3by3_Median7_1*0.85>nFlow_3by3_1;
    nFlow_3by3_1(bottomPixels_1 & highRatioPixels_1)=nFlow_3by3_Median7_1(bottomPixels_1 & highRatioPixels_1);
end

% Normalized with respect to mean
mean_3by3_1=mean(nFlow_3by3_1,'all');
nFlow_3by3_1=nFlow_3by3_1/mean_3by3_1;

figure(8)
set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
imagesc(nFlow_3by3_1)
colormap jet

caxis([minValue maxValue]);
colorbar
imageTitle=strcat('Gated[',num2str(imageNumber),'] (Block) Total:',num2str(fileQuantity),' images, window:[',num2str(windowSize_3by3),' ,',num2str(windowSize_3by3), '], New Filter');
title(imageTitle)
FigureName_=strcat(FigureName,'_',num2str(windowSize_3by3),'by',num2str(windowSize_3by3));
pngFigureName_NewFilter=strcat(FigureName_,'_B_NewFilter.png');
saveas(gcf,pngFigureName_NewFilter);    
    
end

mkdir('3by3_Ph')
mkdir('3by3_B')
mkdir('3by3_d')

movefile *3_Ph_NewFilter.png 3by3_Ph
movefile *3_B_NewFilter.png 3by3_B
movefile *3_d_NewFilter.png 3by3_d

cd ..

toc

function IMAGE=pileUpCorrection(IMAGE)
imageHelp=IMAGE/1024;
imageHelp=1-imageHelp;
IMAGE=log(imageHelp);
end
