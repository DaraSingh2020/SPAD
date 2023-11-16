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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxValue=100;
minValue=50; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% There is only one folder. So choose the files
[file,path] = uigetfile('F:\*.tiff', 'MultiSelect','on');
splittedPath=strsplit(path,'\');
currentFolder=pwd;
temporaryFolder_=cell2mat(splittedPath(end-2));
temporaryFolder=strcat(temporaryFolder_(1:10),'_Gated_Results');
mkdir(temporaryFolder)
cd(strcat(currentFolder,'\',temporaryFolder))

pathCheck=path(1:end-2);
Flag=1;
while Flag==1
    if isnan(str2double(pathCheck(end)))
        rootDirectory=pathCheck;
        Flag=0;
    else
        pathCheck=pathCheck(1:end-1);
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


% This section only shows the raw image. Not really important in
% calculations. You may comment it out. I have used it to verify my code to
% read the address.

imageNumber=fileN_Start;
folderNumber=1;

imageName=strcat(rootDirectory,num2str(folderNumber),'\',imagePrefix,num2str(imageNumber),'.tiff');
image=imread(imageName);
adjustedImage=imadjust(image);
image=double(image);
figure(1)
if rotateImage==1
    adjustedImage=adjustedImage';
end
imshow(adjustedImage)
pngFigureName_NewFilter=strcat('RawImage_Folder_1.png');
saveas(gcf,pngFigureName_NewFilter);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Don't touch the 3by3 window variables
windowSize_3by3=3;
Kernel_3by3=ones(windowSize_3by3,windowSize_3by3,'gpuArray')/windowSize_3by3^2;

windowSize_5by5=5;
Kernel_5by5=ones(windowSize_5by5,windowSize_5by5,'gpuArray')/windowSize_5by5^2;

windowSize_7by7=7;
Kernel_7by7=ones(windowSize_7by7,windowSize_7by7,'gpuArray')/windowSize_7by7^2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fun =@(X) std(X)./mean(X);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for fileNumber=fileN_Start:fileN_End
    % refreshing helper variables before each loop.
    X_7by7=double(gpuArray(image))*0;
    X_5by5=double(gpuArray(image))*0;
    X_3by3=double(gpuArray(image))*0;
    
    fileQuantity=folderN_End-folderN_Start+1;
    imageNumber=fileNumber;
    
    parfor folderNumber=folderN_Start:folderN_End
        imageName=strcat(rootDirectory,num2str(folderNumber),'\',imagePrefix,num2str(imageNumber),'.tiff');
        image=double(gpuArray(imread(imageName)));

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
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Kmean_2D_7by7=X_7by7/fileQuantity;
    flow_7by7 = 1./Kmean_2D_7by7.^2;
    
    Kmean_2D_5by5=X_5by5/fileQuantity;
    flow_5by5 = 1./Kmean_2D_5by5.^2;
    
    Kmean_2D_3by3=X_3by3/fileQuantity;
    flow_3by3 = 1./Kmean_2D_3by3.^2;
%normalizedFlow=(flow/mean2(flow));   
%normalizedFlow_3by3=(flow_3by3/mean2(flow_3by3));    
    
    if rotateImage==1
        nFlow_7by7=rot90(flow_7by7,1);
        nFlow_5by5=rot90(flow_5by5,1);
        nFlow_3by3=rot90(flow_3by3,1);
    else
        nFlow_7by7=flow_7by7;
        nFlow_5by5=flow_5by5; 
        nFlow_3by3=flow_3by3;
    end
    
    exportImageSize=size(nFlow_3by3);

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 7 by 7 raw
figure(2)
set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
imagesc(nFlow_7by7)
colormap jet

caxis([minValue maxValue]);
colorbar
imageTitle=strcat('Gated[',num2str(imageNumber),'] Total:',num2str(fileQuantity),' images, window:[',num2str(windowSize_7by7),' ,',num2str(windowSize_7by7), ']');
title(imageTitle)
FigureName=strcat('rCBF_image',num2str(imageNumber));
FigureName_=strcat(FigureName,'_',num2str(windowSize_7by7),'by',num2str(windowSize_7by7));
pngFigureName=strcat(FigureName_,'.png');
%saveas(gcf,pngFigureName);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
 % 5 by 5 raw 
figure(3)
set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
imagesc(nFlow_5by5)
colormap jet
caxis([minValue maxValue]);
colorbar
imageTitle=strcat('Gated[',num2str(imageNumber),'] Total:',num2str(fileQuantity),' images, window:[',num2str(windowSize_5by5),' ,',num2str(windowSize_5by5), ']');
title(imageTitle)
FigureName=strcat('rCBF_image',num2str(imageNumber));
FigureName_=strcat(FigureName,'_',num2str(windowSize_5by5),'by',num2str(windowSize_5by5));
pngFigureName=strcat(FigureName_,'.png');
%saveas(gcf,pngFigureName);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(4)
set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
imagesc(nFlow_3by3)
colormap jet
caxis([minValue maxValue]);
colorbar
imageTitle=strcat('Gated[',num2str(imageNumber),'] Total:',num2str(fileQuantity),' images, window:[',num2str(windowSize_3by3),' ,',num2str(windowSize_3by3), ']');
title(imageTitle)
FigureName_=strcat(FigureName,'_',num2str(windowSize_3by3),'by',num2str(windowSize_3by3));
pngFigureName_3by3=strcat(FigureName_,'_3by3.png');
%saveas(gcf,pngFigureName_3by3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
nFlow_3by3_Median=medfilt2(nFlow_3by3,[3 3]);
figure(5)
set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
imagesc(nFlow_3by3_Median)
colormap jet
caxis([minValue maxValue]);
colorbar
imageTitle=strcat('Gated[',num2str(imageNumber),'] Total:',num2str(fileQuantity),' images, window:[',num2str(windowSize_3by3),' ,',num2str(windowSize_3by3), '] Median');
title(imageTitle)
FigureName_=strcat(FigureName,'_',num2str(windowSize_3by3),'by',num2str(windowSize_3by3));
pngFigureName_3by3_Median=strcat(FigureName_,'_3by3_Median.png');
%saveas(gcf,pngFigureName_3by3_Median);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

normalizedFlowHelp=nFlow_3by3_Median;    
pixelsForChanging=normalizedFlowHelp*0.8>nFlow_7by7;    
nFlow_7by7(pixelsForChanging)=normalizedFlowHelp(pixelsForChanging);
figure(6)
set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
imagesc(nFlow_7by7)
colormap jet
caxis([minValue maxValue]);
colorbar
imageTitle=strcat('Gated[',num2str(imageNumber),'] Total:',num2str(fileQuantity),' images, window:[',num2str(windowSize_7by7),' ,',num2str(windowSize_7by7), '], New Filter');
title(imageTitle)
FigureName_=strcat(FigureName,'_',num2str(windowSize_7by7),'by',num2str(windowSize_7by7));
pngFigureName_NewFilter=strcat(FigureName_,'_NewFilter.png');
%saveas(gcf,pngFigureName_NewFilter);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
max_nFlow_5by5=max(max(nFlow_5by5))
nFlow_5by5_Median5=medfilt2(nFlow_5by5,[5 5]);

bottomPixels=nFlow_5by5<max_nFlow_5by5/1.7;
highRatioPixels=nFlow_5by5_Median5*0.8>nFlow_5by5;

for ii=1:10  
    nFlow_5by5_Median5=medfilt2(nFlow_5by5,[5 5]);
    highRatioPixels=nFlow_5by5_Median5*0.85>nFlow_5by5;
    nFlow_5by5(bottomPixels & highRatioPixels)=nFlow_5by5_Median5(bottomPixels & highRatioPixels);
end

bottomPixels=nFlow_5by5<max_nFlow_5by5/3;

for ii=1:10  
    nFlow_5by5_Median9=medfilt2(nFlow_5by5,[9 9]);
    highRatioPixels=nFlow_5by5_Median9*0.85>nFlow_5by5;
    nFlow_5by5(bottomPixels & highRatioPixels)=nFlow_5by5_Median9(bottomPixels & highRatioPixels);
end

figure(7)
set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
imagesc(nFlow_5by5)
colormap jet
caxis([minValue maxValue]);
colorbar
imageTitle=strcat('Gated[',num2str(imageNumber),'] Total:',num2str(fileQuantity),' images, window:[',num2str(windowSize_5by5),' ,',num2str(windowSize_5by5), '], New Filter');
title(imageTitle)
FigureName_=strcat(FigureName,'_',num2str(windowSize_5by5),'by',num2str(windowSize_5by5));
pngFigureName_NewFilter=strcat(FigureName_,'_NewFilter.png');
saveas(gcf,pngFigureName_NewFilter);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

max_nFlow_3by3=max(max(nFlow_3by3))
nFlow_3by3_Median3=medfilt2(nFlow_3by3,[3 3]);

bottomPixels=nFlow_3by3<max_nFlow_3by3/1.7;
highRatioPixels=nFlow_3by3_Median3*0.8>nFlow_3by3;

for ii=1:5  
    nFlow_3by3_Median3=medfilt2(nFlow_3by3,[3 3]);
    highRatioPixels=nFlow_3by3_Median3*0.85>nFlow_3by3;
    nFlow_3by3(bottomPixels & highRatioPixels)=nFlow_3by3_Median3(bottomPixels & highRatioPixels);
end

bottomPixels=nFlow_3by3<max_nFlow_3by3/3;

for ii=1:5  
    nFlow_3by3_Median7=medfilt2(nFlow_3by3,[7 7]);
    highRatioPixels=nFlow_3by3_Median7*0.85>nFlow_3by3;
    nFlow_3by3(bottomPixels & highRatioPixels)=nFlow_3by3_Median7(bottomPixels & highRatioPixels);
end


figure(8)
set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
imagesc(nFlow_3by3)
colormap jet

caxis([minValue maxValue]);
colorbar
imageTitle=strcat('Gated[',num2str(imageNumber),'] Total:',num2str(fileQuantity),' images, window:[',num2str(windowSize_3by3),' ,',num2str(windowSize_3by3), '], New Filter');
title(imageTitle)
FigureName_=strcat(FigureName,'_',num2str(windowSize_3by3),'by',num2str(windowSize_3by3));
pngFigureName_NewFilter=strcat(FigureName_,'_NewFilter.png');
saveas(gcf,pngFigureName_NewFilter);

    
    
end

mkdir('3by3')
mkdir('5by5')

movefile *3_NewFilter.png 3by3
movefile *5_NewFilter.png 5by5

cd ..

toc