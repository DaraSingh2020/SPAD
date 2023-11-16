% Dara January 2022. Modification of original LSCI code using
% convolution filter and multiple CPUs and gpuArray and asking questions to
% deine appropraite setting:

close all
clc
clear all
warning off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Asking the number of images to be used
maxFileNumber=1000; %Choose the number of files you want to use
prompt = {'Choose the number of images to be analyzed'};
dialogTitle = 'Input';
dims = [1 35];
definput = {num2str(maxFileNumber)};
response = inputdlg(prompt,dialogTitle,dims,definput);
maxFileNumber=str2double(response{1});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Asking about the window size to be used
WindowSize=7;
prompt = {'Choose the pixel window size'};
dialogTitle = 'Input';
dims = [1 35];
definput = {num2str(WindowSize)};
response = inputdlg(prompt,dialogTitle,dims,definput);
WindowSize=str2double(response{1});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Asking if normalized or not normalized format should be shown
question = questdlg('Would you like to construct the normalized flow?', ...
	'LSCI anlysis', ...
	'No. Do not normalize it','Yes. Normalized it, please','Yes. Normalized it, please');

switch question
    case 'No. Do not normalize it'
        normalizationFlag=0;
    case 'Yes. Normalized it, please'
        normalizationFlag=1;  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Asking about the transformations on the images. If yes, you should
% specify that parameter lambda. Other codes help estimate a good value but
% not this one. For LSCI I realized that a number around 1.5 works the
% best.
question = questdlg('Would you like to use BoxCox transformation?', ...
	'LSCI anlysis', ...
	'No. Data is fine','Yes, Data is skewed','Yes, Data is skewed');

switch question
    case 'No. Data is fine'
        BoxCoxFlag=0;
    case 'Yes, Data is skewed'
        BoxCoxFlag=1;  
        BoxCoxDefault=1.5;
        prompt = {'Enter lambda for BoxCox transformation'};
        dialogTitle = 'Input';
        dims = [1 35];
        definput = {num2str(BoxCoxDefault)};
        response = inputdlg(prompt,dialogTitle,dims,definput);
        BoxCoxLambda=str2double(response{1});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
useUpdatedColors=0;
listOfrCBF={};
bodyFlag=1;
while bodyFlag==1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Asking about the whereabouts of the images...And if you want to analyze a
% new folder. Appropriate names should be given to the file names. They
% will be subtracted eventually.
    question = questdlg('Would you like to analyze a new folder?', ...
        'LSCI anlysis', ...
        'No. Done.','Yes, please','Yes, please');

    switch question
        case 'No. Done.'
            bodyFlag=0;
        break
    end

    prompt = {'Enter variable name (like Baseline, LeftLigation, RightLigation,etc.) :'};
    dialogTitle = 'Prefix selection';
    definput = {'Baseline'};
    dims = [1 40];
    opts.Interpreter = 'tex';
    dialogInput = inputdlg(prompt,dialogTitle,dims,definput,opts);
    prefix=string(dialogInput);
    listOfrCBF{end+1}=prefix;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reading the images by pop up window
    [file,path] = uigetfile('*.tiff', 'MultiSelect', 'on');

    tic;
%     if length(file)>maxFileNumber
%         file=file(1:maxFileNumber);
%     end

    fileName     = strcat(path,file);
    splittedPath = strsplit(path,'\');
    fileQuantity   = size(fileName,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This section only shows the raw image. Not really important in
% calculations. You may comment it out. I have used it to verify my code to
% read the address.

    image = imread(fileName{1,50});
    adjustedImage=imadjust(image);
    image=double(image);
    figure(1)
    imshow(adjustedImage)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    imageGPU=double(gpuArray(image));
    X=imageGPU*0;
    Kernel=ones(WindowSize,WindowSize,'gpuArray')/WindowSize^2;

    parfor counter=1:fileQuantity
    
        image = double(gpuArray(imread(fileName{1,counter})));
        if BoxCoxFlag==1
            image=(image.^BoxCoxLambda-1)/BoxCoxLambda;
        end
        imageSquareMean=conv2(image.^2,Kernel,'same');
        imageMean=conv2(image,Kernel,'same');
        imageMeanSquare=imageMean.^2;
        Iout=sqrt(abs(imageSquareMean-imageMeanSquare))./imageMean;
        X=X+Iout;   
    end

    kMean2D = X/fileQuantity;
    %flow=kMean2D;
    flow = 1./kMean2D.^2;
    flow=flip(flip(flow,1),2);
% Calculations ended here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if normalizationFlag==1
        normalizedFlow=(flow/mean2(flow));
        imageShow=normalizedFlow;
        titleString=strcat('Normalized. No. of images:',num2str(fileQuantity),' images: ',prefix);
    else
        titleString=strcat('Not Normalized. No. of images:',num2str(fileQuantity),' images: ',prefix);
        imageShow=flow;
    end   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Aksing about the quality of colorbar
    changeColor=1;
    while changeColor==1
        figure(2)
        imagesc(imageShow);
        title(titleString)
        xLabel=strcat('First image name: ',string(file(1)));
        xlabel(xLabel);
        colormap jet
        if useUpdatedColors==1
            caxis([lowerColor upperColor]);
        else
            lowerColor=0;
            upperColor=max(max(imageShow));
        end
        colorbar
    
        question = questdlg('Would you like to change the color map?', ...
        'LSCI anlysis', ...
        'No. It seems fine. Just save it','Yes. Change it','Yes. Change it');

        switch question
            case 'No. It seems fine. Just save it'
                changeColor=0;
            case 'Yes. Change it'
                useUpdatedColors=1;
                changeColor=1;
                prompt = {'Enter the upper value:','Enter the lower value:'};
                dialogTitle = 'Input';
                dims = [1 35];
                definput = {num2str(upperColor),num2str(lowerColor)};
                response = inputdlg(prompt,dialogTitle,dims,definput);
                upperColor=str2double(response{1});
                lowerColor=str2double(response{2});
        end  
        figureName = strcat('LSCI_',num2str(fileQuantity),'_Images',prefix,'.png');
        saveas(gcf,figureName); 

        eval(strcat('structure.',prefix,'=imageShow'));
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subtractions from here...
subtractionFlag=1;
lowerCap=0;
while subtractionFlag==1
    [index_1,tf_1] = listdlg('PromptString',{'Select A from the options:','A-B'}...
        ,'SelectionMode','single','ListString',listOfrCBF);
    image_RH=listOfrCBF{index_1};
    eval(strcat('nFlowImage_1=structure.',image_RH));
    [index_2,tf_2] = listdlg('PromptString',{'Select B from the options:','A-B'}...
        ,'SelectionMode','single','ListString',listOfrCBF);
    image_LH=listOfrCBF{index_2};
    eval(strcat('nFlowImage_2=structure.',image_LH));
    difference=nFlowImage_1-nFlowImage_2;
    
    modificationFlag=1;
    useUpdatedCaps=0;
    upperCap=floor(max(max(difference)));
    while modificationFlag==1
        figure(3)
        imagesc(difference);

        titleString=strcat('Differences. imagesQTY:',num2str(fileQuantity),'-',image_RH,'-',image_LH);
        title(titleString)
        colormap jet
        
        if useUpdatedCaps==1
            caxis([lowerCap upperCap]);
        end
        colorbar
        figureName = strcat('LSCI_diff',num2str(fileQuantity),'_',image_RH,'_',image_LH,'.png');

        imageQuality = questdlg('Was the image quality good?', ...
         'LSCI anlysis', ...
         'No. Change intensities boundaries','Yes. Save it','Yes. Save it');
        switch imageQuality
            case 'Yes. Save it'
            modificationFlag=0;
            saveas(gcf,figureName);
            case 'No. Change intensities boundaries'
            useUpdatedCaps=1;
            prompt = {'Enter the upper value:','Enter the lower value:'};
            dialogTitle = 'Input';
            dims = [1 35];
            definput = {num2str(upperCap),num2str(lowerCap)};
            response = inputdlg(prompt,dialogTitle,dims,definput);
            upperCap=str2double(response{1});
            lowerCap=str2double(response{2});            
        end
    end
    
    subFinished = questdlg('Do you have more subtraction?', ...
        'LSCI anlysis', ...
        'No. Thanks.','Yes, please','Yes, please');
    switch subFinished
        case 'No. Thanks.'
            subtractionFlag=0;
            break
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
    sizeImage=size(difference);
    xMin_RH=961;
    yMin_RH=431;
    width_RH=250;
    height_RH=250;

    xMin_LH=111;
    yMin_LH=331;
    width_LH=250;
    height_LH=250;
    
    xMin_Main=91;
    yMin_Main=101;
    width_Main=1150;
    height_Main=850;

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
    figure(4)
    imagesc(difference);
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
        
        
        
        
        image_RH=difference(yMin_RH:yMax_RH,xMin_RH:xMax_RH);
        figure(5)
        imagesc(image_RH);
        colormap jet
        colorbar
        title('RIO Right Hemisphere')
        saveas(gcf,'RightHemisphere.png');
        
        
        image_LH=difference(yMin_LH:yMax_LH,xMin_LH:xMax_LH);
        figure(6)
        imagesc(image_LH);
        colormap jet
        colorbar
        title('RIO Left Hemisphere')
        saveas(gcf,'LeftHemisphere.png');
        
        image_Main=difference(yMin_Main:yMax_Main,xMin_Main:xMax_Main);
        figure(7)
        imagesc(image_Main);
        colormap jet
        colorbar
        title('RIO Both Hemisphere')
        saveas(gcf,'WholeHeadSelected.png');
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
saveImages=0;
TimePointFlag=1;
averagingSize=100;
jump=20;
RH_ROI_List=[];
LH_ROI_List=[];
Main_ROI_List=[];
listOfrCBF={};
rCBF_marker=[];
while TimePointFlag==1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Asking about the whereabouts of the images...And if you want to analyze a
% new folder. Appropriate names should be given to the file names. They
% will be subtracted eventually.
    question = questdlg('Would you like to add a new folder?', ...
        'LSCI anlysis', ...
        'No. Done.','Yes, please','Yes, please');

    switch question
        case 'No. Done.'
            TimePointFlag=0;
        break
            
    end

    prompt = {'Enter variable name (like Baseline, LeftLigation, RightLigation,etc.) :'};
    dialogTitle = 'Prefix selection';
    definput = {'Baseline'};
    dims = [1 40];
    opts.Interpreter = 'tex';
    dialogInput = inputdlg(prompt,dialogTitle,dims,definput,opts);
    prefix=string(dialogInput);
    rCBF_marker(end+1)=length(RH_ROI_List);
    listOfrCBF{end+1}=prefix;

    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reading the images by pop up window
    [file,path] = uigetfile('F:\test_9weekmouse_1\LSCI\*.tiff', 'MultiSelect', 'on');
    numberOfImages=length(file);
    
    f = warndlg(strcat('Total images in the folder are: ',num2str(numberOfImages)),'Number of images');
 
    prompt = {'How many images should be averaged (e.g., N images)',...
        'Select the jump (e.g. select 50 if your next start point should be 51'};
    dlgtitle = 'Averaging size and overlaps';
    dims = [1 75];
    definput = {num2str(averagingSize),num2str(jump)};
    response = inputdlg(prompt,dlgtitle,dims,definput);
    averagingSize=str2double(response{1});
    jump=str2double(response{2});
    
    fileName     = strcat(path,file);
    folderSize   = size(fileName,2);
%     RH_ByFolder=zeros(1,folderSize);
%     LH_ByFolder=zeros(1,folderSize);
%     Main_ByFolder=zeros(1,folderSize);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    LSCI_Flag=1;
    Kernel=ones(WindowSize,WindowSize,'gpuArray')/WindowSize^2;
    tailStart=1;
    tailEnd=jump;
    headStart=1+averagingSize;
    headEnd=jump+averagingSize;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating 1 to 100 images. It makes our P1. It is also same as the
% middle section
        image = double(gpuArray(imread(fileName{1,1})));
        imageGPU=double(gpuArray(image));
        X_body=imageGPU*0;

        parfor counter=1:averagingSize
    
            image = double(gpuArray(imread(fileName{1,counter})));
            if BoxCoxFlag==1
                image=(image.^BoxCoxLambda-1)/BoxCoxLambda;
            end
            imageSquareMean=conv2(image.^2,Kernel,'same');
            imageMean=conv2(image,Kernel,'same');
            imageMeanSquare=imageMean.^2;
            Iout=sqrt(abs(imageSquareMean-imageMeanSquare))./imageMean;
            X_body=X_body+Iout;   
        end    
        
        
        kMean2D = X_body/fileQuantity;
        flow = 1./kMean2D.^2;
        flow=flip(flip(flow,1),2);
        
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
% Now simultaneously calculating 2 and 101

    while LSCI_Flag==1
        headfileName=fileName{1,headStart:headEnd};
        tailfileName=fileName{1,tailStart:tailEnd};
        fileQuantity   = averagingSize;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating front and back. Later tail (the smaller one) will be
% subtracted and back (the bigger one) will added
%%%%%%%%%%%%%%%%%  Tail %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        X_tail=imageGPU*0;
        parfor counter=tailStart:tailEnd
            image = double(gpuArray(imread(fileName{1,counter})));
            if BoxCoxFlag==1
                image=(image.^BoxCoxLambda-1)/BoxCoxLambda;
            end
            imageSquareMean=conv2(image.^2,Kernel,'same');
            imageMean=conv2(image,Kernel,'same');
            imageMeanSquare=imageMean.^2;
            Iout=sqrt(abs(imageSquareMean-imageMeanSquare))./imageMean;
            X_tail=X_tail+Iout;   
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Head  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        X_head=imageGPU*0;
        parfor counter=headStart:headEnd
            image = double(gpuArray(imread(fileName{1,counter})));
            if BoxCoxFlag==1
                image=(image.^BoxCoxLambda-1)/BoxCoxLambda;
            end
            imageSquareMean=conv2(image.^2,Kernel,'same');
            imageMean=conv2(image,Kernel,'same');
            imageMeanSquare=imageMean.^2;
            Iout=sqrt(abs(imageSquareMean-imageMeanSquare))./imageMean;
            X_head=X_head+Iout;   
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        X_body=X_body+X_head-X_tail;

        kMean2D = X_body/fileQuantity;
        flow = 1./kMean2D.^2;
        flow=flip(flip(flow,1),2);
        
        image_RH=flow(yMin_RH:yMax_RH,xMin_RH:xMax_RH);
        box_RH_Mean=mean(mean(image_RH));
        RH_ROI_List(end+1)=box_RH_Mean;
        
        image_LH=flow(yMin_LH:yMax_LH,xMin_LH:xMax_LH);
        box_LH_Mean=mean(mean(image_LH));
        LH_ROI_List(end+1)=box_LH_Mean;
        
        image_Main=flow(yMin_Main:yMax_Main,xMin_Main:xMax_Main);
        box_Main_Mean=mean(mean(image_Main));
        Main_ROI_List(end+1)=box_Main_Mean;
        
        
        if saveImages==1
            imageShow=flow;
            figure(7)
            imagesc(imageShow);
            titleString=strcat(num2str(fileQuantity),' images: ',...
                prefix, ' RH mean: ',num2str(round(box_RH_Mean)),' LH mean: ',...
                num2str(round(box_LH_Mean)),' Main mean: ',num2str(round(box_Main_Mean)),...
                ', ',num2str(nameStart),'-', num2str(nameEnd));
            title(titleString);
            xLabel=strcat('First image name: ',string(file(nameStart)));
            xlabel(xLabel);
            colormap jet
            colorbar
            figureName = strcat('LSCI_',num2str(fileQuantity),'_Images',prefix,'_',num2str(nameStart),'_', num2str(nameEnd),'.png');
            saveas(gcf,figureName);
        end
        
        tailStart=tailStart+jump
        tailEnd=tailEnd+jump
        headStart=headStart+jump
        headEnd=headEnd+jump
        
        if headEnd>folderSize
            headEnd=folderSize;
        end

        if headStart>=folderSize
            break
        end
    end
    listOfrCBF

    if ishandle(h) && strcmp(get(h, 'type'), 'figure')
        close (h)
    end
    h=figure(8)
    plot(RH_ROI_List,'red')
    hold on
    plot(LH_ROI_List,'blue')
    hold on
    plot(Main_ROI_List,'magenta')  
    for ii=1:length(rCBF_marker)
        xline(rCBF_marker(ii),'-.g',listOfrCBF(ii))
    end
    

end

figure(9) 
plot(RH_ROI_List,'red')
hold on
plot(LH_ROI_List,'blue')
hold on
plot(Main_ROI_List,'magenta')   

ylabel('Intensities on CBF')
xlabelString=strcat('Time (',num2str(jump),' frames or ',num2str(jump/1000),'th of minute)')
xlabel(xlabelString)
legend('RH_ROI','LH_ROI')

for ii=1:length(rCBF_marker)
    xline(rCBF_marker(ii),'-.g',listOfrCBF(ii))
end

legend('RH','LH', 'Main')
titleString='Cardiac Arrest';
title(titleString);
figureName='TimePlot_CardiacArrest';
figureNamepng=strcat(figureName,'.png');
saveas(gcf,figureName);
saveas(gcf,figureNamepng);

baselineLength=rCBF_marker(2)

RH_BaselineMean=mean(RH_ROI_List(1:baselineLength));
LH_BaselineMean=mean(LH_ROI_List(1:baselineLength));
Main_BaselineMean=mean(Main_ROI_List(1:baselineLength));

RH_normalized=RH_ROI_List/RH_BaselineMean;
LH_normalized=LH_ROI_List/LH_BaselineMean;
Main_normalized=Main_ROI_List/Main_BaselineMean;

figure(10) 
plot(RH_normalized,'red')
hold on
plot(LH_normalized,'blue')
hold on
plot(Main_normalized,'magenta')
ylabel('Intensities on CBF')
xlabel(xlabelString)

for ii=1:length(rCBF_marker)
    xline(rCBF_marker(ii),'-.g',listOfrCBF(ii))
end

legend('RH','LH', 'Main')
titleStringN=strcat(titleString,' Normalized');
title(titleStringN);
figureNameN=strcat(figureName,'_Normalized');
figureNamepng=strcat(figureNameN,'.png');
saveas(gcf,figureNameN);
saveas(gcf,figureNamepng);


toc


