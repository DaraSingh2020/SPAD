close all;
clear all;
clc;

% dark image #0
darkImagePath1='D:\LSCI_Image_Data\test_112021_13ns_DarkImage_gated\image_0.tiff';
darkImage1=imread(darkImagePath1);
fig1=figure('Name','Dark Image: 0');
imshow(imadjust(darkImage1))
title('dark image 0')

% dark image #1
darkImagePath2='D:\LSCI_Image_Data\test_112021_13ns_DarkImage_gated\image_99.tiff';
darkImage2=imread(darkImagePath2);
fig2=figure('Name','Dark Image 99');
imshow(imadjust(darkImage2))
title('dark image 99')

% the difference between dark image #0 and #1
darkImageD=darkImage2-darkImage1;
figD=figure('Name','Dark Image Differences');
imshow(imadjust(darkImageD))
title('(dark image 99)-(dark image 0)')

%
darkImage1double=double(darkImage1);
darkImage2double=double(darkImage2);

% finding top 98th percentile value:
darkImage1_98thP = prctile(darkImage1double,99.0,"all");
darkImage2_98thP = prctile(darkImage2double,99.0,"all");

% just making a copy:
darkI1=darkImage1double;
darkI2=darkImage2double;


% if a pixel value is more or equal to 98th percentile make it one otherwise
% make it zero:
darkI1(darkI1<=darkImage1_98thP)=0;
darkI1(darkI1>darkImage1_98thP)=1;

darkI2(darkI2<=darkImage1_98thP)=0;
darkI2(darkI2>darkImage1_98thP)=1;

% see what percentiles are equal to or more than 98th percentile:
check1=sum(darkI1,'all')/(256*512);
check2=sum(darkI2,'all')/(256*512);
disp(strcat('In dark image #0 proportion greater or equal to 98th percentile are: ',num2str(check1)))
disp(strcat('In dark image #99 proportion greater or equal to 98th percentile are: ',num2str(check2)))

% absolute value of the difference should show non-identical top 98%
darkI_diff=abs(darkI1-darkI2);
checkdiff=sum(darkI_diff,'all')/(256*512);
disp(strcat('Top 98th percentiles do not share same value in: ',num2str(checkdiff*100*100/2),'% of pixels'))

