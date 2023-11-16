% SPAD camera has a lot of faulty pixels. In this algorithm, 7by7,5by5 and 
% 3by3 images are reconstructed. Next, median filter is used on the 3by3
% image. Then this modified 3by3 image is used to get rid of faulty pixels
% in 7by7 or 5by5 images.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% close all
% clc
% clear all 
% warning off
tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select folders and files on which the code should run. For a single image
% fileN_start should match the fileN_End variable. folders should be fixed
% only if you want to run a single image.
fileN_Start=0;
fileN_End=1;
folderN_Start=1;
folderN_End=350;
folderN_EndBaseline=88;
folderQuantity=folderN_End-folderN_Start+1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxValue=70;
minValue=30; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mouse1 on February 9th
%Mouse1,Step1 
[file,path] = uigetfile('F:\*.tiff', 'MultiSelect','on');
splittedPath=strsplit(path,'\');
currentFolder=pwd;
temporaryFolder_=cell2mat(splittedPath(end-2));
temporaryFolder=strcat(temporaryFolder_(1:10),'_TimeSeries_FFT_Results');
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


%rootDirectory='F:\SPAD_Mouse_2_10_2022\1stMouse_Data\3_P800mw_exp5.36_31nsOff_18psdelay_F11_2frame_Pulse\output_imagesPulse';

imagePrefix='image_';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This section only shows the raw image. Not really important in
% calculations. You may comment it out. I have used it to verify my code to
% read the address.

imageNumber=fileN_Start;
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

for fileNumber=fileN_Start:fileN_End
    % refreshing helper variables before each loop.

    X_3by3=double(gpuArray(image))*0;
    
    fileQuantity=folderN_EndBaseline-folderN_Start+1;
    imageNumber=fileNumber;
    
    parfor folderNumber=folderN_Start:folderN_EndBaseline
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
    set(gcf,'Position', [200 50 exportImageSize(2)*2 exportImageSize(1)*1.5])
    imagesc(nFlow_3by3);
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
averagingSize=50;
jump=1;

Main_ROI_List=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tailStart=1;
tailEnd=jump;
headStart=1+averagingSize;
headEnd=jump+averagingSize;   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating 1 to 100 images. It makes our P1. It is also same as the
% middle section
bodyStart=1;
bodyEnd=averagingSize;

for fileNumber=fileN_Start:fileN_End
    % refreshing helper variables before each loop.
     X_body=double(gpuArray(image))*0;

     fileQuantity=bodyEnd-bodyStart+1;
     imageNumber=fileNumber;
     
    
     parfor folderNumber=bodyStart:bodyEnd
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
           X_body=X_body+Iout_3by3;
     end  
end
               
    Kmean_2D_3by3=X_body/fileQuantity;
    flow_3by3 = 1./Kmean_2D_3by3.^2;
    flow=rot90(flow_3by3,1);

    image_Main=flow(yMin_Main:yMax_Main,xMin_Main:xMax_Main);
    box_Main_Mean=mean(mean(image_Main));
    Main_ROI_List(end+1)=box_Main_Mean;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now simultaneously calculating 2 and 101
SPAD_Flag=1;
while SPAD_Flag==1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating front and back. Later tail (the smaller one) will be
% subtracted and back (the bigger one) will added
%%%%%%%%%%%%%%%%%  Tail %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for fileNumber=fileN_Start:fileN_End
        % refreshing helper variables before each loop.
        X_tail=double(gpuArray(image))*0;
        imageNumber=fileNumber;
    
        for folderNumber=tailStart:tailEnd
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
            X_tail=X_tail+Iout_3by3;

        end  
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Head  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for fileNumber=fileN_Start:fileN_End
        % refreshing helper variables before each loop.

        X_head=double(gpuArray(image))*0;
        imageNumber=fileNumber;
    
        for folderNumber=headStart:headEnd
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
            X_head=X_head+Iout_3by3;

        end  
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        X_body=X_body+X_head-X_tail;

        Kmean_2D_3by3=X_body/fileQuantity;
        flow_3by3 = 1./Kmean_2D_3by3.^2;
        flow=rot90(flow_3by3,1);
        
        image_Main=flow(yMin_Main:yMax_Main,xMin_Main:xMax_Main);
        box_Main_Mean=mean(mean(image_Main));
        Main_ROI_List(end+1)=box_Main_Mean;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
   
        
        tailStart=tailStart+jump;
        tailEnd=tailEnd+jump;
        headStart=headStart+jump
        headEnd=headEnd+jump
        

        if headEnd>folderN_End
            break
        end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Experiment='Co2Inhalation';
rCBF_Marker=[0,5,10];
listOfrCBF={'Baseline','Inhalation','Recovery'};
totalTime=20;
Experiment='CO2Inhalation';


totalFolders=folderN_End-folderN_Start+1;
timePerPoint=totalTime/length(Main_ROI_List);

baselineMarker=floor((5/totalTime)*length(Main_ROI_List));  
Main_BaselineMean=mean(Main_ROI_List(1:baselineMarker));
Main_normalized=Main_ROI_List/Main_BaselineMean;



figure(5) 

plot(Main_ROI_List,'magenta')
ylabelString='CBF';
ylabel(ylabelString)
xlabelString=strcat('Time (',num2str(timePerPoint),' minutes)');
xlabel(xlabelString)

titleString=strcat(Experiment,', jump:',num2str(jump),', Duration:',num2str(totalTime),' min',', Folders:',num2str(folderN_End));
title(titleString);
figureName=strcat('TimePlot_',Experiment);
figureNamepng=strcat(figureName,'.png');
for ii=1:length(rCBF_Marker)
    xline(rCBF_Marker(ii),'-.',listOfrCBF(ii),'LabelVerticalAlignment','bottom')
end
legend('Main')
saveas(gcf,figureName);
saveas(gcf,figureNamepng);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(6)

nSamples=220;  %220 folders
samplingT=5*60;  %Samples collected for 5 minutes
Fs=nSamples/samplingT;   %sampling frequency
L=length(Main_ROI_List);  %Main_ROI_List is the data.
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

baselineMarker=floor(5/totalTime);  

totalFolders=folderN_End-folderN_Start+1;
timePerFolder=totalTime/length(Main_ROI_List);
time=(1:length(Main_ROI_List))*timePerFolder;


figure7=figure;


plot(time,Main_ROI_List,'green')
ylabelString='CBF';
ylabel(ylabelString)
xlabelString=strcat('Time (minutes)');
xlabel(xlabelString)

titleString=strcat(Experiment,' Folders:',num2str(folderN_End), ', Gate[',num2str(imageNumber),']');
title(titleString);
figureName=strcat('TimePlot_Gate[',num2str(imageNumber),']',Experiment);
figureNamepng=strcat(figureName,'.png');

for ii=1:length(rCBF_Marker)
    xline(rCBF_Marker(ii),'-.',listOfrCBF(ii),'LabelVerticalAlignment','bottom')
end

legend('Main')
saveas(gcf,figureName);
saveas(gcf,figureNamepng);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

baselineMarker=floor((5/totalTime)*length(Main_ROI_List));  
Main_BaselineMean=mean(Main_ROI_List(1:baselineMarker));
Main_normalized=Main_ROI_List/Main_BaselineMean;

figure8=figure;
plot(time,Main_normalized,'green')
ylabelString=strcat(ylabelString,'(Normalized to Baseline)')
ylabel(ylabelString)
xlabel(xlabelString)
for ii=1:length(rCBF_Marker)
    xline(rCBF_Marker(ii),'-.',listOfrCBF(ii),'LabelVerticalAlignment','bottom')
end
legend('Main')
titleStringN=strcat(titleString,' (Normalized)');
title(titleStringN);
figureNameN=strcat(figureName,'_Normalized');
figureNamepng=strcat(figureNameN,'.png');
saveas(gcf,figureNameN);
saveas(gcf,figureNamepng);

%Main_normalized_Gate51=Main_normalized;
%Main_normalized_Gate21=Main_normalized;
%Main_normalized_Gate1=Main_normalized;

figure9=figure;
plot(time,Main_normalized_Gate51,'green')
hold on
plot(time,Main_normalized_Gate21,'red')
hold on
plot(time,Main_normalized_Gate1,'blue')
ylabelString=strcat('CBF (Normalized to Baseline)')
ylabel(ylabelString)
xlabel(xlabelString)
for ii=1:length(rCBF_Marker)
    xline(rCBF_Marker(ii),'-.',listOfrCBF(ii),'LabelVerticalAlignment','bottom')
end
legend('Gate51','Gate21','Gate1')
titleStringN=strcat('Rat CO2 Inhalation Folders:350 (Normalized to Baseline)');
title(titleStringN);
figureNameN=strcat(figureName,'_Normalized3');
figureNamepng=strcat(figureNameN,'.png');
saveas(gcf,figureNameN);
saveas(gcf,figureNamepng);




toc