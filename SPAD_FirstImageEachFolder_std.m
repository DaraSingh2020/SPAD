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
fileN_End=30;
folderN_Start=1;
folderN_End=80;
folderQuantity=folderN_End-folderN_Start+1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Put the right directory here. image name will be modified with the image
% name prefix. remove the folder numbers. The code takes care of it.

%Item1:
%rootDirectory='F:\test_mouse_LSCI_publication_SPAD_sharedpath_polarizer_zoomedIne_01182022\2_P800mw_exp5.36_31nsOff_18psdelay_F11bw22_mouse_Pol_NOConcave_Pellicle_ZoomedIn_Withpad';
%rootDirectory='F:\test_mouse_LSCI_publication_SPAD\2_P800mw';

%item3: directory to phantom (January 12th scanned)
%rootDirectory='F:\test_Phantom_MultipleBatches_GatedMode_01102021\7_P400mw_exp5.36_31nsOff_18psdelay_F11bw22_Ph_MultipleBatches_Pol_NOConcave_Pellicle_ZoomedIn_Withpad\output_imagesTrianglePhan';


%item3: directory to phantom (January 18th scanned)
rootDirectory='F:\test_9weekmouse_1\5_P1w_exp5.36_31nsOff_18psdelay_F11_mouse_MultipleBatches_Pol_NOConcave_Pellicle_ZoomedIn_Withpad\output_imagesBLmo';


%Item2:
%rootDirectory='F:\test_mouse_LSCI_publication_SPAD\5_P1w\output_imagesBLmo';

imagePrefix='image_';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
imshow(adjustedImage)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Don't touch the 3by3 window variables
windowSize_3by3=3;
blockSize_3by3=[windowSize_3by3 windowSize_3by3];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Choose either 5by5 or 7by7
windowSize=7;
blockSize=[windowSize windowSize];
% blockSize=[5 5];
fun =@(X) std(X)./mean(X);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for fileNumber=fileN_Start:fileN_End
    % refreshing helper variables before each loop.
    X=double(image)*0;
    X_3by3=double(image)*0;
    fileQuantity=folderN_End-folderN_Start+1;
    imageNumber=fileNumber;
    
    parfor folderNumber=folderN_Start:folderN_End
        imageName=strcat(rootDirectory,num2str(folderNumber),'\',imagePrefix,num2str(imageNumber),'.tiff');
        image=double(imread(imageName));

%% Fixing the skewness: Optional and can be changed
        imageHelp=image;
        imageHelp=imageHelp/1024;
        imageHelp=1-imageHelp;
        image=log(imageHelp);
% Fixing the skewness ends here

        Z = double(image);
        Iout = colfilt(Z,blockSize,'sliding',fun);
        X=X+Iout;
        
        Iout_3by3 = colfilt(Z,blockSize_3by3,'sliding',fun);
        X_3by3=X_3by3+Iout_3by3;
    end
    
    Kmean_2D=X/fileQuantity;
    flow = 1./Kmean_2D.^2;
    
    Kmean_2D_3by3=X_3by3/fileQuantity;
    flow_3by3 = 1./Kmean_2D_3by3.^2;
%normalizedFlow=(flow/mean2(flow));
    normalizedFlow=flow;
    
%normalizedFlow_3by3=(flow_3by3/mean2(flow_3by3));    
    normalizedFlow_3by3=flow_3by3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% constructing the images

    figure(2)
    imagesc(normalizedFlow)
    colormap jet
    maxValue=max(max(normalizedFlow));
%cappedScale=0.37*maxValue;
    caxis([50 300]);
    colorbar
    imageTitle=strcat('image:',num2str(imageNumber),' averaged over',num2str(folderQuantity),' folders, window:[',num2str(windowSize),' ,',num2str(windowSize), ']');
    title(imageTitle)
    FigureName=strcat('rCBF_image',num2str(imageNumber));
    FigureName_=strcat(FigureName,'_',num2str(windowSize),'by',num2str(windowSize));
    pngFigureName=strcat(FigureName_,'.png');
    saveas(gcf,pngFigureName);
    
    
    figure(3)
    imagesc(normalizedFlow_3by3)
    colormap jet
    maxValue_3by3=max(max(normalizedFlow_3by3));
%cappedScale=0.37*maxValue;
    caxis([50 300]);
    colorbar
    imageTitle=strcat('image:',num2str(imageNumber),' averaged over',num2str(folderQuantity),' folders, window:[',num2str(windowSize_3by3),' ,',num2str(windowSize_3by3), ']');
    title(imageTitle)
    FigureName_=strcat(FigureName,'_',num2str(windowSize_3by3),'by',num2str(windowSize_3by3));
    pngFigureName_3by3=strcat(FigureName_,'_3by3.png');
    saveas(gcf,pngFigureName_3by3);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    normalizedFlowNew=normalizedFlow;
    normalizedFlowHelp=medfilt2(normalizedFlow_3by3,[9 9]);
    
    pixelsForChanging=normalizedFlowHelp*0.9>normalizedFlow;
    
    normalizedFlowNew(pixelsForChanging)=normalizedFlowHelp(pixelsForChanging);
    figure(4)
    imagesc(normalizedFlowNew)
    colormap jet
    maxValue_Modified=max(max(normalizedFlowNew));
%cappedScale=0.37*maxValue;
    caxis([50 300]);
    colorbar
    imageTitle=strcat('image:',num2str(imageNumber),' averaged over',num2str(folderQuantity),' folders, window:[',num2str(windowSize),' ,',num2str(windowSize), '], New Filter');
    title(imageTitle)
    FigureName_=strcat(FigureName,'_',num2str(windowSize),'by',num2str(windowSize));
    pngFigureName_NewFilter=strcat(FigureName_,'_NewFilter.png');
    saveas(gcf,pngFigureName_NewFilter);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    normalizedFlowNew=normalizedFlow_3by3;
    normalizedFlowHelp=medfilt2(normalizedFlow_3by3,[9 9]);
    
    pixelsForChanging=normalizedFlowHelp*0.9>normalizedFlow;
    
    normalizedFlowNew(pixelsForChanging)=normalizedFlowHelp(pixelsForChanging);
    figure(5)
    imagesc(normalizedFlowNew)
    colormap jet
    maxValue_Modified=max(max(normalizedFlowNew));
%cappedScale=0.37*maxValue;
    caxis([70 300]);
    colorbar
    imageTitle=strcat('image:',num2str(imageNumber),' averaged over',num2str(folderQuantity),' folders, window:[',num2str(windowSize_3by3),' ,',num2str(windowSize_3by3), '], New Filter');
    title(imageTitle)
    FigureName_=strcat(FigureName,'_',num2str(windowSize_3by3),'by',num2str(windowSize_3by3));
    pngFigureName_NewFilter=strcat(FigureName_,'_NewFilter.png');
    saveas(gcf,pngFigureName_NewFilter);

    
    
    
    
    
end
toc