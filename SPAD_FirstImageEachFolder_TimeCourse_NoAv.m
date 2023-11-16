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
imageStart=1;

imageEnd=30;
folderStart=1;
folderEnd=640;
folderN_EndBaseline=120;
folderQuantity=folderEnd-folderStart+1;
imageQuantity=imageEnd-imageStart+1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxValue=600;
minValue=70; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
rootDirectory='F:\SPAD_Mouse_2_10_2022\1stMouse_Data\8_P800mw_exp5.36_31nsOff_18psdelay_F11_Ligation_CA_MultipleBatches\output_imagesLig';

%Mouse2, Step3
%rootDirectory='F:\SPAD_Mouse_2_10_2022\2ndMouse_Data\9_P500mw_exp5.36_31nsOff_18psdelay_F11_CO2\output_images2ndmiceCO';

%Mouse2,Step7 
%rootDirectory='F:\SPAD_Mouse_2_10_2022\2ndMouse_Data\12_P500mw_exp5.36_31nsOff_18psdelay_F11_Ligation\output_images2ndmiceLigCA';

imagePrefix='image_';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This section only shows the raw image. Not really important in
% calculations. You may comment it out. I have used it to verify my code to
% read the address.

imageNumber=imageStart;
folderNumber=1;

imageName=strcat(rootDirectory,num2str(folderNumber),'\',imagePrefix,num2str(imageNumber),'.tiff');
image=imread(imageName);
adjustedImage=imadjust(rot90(image));
image=double(image);
figure(1)
imshow(adjustedImage)
saveas(gcf,'RawImage.png');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Don't touch the 3by3 window variables
windowSize_3by3=3;
Kernel_3by3=ones(windowSize_3by3,windowSize_3by3,'gpuArray')/windowSize_3by3^2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for imageNumber=imageStart:imageEnd
    % refreshing helper variables before each loop.

    X_3by3=double(gpuArray(image))*0;
    
    fileQuantity=folderN_EndBaseline-folderStart+1;

    
    parfor folderNumber=folderStart:folderN_EndBaseline
        imageName=strcat(rootDirectory,num2str(folderNumber),'\',imagePrefix,num2str(imageNumber-1),'.tiff');
        image=double(gpuArray(imread(imageName)));

%% Fixing the skewness: Optional and can be changed
        imageHelp=image;
        imageHelp=imageHelp/1024;
        imageHelp=1-imageHelp;
        image=log(imageHelp);
% Fixing the skewness ends here

            imageSquareMean_3by3=conv2(image.^2,Kernel_3by3,'same');           
            imageMean_3by3=conv2(image,Kernel_3by3,'same');
            imageMeanSquare_3by3=imageMean_3by3.^2;
            Iout_3by3=sqrt(abs(imageSquareMean_3by3-imageMeanSquare_3by3))./imageMean_3by3;
            X_3by3=X_3by3+Iout_3by3;

    end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Kmean_2D_3by3=X_3by3/fileQuantity;
    flow_3by3 = 1./Kmean_2D_3by3.^2;
    nFlow_3by3=rot90(flow_3by3,1);
  
    exportImageSize=size(nFlow_3by3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

max_nFlow_3by3=max(max(nFlow_3by3));
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

figure(2)
set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
imagesc(nFlow_3by3)
colormap jet
caxis([minValue maxValue]);
colorbar
imageTitle=strcat('Gated[',num2str(imageNumber),'] Total:',num2str(fileQuantity),' images, window:[',num2str(windowSize_3by3),' ,',num2str(windowSize_3by3), '], New Filter');
title(imageTitle)
FigureName=strcat('rCBF_image',num2str(imageNumber));
FigureName_=strcat(FigureName,'_',num2str(windowSize_3by3),'by',num2str(windowSize_3by3));
pngFigureName_NewFilter=strcat(FigureName_,'_NewFilter.png');
saveas(gcf,pngFigureName_NewFilter);
if imageNumber==imageStart
    nFlow_3by3_1=nFlow_3by3;
end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do you want to select a region from the difference?
question = questdlg('Do you want to select a region from the difference?', ...
	'LSCI anlysis', ...
	'No. Done with calculations','Yes. Please','Yes. Please');

switch question
    case 'No. Done with calculations'
        TimePointFlag=0;
    case 'Yes. Please'
        TimePointFlag=1;  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if TimePointFlag==1

    xMin_RH=130;
    yMin_RH=60;
    width_RH=100;
    height_RH=350;

    xMin_LH=25;
    yMin_LH=60;
    width_LH=100;
    height_LH=350;
    
    xMin_Main=15;
    yMin_Main=70;
    width_Main=230;
    height_Main=360;

    xMax_RH=xMin_RH+width_RH;
    yMax_RH=yMin_RH+height_RH;
    xMax_LH=xMin_LH+width_LH;
    yMax_LH=yMin_LH+height_LH;
    xMax_Main=xMin_Main+width_Main;
    yMax_Main=yMin_Main+height_Main;

    %difference=gather(difference);
    selectRectangle=1;
else
    selectRectangle=0;
end

while selectRectangle==1
    figure(3)
    set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
    imagesc(nFlow_3by3_1);
    colormap jet
    colorbar
    title('Select the right position for the rectangle');

    rectangle('Position',[xMin_RH yMin_RH width_RH height_RH])
    text((xMin_RH+30), (yMin_RH+30),'RH ROI')
    rectangle('Position',[xMin_LH yMin_LH width_LH height_LH])
    text((xMin_LH+30), (yMin_LH+30),'LH ROI')
    rectangle('Position',[xMin_Main yMin_Main width_Main height_Main])
    text((xMin_Main+30), (yMin_Main+30),'Main ROI')

    prompt = {'Enter X RH minimum','Enter Y RH minimum','Enter width RH','Enter height RH',...
       'Enter X LH minimum','Enter Y LH minimum','Enter width LH','Enter height LH',...
       'Enter X Main minimum','Enter Y Main minimum','Enter width Main','Enter height Main' };
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {num2str(xMin_RH),num2str(yMin_RH),num2str(width_RH),num2str(height_RH),...
       num2str(xMin_LH),num2str(yMin_LH),num2str(width_LH),num2str(height_LH),...
       num2str(xMin_Main),num2str(yMin_Main),num2str(width_Main),num2str(height_Main)};
    response = inputdlg(prompt,dlgtitle,dims,definput);
    if isempty(response)
        selectRectangle=0;
        saveas(gcf,'SelectedRectangles.png');
    else
        xMin_RH=str2double(response{1});
        yMin_RH=str2double(response{2});
        width_RH=str2double(response{3});
        height_RH=str2double(response{4});
    
        xMin_LH=str2double(response{5});
        yMin_LH=str2double(response{6}); 
        width_LH=str2double(response{7});
        height_LH=str2double(response{8});
        
        xMin_Main=str2double(response{9});
        yMin_Main=str2double(response{10}); 
        width_Main=str2double(response{11});
        height_Main=str2double(response{12});
        
        xMax_RH=xMin_RH+width_RH;
        yMax_RH=yMin_RH+height_RH;
        xMax_LH=xMin_LH+width_LH;
        yMax_LH=yMin_LH+height_LH;
        xMax_Main=xMin_Main+width_Main;
        yMax_Main=yMin_Main+height_Main;
        
                
        image_RH=nFlow_3by3(yMin_RH:yMax_RH,xMin_RH:xMax_RH);
        figure(4)
        set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
        imagesc(image_RH);
        colormap jet
        colorbar
        title('RIO Right Hemisphere')
        saveas(gcf,'RightHemisphere.png');
        
        
        image_LH=nFlow_3by3(yMin_LH:yMax_LH,xMin_LH:xMax_LH);
        figure(5)
        set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
        imagesc(image_LH);
        colormap jet
        colorbar
        title('RIO Left Hemisphere')
        saveas(gcf,'LeftHemisphere.png');
        
        image_Main=nFlow_3by3(yMin_Main:yMax_Main,xMin_Main:xMax_Main);
        figure(6)
        set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
        imagesc(image_Main);
        colormap jet
        colorbar
        title('RIO Both Hemisphere')
        saveas(gcf,'WholeHeadSelected.png');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main_ROI_List=zeros(imageQuantity,folderQuantity);
% RH_ROI_List=zeros(imageQuantity,folderQuantity);
% LH_ROI_List=zeros(imageQuantity,folderQuantity);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

imageStart=0;
imageEnd=11;
for imageNumber=imageStart:imageEnd
    Main_ROI_List=zeros(1,folderQuantity);
    RH_ROI_List=zeros(1,folderQuantity);
    LH_ROI_List=zeros(1,folderQuantity);

     parfor folderNumber=folderStart:folderEnd
         imageName=strcat(rootDirectory,num2str(folderNumber),'\',imagePrefix,num2str(imageNumber),'.tiff');
         image=double(gpuArray(imread(imageName)));

%% Fixing the skewness: Optional and can be changed
          imageHelp=image;
          imageHelp=imageHelp/1024;
          imageHelp=1-imageHelp;
          image=log(imageHelp);
% Fixing the skewness ends here
          imageSquareMean_3by3=conv2(image.^2,Kernel_3by3,'same');           
          imageMean_3by3=conv2(image,Kernel_3by3,'same');
          imageMeanSquare_3by3=imageMean_3by3.^2;
          Iout_3by3=sqrt(abs(imageSquareMean_3by3-imageMeanSquare_3by3))./imageMean_3by3;
           
          Kmean_2D_3by3=Iout_3by3;
          flow_3by3 = 1./Kmean_2D_3by3.^2;
          flow=rot90(flow_3by3,1);

          image_Main=flow(yMin_Main:yMax_Main,xMin_Main:xMax_Main);
          box_Main_Mean=mean(mean(image_Main));
          Main_ROI_List(1,folderNumber)=box_Main_Mean;
          
          image_RH=flow(yMin_RH:yMax_RH,xMin_RH:xMax_RH);
          box_RH_Mean=mean(mean(image_RH));
          RH_ROI_List(1,folderNumber)=box_RH_Mean;

          image_LH=flow(yMin_LH:yMax_LH,xMin_LH:xMax_LH);
          box_LH_Mean=mean(mean(image_LH));
          LH_ROI_List(1,folderNumber)=box_LH_Mean;
           
     end  


% ROI_Main=mean(Main_ROI_List);
% ROI_LH=mean(LH_ROI_List);
% ROI_RH=mean(RH_ROI_List);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% totalTime=15;
% Experiment='Co2Inhalation';
% rCBF_Marker=[0,5,10];
% listOfrCBF={'Baseline','Inhalation','Recovery'};
  

totalTime=28;
Experiment='Ligation-CA';
rCBF_Marker=[0,5,8,10,13,18,20];
listOfrCBF={'Baseline','RightLigation','Bilateral','LeftRelease','Recovery','10 sec Co2 + Pause2min','100%Co2'};
baselineMarker=floor(5/totalTime);  

totalFolders=folderEnd-folderStart+1;
timePerFolder=totalTime/length(RH_ROI_List);
time=(1:length(RH_ROI_List))*timePerFolder;


figure7=figure;

plot(time,RH_ROI_List,'red')
hold on
plot(time,LH_ROI_List,'blue')
hold on
plot(time,Main_ROI_List,'green')
ylabelString='CBF';
ylabel(ylabelString)
xlabelString=strcat('Time (minutes)');
xlabel(xlabelString)

titleString=strcat(Experiment,' Folders:',num2str(folderEnd), ', Gate[',num2str(imageNumber),']');
title(titleString);
figureName=strcat('TimePlot_Gate[',num2str(imageNumber),']',Experiment);
figureNamepng=strcat(figureName,'.png');

for ii=1:length(rCBF_Marker)
    xline(rCBF_Marker(ii),'-.',listOfrCBF(ii),'LabelVerticalAlignment','bottom')
end

legend('RH','LH', 'Main')
saveas(gcf,figureName);
saveas(gcf,figureNamepng);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

baselineMarker=floor((5/totalTime)*length(RH_ROI_List));  
RH_BaselineMean=mean(RH_ROI_List(1:baselineMarker));
LH_BaselineMean=mean(LH_ROI_List(1:baselineMarker));
Main_BaselineMean=mean(Main_ROI_List(1:baselineMarker));

RH_normalized=RH_ROI_List/RH_BaselineMean;
LH_normalized=LH_ROI_List/LH_BaselineMean;
Main_normalized=Main_ROI_List/Main_BaselineMean;

figure8=figure;
plot(time,RH_normalized,'red')
hold on
plot(time,LH_normalized,'blue')
hold on
plot(time,Main_normalized,'green')
ylabelString=strcat(ylabelString,'(Normalized to Baseline)')
ylabel(ylabelString)
xlabel(xlabelString)
for ii=1:length(rCBF_Marker)
    xline(rCBF_Marker(ii),'-.',listOfrCBF(ii),'LabelVerticalAlignment','bottom')
end
legend('RH','LH', 'Main')
titleStringN=strcat(titleString,' (Normalized)');
title(titleStringN);
figureNameN=strcat(figureName,'_Normalized');
figureNamepng=strcat(figureNameN,'.png');
saveas(gcf,figureNameN);
saveas(gcf,figureNamepng);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
samplingFreq=1/timePerFolder;
lowPassFreq=1;
lowPass_Main=lowpass(Main_normalized,lowPassFreq,samplingFreq);
lowPass_LH=lowpass(LH_normalized,lowPassFreq,samplingFreq);
lowPass_RH=lowpass(RH_normalized,lowPassFreq,samplingFreq);
figure9=figure;

plot(time,lowPass_RH,'red')
hold on
plot(time,lowPass_LH,'blue')
hold on
plot(time,lowPass_Main,'green')

ylabel(ylabelString)
xlabel(xlabelString)
for ii=1:length(rCBF_Marker)
    xline(rCBF_Marker(ii),'-.',listOfrCBF(ii),'LabelVerticalAlignment','bottom')
end
legend('RH','LH', 'Main')
titleStringN=strcat(titleString,' L.P. Cutoff Freq.: ',num2str(lowPassFreq),'Hz');
title(titleStringN);
figureNameN=strcat(figureName,'_LowPassFreq');
figureNamepng=strcat(figureNameN,'.png');
saveas(gcf,figureNameN);
saveas(gcf,figureNamepng);


if imageNumber==0
    lowPass_Main_0=lowPass_Main;
    lowPass_RH_0=lowPass_RH;
    lowPass_LH_0=lowPass_LH;
elseif imageNumber==5
    lowPass_Main_5=lowPass_Main;
    lowPass_RH_5=lowPass_RH;
    lowPass_LH_5=lowPass_LH;
elseif imageNumber==10
    lowPass_Main_10=lowPass_Main;
    lowPass_RH_10=lowPass_RH;
    lowPass_LH_10=lowPass_LH;
end

end

% lowPass_Main_1=lowPass_Main;
% lowPass_Main_10=lowPass_Main;
% lowPass_Main_20=lowPass_Main;
% lowPass_Main_30=lowPass_Main;

return
figure12=figure;

plot(time,lowPass_Main_0,'red')
hold on
plot(time,lowPass_Main_5,'blue')
hold on
plot(time,lowPass_Main_10,'green')


ylabel(ylabelString)
xlabel(xlabelString)
for ii=1:length(rCBF_Marker)
    xline(rCBF_Marker(ii),'-.',listOfrCBF(ii),'LabelVerticalAlignment','bottom')
end
legend('G[0]','G[5]', 'G[10]')
titleString=strcat(Experiment,' Folders:',num2str(folderEnd));
titleStringN=strcat(titleString,' L.P. Cutoff Freq.: ',num2str(lowPassFreq),'Hz Main ROI');
title(titleStringN);
figureNameN=strcat(figureName,'_LowPassFreq_Compare_Main');
figureNamepng=strcat(figureNameN,'.png');
saveas(gcf,figureNameN);
saveas(gcf,figureNamepng);
























toc