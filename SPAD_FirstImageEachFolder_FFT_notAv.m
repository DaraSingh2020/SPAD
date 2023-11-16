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
imageEnd=2;
folderStart=1;
folderEnd=220;
folderEndBaseline=220;
folderQuantity=folderEnd-folderStart+1;
imageQuantity=imageEnd-imageEnd+1;
totalTime=5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxIntensity=600;
minIntensity=70; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mouse1 on February 9th
%Mouse1,Step1 
rootDirectory='F:\SPAD_Mouse_2_10_2022\1stMouse_Data\3_P800mw_exp5.36_31nsOff_18psdelay_F11_2frame_Pulse\output_imagesPulse';

imagePrefix='image_';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This section only shows the raw image. Not really important in
% calculations. You may comment it out. I have used it to verify my code to
% read the address.

imageNumber=imageStart-1;
folderNumber=1;

imageName=strcat(rootDirectory,num2str(folderNumber),'\',imagePrefix,num2str(imageNumber),'.tiff');
image=imread(imageName);
adjustedImage=imadjust(rot90(image));
image=double(image);
figure(1)
imshow(adjustedImage)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Don't touch the 3by3 window variables
windowSize_3by3=3;
Kernel_3by3=ones(windowSize_3by3,windowSize_3by3,'gpuArray')/windowSize_3by3^2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for imageNumber=imageStart:imageEnd
    % refreshing helper variables before each loop.

    X_3by3=double(gpuArray(image))*0;
    
    fileQuantity=folderEndBaseline-folderStart+1;
    
    parfor folderNumber=folderStart:folderEndBaseline
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
caxis([minIntensity maxIntensity]);
colorbar
imageTitle=strcat('Gated[',num2str(imageNumber),'] Total:',num2str(fileQuantity),' images, window:[',num2str(windowSize_3by3),' ,',num2str(windowSize_3by3), '], New Filter');
title(imageTitle)
FigureName=strcat('rCBF_image',num2str(imageNumber));
FigureName_=strcat(FigureName,'_',num2str(windowSize_3by3),'by',num2str(windowSize_3by3));
pngFigureName_NewFilter=strcat(FigureName_,'_NewFilter.png');
saveas(gcf,pngFigureName_NewFilter);   
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do you want to select a region from the difference?
question = questdlg('Do you want to select a ROI (Region Of Interest)?', ...
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
   
    xMin_Main=20;
    yMin_Main=100;
    width_Main=200;
    height_Main=360;

    xMax_Main=xMin_Main+width_Main;
    yMax_Main=yMin_Main+height_Main;

    %difference=gather(difference);
    selectRectangle=1;
else
    selectRectangle=0;
end

while selectRectangle==1
    figure(3)
    set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5]);
    colormap jet
    colorbar
    title('Select the right position for the rectangle');

    rectangle('Position',[xMin_Main yMin_Main width_Main height_Main])
    text((xMin_Main+30), (yMin_Main+30),'Main ROI')

    prompt = {'Enter X Main minimum','Enter Y Main minimum','Enter width Main','Enter height Main' };
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {num2str(xMin_Main),num2str(yMin_Main),num2str(width_Main),num2str(height_Main)};
    response = inputdlg(prompt,dlgtitle,dims,definput);
    if isempty(response)
        selectRectangle=0;
        saveas(gcf,'SelectedRectangles.png');
    else

        
        xMin_Main=str2double(response{1});
        yMin_Main=str2double(response{2}); 
        width_Main=str2double(response{3});
        height_Main=str2double(response{4});
        

        xMax_Main=xMin_Main+width_Main;
        yMax_Main=yMin_Main+height_Main;
        
        image_Main=nFlow_3by3(yMin_Main:yMax_Main,xMin_Main:xMax_Main);
        figure(4)
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


Main_ROI_List=zeros(imageQuantity,folderQuantity);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating 1 to 100 images. It makes our P1. It is also same as the
% middle section
bodyStart=1;
bodyEnd=averagingSize;

for imageNumber=imageStart:imageEnd
    % refreshing helper variables before each loop.
        
     parfor folderNumber=folderStart:folderEnd
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
           
          Kmean_2D_3by3=Iout_3by3;
          flow_3by3 = 1./Kmean_2D_3by3.^2;
          flow=rot90(flow_3by3,1);

          image_Main=flow(yMin_Main:yMax_Main,xMin_Main:xMax_Main);
          box_Main_Mean=mean(mean(image_Main));
          Main_ROI_List(imageNumber,folderNumber)=box_Main_Mean;
          box_Main_Mean
           
           
     end  
end

ROI=mean(Main_ROI_List);
size(ROI)
               

foldersPerMinute=folderQuantity/totalTime;
timeline=(1:folderEnd)/foldersPerMinute;
Experiment='Fast sampling'
figure(5) 

plot(timeline,ROI,'magenta')
ylabelString='CBF';
ylabel(ylabelString)
xlabelString=strcat('Time ( minutes)');
xlabel(xlabelString)

titleString=strcat(Experiment,', Av. size:',num2str(averagingSize),', jump:',num2str(jump),', Duration:',num2str(totalTime),' min',', Folders:',num2str(folderEnd));
title(titleString);
figureName=strcat('TimePlot_',Experiment);
figureNamepng=strcat(figureName,'.png');

legend('Main')
saveas(gcf,figureName);
saveas(gcf,figureNamepng);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
detrendedROI=detrend(ROI);
figure(6) 

plot(timeline,detrendedROI,'magenta')
ylabelString='CBF';
ylabel(ylabelString)
xlabelString=strcat('Time ( minutes)');
xlabel(xlabelString)

titleString=strcat(Experiment,', Av. size:',num2str(averagingSize),', jump:',num2str(jump),', Duration:',num2str(totalTime),' min',', Folders:',num2str(folderEnd));
title(titleString);
figureName=strcat('TimePlot_',Experiment);
figureNamepng=strcat(figureName,'.png');

legend('Main')
saveas(gcf,figureName);
saveas(gcf,figureNamepng);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trendOfROI=ROI-detrend(ROI);
figure(7) 

plot(timeline,trendOfROI,'magenta')
ylabelString='CBF';
ylabel(ylabelString)
xlabelString=strcat('Time ( minutes)');
xlabel(xlabelString)

titleString=strcat(Experiment,', Av. size:',num2str(averagingSize),', jump:',num2str(jump),', Duration:',num2str(totalTime),' min',', Folders:',num2str(folderEnd));
title(titleString);
figureName=strcat('TimePlot_',Experiment);
figureNamepng=strcat(figureName,'.png');

legend('Main')
saveas(gcf,figureName);
saveas(gcf,figureNamepng);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


figure(7)

nSamples=220;  %220 folders
samplingT=5*60;  %Samples collected for 5 minutes
Fs=nSamples/samplingT;   %sampling frequency
L=length(ROI);  %Main_ROI_List is the data.
timeVector=(0:L-1)*samplingT;
Y=fft(Main_ROI_List);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
plot(f,P1) 

[maxF,maxF_Index]=max(P1)
f(maxF_Index)

title('Single-Sided Amplitude Spectrum. ')
xlabel('f (Hz)')
ylabel('|P1(f)|')
figureName='FFT_Plot';
figureNamepng=strcat(figureName,'.png');
saveas(gcf,figureName);
saveas(gcf,figureNamepng);



toc