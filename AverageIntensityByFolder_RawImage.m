% convolution filter and multiple CPUs and gpuArray

close all
clc
clear all
warning off
tic;
%rootDirectory='F:\Test_Data_SPAD_Dec9th2021\output_images';  %Item1

%Item2:
%rootDirectory='F:\11_GatedMode_Ligation_P600mw_exp5.36_31nsOff_18psdelay_F11_mouse_Pol_NOConcave_Pellicle_ZoomedIn_Withpad\1_BL\output_imagesBL';

%item3:
rootDirectory='F:\test_Phantom_MultipleBatches_GatedMode_01102021\7_P400mw_exp5.36_31nsOff_18psdelay_F11bw22_Ph_MultipleBatches_Pol_NOConcave_Pellicle_ZoomedIn_Withpad\output_imagesTrianglePhan';

imagePrifix='image_';  

%% Select the file numbers over which intensity is being analyzed

fileN1=10;  %default 0 for image number 1
fileN2=10;  %change it to 19 to get LSCI of the first 20 images
% It means we will have 20 points
fileLength=fileN2-fileN1+1; %files are the images within the folder
%
%% for selecting folder numbers changes the below variables
%folders contain files
folderN1=1;
folderN2=80;
folderLenght=folderN2-folderN1+1;

%image quantity is files in each folder selected times the number of
%folders
fileQuantity=fileLength*folderLenght;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% firstImage reads the first image. We need its size:

firstImageName=strcat(rootDirectory,num2str(folderN1),'\',imagePrifix,num2str(fileN1),'.tiff');
firstImage = imread(firstImageName);
disp(strcat('The size of the first image is: ',num2str(size(firstImage))));
adjustedImage=imadjust(firstImage);
disp('Choose the selected pixels, then right-click and the choose crop')
[~,rectOut] = imcrop(adjustedImage);

% ---> is x-direction and downward is y-direction the the following output.
% It's different from raw and column but can be related to each other.
xMin=floor(rectOut(1));
yMin=floor(rectOut(2));
newRawSize=floor(rectOut(3))+2
newColSize=floor(rectOut(4))+2
xMax=floor(rectOut(1)+rectOut(3));
yMax=floor(rectOut(2)+rectOut(4));
subMatrix=zeros(newColSize,newRawSize);

close all
subImageMean=zeros(folderLenght,1);

for folderNumber=folderN1:folderN2
    folderName=strcat(rootDirectory,num2str(folderNumber),'\');
    subImageMean_helper=0;
    parfor fileNumber=fileN1:fileN2
        imageNames=strcat(folderName,imagePrifix,num2str(fileNumber),'.tiff');
        image = imread(imageNames);
        subImage=double(image(yMin:yMax,xMin:xMax));
        subImageMean_helper=subImageMean_helper+mean2(subImage);
    end
    subImageMean(folderNumber)=subImageMean_helper;
end
%%
plot(subImageMean)
title('<I> over first images of each folder in selected regions')
ylabel('Average Intensity')
xlabel('Folder Number')
figName='IntensitySubRectBoxFirstImage80Folders';
figNamePNG=strcat(figName,'.png');

saveas(gcf,figName);
saveas(gcf,figNamePNG);

toc