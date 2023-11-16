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
fileN_End=0;
folderN_Start=1;
folderN_End=640;
folderN_EndBaseline=120;
folderQuantity=folderN_End-folderN_Start+1;
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
%rootDirectory='F:\SPAD_Mouse_2_10_2022\1stMouse_Data\8_P800mw_exp5.36_31nsOff_18psdelay_F11_Ligation_CA_MultipleBatches\output_imagesLig';

%Mouse2, Step3
%rootDirectory='F:\SPAD_Mouse_2_10_2022\2ndMouse_Data\9_P500mw_exp5.36_31nsOff_18psdelay_F11_CO2\output_images2ndmiceCO';

%Mouse2,Step7 
rootDirectory='F:\SPAD_Mouse_2_10_2022\2ndMouse_Data\12_P500mw_exp5.36_31nsOff_18psdelay_F11_Ligation\output_images2ndmiceLigCA';

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

windowSize_5by5=5;
Kernel_5by5=ones(windowSize_5by5,windowSize_5by5,'gpuArray')/windowSize_5by5^2;

windowSize_7by7=7;
Kernel_7by7=ones(windowSize_7by7,windowSize_7by7,'gpuArray')/windowSize_7by7^2;

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
    imagesc(nFlow_3by3);
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
averagingSize=50;
jump=5;
RH_ROI_List=[];
LH_ROI_List=[];
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
for ii=1:5
for fileNumber=fileN_Start:fileN_End
    % refreshing helper variables before each loop.
     X_body=double(gpuArray(image))*0;
     bodyEnd=ii*2*jump;
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

        image_RH=flow(yMin_RH:yMax_RH,xMin_RH:xMax_RH);
        box_RH_Mean=mean(mean(image_RH));
        RH_ROI_List(end+1)=box_RH_Mean;
        
        image_LH=flow(yMin_LH:yMax_LH,xMin_LH:xMax_LH);
        box_LH_Mean=mean(mean(image_LH));
        LH_ROI_List(end+1)=box_LH_Mean;
        
        image_Main=flow(yMin_Main:yMax_Main,xMin_Main:xMax_Main);
        box_Main_Mean=mean(mean(image_Main));
        Main_ROI_List(end+1)=box_Main_Mean;
end 

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
    
        parfor folderNumber=tailStart:tailEnd
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
    
        parfor folderNumber=headStart:headEnd
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
        
        image_RH=flow(yMin_RH:yMax_RH,xMin_RH:xMax_RH);
        box_RH_Mean=mean(mean(image_RH));
        RH_ROI_List(end+1)=box_RH_Mean;
        
        image_LH=flow(yMin_LH:yMax_LH,xMin_LH:xMax_LH);
        box_LH_Mean=mean(mean(image_LH));
        LH_ROI_List(end+1)=box_LH_Mean;
        
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

headEnd=headEnd-jump;
bodyEnd=headEnd;
bodyStart=headEnd-averagingSize;

for ii=1:4
for fileNumber=fileN_Start:fileN_End
    % refreshing helper variables before each loop.
     X_body=double(gpuArray(image))*0;
     bodyStart=bodyStart+2*jump;
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

        image_RH=flow(yMin_RH:yMax_RH,xMin_RH:xMax_RH);
        box_RH_Mean=mean(mean(image_RH));
        RH_ROI_List(end+1)=box_RH_Mean;
        
        image_LH=flow(yMin_LH:yMax_LH,xMin_LH:xMax_LH);
        box_LH_Mean=mean(mean(image_LH));
        LH_ROI_List(end+1)=box_LH_Mean;
        
        image_Main=flow(yMin_Main:yMax_Main,xMin_Main:xMax_Main);
        box_Main_Mean=mean(mean(image_Main));
        Main_ROI_List(end+1)=box_Main_Mean;
end 



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


totalFolders=folderN_End-folderN_Start+1;
timePerPoint=totalTime/length(RH_ROI_List);
%rCBF_timeMarker=floor(rCBF_Marker./timePerPoint);
time=(1:length(RH_ROI_List))*timePerPoint;


figure(7) 
plot(time,RH_ROI_List,'red')
hold on
plot(time,LH_ROI_List,'blue')
hold on
plot(time,Main_ROI_List,'magenta')
ylabelString='CBF';
ylabel(ylabelString)
xlabelString=strcat('Time (minutes)');
xlabel(xlabelString)

titleString=strcat(Experiment,', Av. size:',num2str(averagingSize),', stride:',num2str(jump),', Folders:',num2str(folderN_End));
title(titleString);
figureName=strcat('TimePlot_',Experiment);
figureNamepng=strcat(figureName,'.png');

for ii=1:length(rCBF_Marker)
    xline(rCBF_Marker(ii),'-.g',listOfrCBF(ii),'LabelVerticalAlignment','bottom')
end

legend('RH','LH', 'Main')
saveas(gcf,figureName);
saveas(gcf,figureNamepng);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

baselineLength=floor(folderN_EndBaseline/jump);
RH_BaselineMean=mean(RH_ROI_List(1:baselineLength));
LH_BaselineMean=mean(LH_ROI_List(1:baselineLength));
Main_BaselineMean=mean(Main_ROI_List(1:baselineLength));

RH_normalized=RH_ROI_List/RH_BaselineMean;
LH_normalized=LH_ROI_List/LH_BaselineMean;
Main_normalized=Main_ROI_List/Main_BaselineMean;

figure(8) 
plot(time,RH_normalized,'red')
hold on
plot(time,LH_normalized,'blue')
hold on
plot(time,Main_normalized,'magenta')
ylabelString=strcat(ylabelString,'(Normalized to Baseline)')
ylabel(ylabelString)
xlabel(xlabelString)
for ii=1:length(rCBF_Marker)
    xline(rCBF_Marker(ii),'-.g',listOfrCBF(ii),'LabelVerticalAlignment','bottom')
end
legend('RH','LH', 'Main')
titleStringN=strcat(titleString,' (Normalized)');
title(titleStringN);
figureNameN=strcat(figureName,'_Normalized');
figureNamepng=strcat(figureNameN,'.png');
saveas(gcf,figureNameN);
saveas(gcf,figureNamepng);


toc