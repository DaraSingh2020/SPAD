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
    maxFileNumber=1000; %Choose the number of files you want to use
    if length(file)>maxFileNumber
        file=file(1:maxFileNumber);
    end

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
    flow = 1./kMean2D.^2;
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
    image_1=listOfrCBF{index_1};
    eval(strcat('nFlowImage_1=structure.',image_1));
    [index_2,tf_2] = listdlg('PromptString',{'Select B from the options:','A-B'}...
        ,'SelectionMode','single','ListString',listOfrCBF);
    image_2=listOfrCBF{index_2};
    eval(strcat('nFlowImage_2=structure.',image_2));
    difference=nFlowImage_1-nFlowImage_2;
    
    modificationFlag=1;
    useUpdatedCaps=0;
    upperCap=floor(max(max(difference)));
    while modificationFlag==1
        figure(3)
        imagesc(difference);

        titleString=strcat('Differences. imagesQTY:',num2str(fileQuantity),'-',image_1,'-',image_2);
        title(titleString)
        colormap jet
        
        if useUpdatedCaps==1
            caxis([lowerCap upperCap]);
        end
        colorbar
        figureName = strcat('LSCI_diff',num2str(fileQuantity),'_',image_1,'_',image_2,'.png');

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
toc