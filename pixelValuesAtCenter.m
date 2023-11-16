close all;
clear all;
clc;



[file1,path1] = uigetfile('F:\*.tiff', 'MultiSelect','on');
splittedPath=strsplit(path1,'\');
folderName_=cell2mat(splittedPath(end-1));
folderName=strrep(folderName_,'_','-');
imagePrefix='image_';
imageName1=strcat(path1,'image_0.tiff');
image1=imread(imageName1);
adjustedImage1=imadjust(image1);

fileN_Start=0;
fileN_End=length(file1)-1;
fileLength=fileN_End-fileN_Start+1;
   
xMin=210;
yMin=90;
width=70;
height=80;
    
xMax=xMin+width;
yMax=yMin+height;
selectRectangle=1;


while selectRectangle==1
    figure(1)
    imshow(adjustedImage1);
    title('Select the right position for the rectangle');

    rectangle('Position',[xMin yMin width height],'EdgeColor','r')
    text((xMin+30), (yMin+30),'Main ROI')

    prompt = {'Enter X Main minimum','Enter Y Main minimum','Enter width Main','Enter height Main' };
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {num2str(xMin),num2str(yMin),num2str(width),num2str(height)};
    response = inputdlg(prompt,dlgtitle,dims,definput);
    if isempty(response)
        selectRectangle=0;
        saveas(gcf,'SelectedRectangles.png');
    else

        
        xMin=str2double(response{1});
        yMin=str2double(response{2}); 
        width=str2double(response{3});
        height=str2double(response{4});
        

        xMax=xMin+width;
        yMax=yMin+height;
        
    end
end



sumSubImage=zeros(fileLength,1);
meanSubImage=zeros(fileLength,1);
sumGrtrThan800=zeros(fileLength,1);
meanGrtrThan800=zeros(fileLength,1);
sumBetween500_800=zeros(fileLength,1);
meanBetween500_800=zeros(fileLength,1);
sumBetween300_500=zeros(fileLength,1);
meanBetween300_500=zeros(fileLength,1);
sumBetween100_300=zeros(fileLength,1);
meanBetween100_300=zeros(fileLength,1);
sumLessThan100=zeros(fileLength,1);
meanLessThan100=zeros(fileLength,1);


for imageN_=fileN_Start:fileN_End
    imageName=strcat(path1,'image_',num2str(imageN_),'.tiff');
    imageN=imageN_+1;
    image=double(imread(imageName));
    subImage=image(yMin:yMax,xMin:xMax);
    
    sumSubImage(imageN)=sum(subImage,'all');
    meanSubImage(imageN)=mean(subImage,'all');
    
    grtrThan800=subImage>800;
    countGrtrThan800=sum(grtrThan800,'all');
    subImage_GrtrThan800=grtrThan800.*subImage;
    sumGrtrThan800(imageN)=sum(subImage_GrtrThan800,'all');
    meanGrtrThan800(imageN)=sumGrtrThan800(imageN)/countGrtrThan800;
    
    between500_800=(subImage>500 & subImage<800);
    countBetween500_800=sum(between500_800,'all');
    subImage_Between500_800=between500_800.*subImage;
    sumBetween500_800(imageN)=sum(subImage_Between500_800,'all');
    meanBetween500_800(imageN)=sumBetween500_800(imageN)/countBetween500_800;
    
    
    between300_500=(subImage>300 & subImage<500);
    countBetween300_500=sum(between300_500,'all');
    subImage_Between300_500=between300_500.*subImage;
    sumBetween300_500(imageN)=sum(subImage_Between300_500,'all');
    meanBetween300_500(imageN)=sumBetween300_500(imageN)/countBetween300_500;
    
    between100_300=(subImage>200 & subImage<300);
    countBetween100_300=sum(between100_300,'all');
    subImage_Between100_300=between100_300.*subImage;
    sumBetween100_300(imageN)=sum(subImage_Between100_300,'all');
    meanBetween100_300(imageN)=sumBetween100_300(imageN)/countBetween100_300;
    
    lessThan100=subImage<100;
    countLessThan100=sum(lessThan100,'all');
    subImage_LessThan100=lessThan100.*subImage;
    sumLessThan100(imageN)=sum(subImage_LessThan100,'all');
    meanLessThan100(imageN)=sumLessThan100(imageN)/countLessThan100;

end

figure(2)
plot(meanSubImage)
title(folderName)
ylabel('mean intensity')
xlabel('slice')
legend('selected ROI')
saveas(gcf,'ROI.png');

figure(3)
plot(meanSubImage)
hold on
plot(meanGrtrThan800)
hold on
plot(meanBetween500_800)
hold on
plot(meanBetween300_500)
hold on
plot(meanBetween100_300)
hold on
plot(meanLessThan100)
hold off
title(folderName)
ylabel('mean intensity')
xlabel('slice')
legend({'SubImage','GrtrThan800','Between500-800','Between300-500','Between100-300','LessThan100'},'Location','northeast')
saveas(gcf,'ROI_1.png');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


imageName=strcat(path1,'image_',num2str(0),'.tiff');
image=double(imread(imageName));
subImage=image(yMin:yMax,xMin:xMax);

grtrThan800=subImage>800;
between500_800=(subImage>500 & subImage<800);
between300_500=(subImage>300 & subImage<500);
between100_300=(subImage>200 & subImage<300);
lessThan100=subImage<100;


for imageN_=fileN_Start:fileN_End
    imageName=strcat(path1,'image_',num2str(imageN_),'.tiff');
    imageN=imageN_+1;
    image=double(imread(imageName));
    subImage=image(yMin:yMax,xMin:xMax);
    
    sumSubImage(imageN)=sum(subImage,'all');
    meanSubImage(imageN)=mean(subImage,'all');
    
    
    countGrtrThan800=sum(grtrThan800,'all');
    subImage_GrtrThan800=grtrThan800.*subImage;
    sumGrtrThan800(imageN)=sum(subImage_GrtrThan800,'all');
    meanGrtrThan800(imageN)=sumGrtrThan800(imageN)/countGrtrThan800;
    
    
    countBetween500_800=sum(between500_800,'all');
    subImage_Between500_800=between500_800.*subImage;
    sumBetween500_800(imageN)=sum(subImage_Between500_800,'all');
    meanBetween500_800(imageN)=sumBetween500_800(imageN)/countBetween500_800;
    
    
    
    countBetween300_500=sum(between300_500,'all');
    subImage_Between300_500=between300_500.*subImage;
    sumBetween300_500(imageN)=sum(subImage_Between300_500,'all');
    meanBetween300_500(imageN)=sumBetween300_500(imageN)/countBetween300_500;
    
    
    countBetween100_300=sum(between100_300,'all');
    subImage_Between100_300=between100_300.*subImage;
    sumBetween100_300(imageN)=sum(subImage_Between100_300,'all');
    meanBetween100_300(imageN)=sumBetween100_300(imageN)/countBetween100_300;
    
    
    countLessThan100=sum(lessThan100,'all');
    subImage_LessThan100=lessThan100.*subImage;
    sumLessThan100(imageN)=sum(subImage_LessThan100,'all');
    meanLessThan100(imageN)=sumLessThan100(imageN)/countLessThan100;

end

figure(4)
plot(meanSubImage)
title(folderName)
ylabel('mean intensity')
xlabel('slice')
legend('selected ROI')
saveas(gcf,'ROI_2.png');

figure(5)
plot(meanSubImage)
hold on
plot(meanGrtrThan800)
hold on
plot(meanBetween500_800)
hold on
plot(meanBetween300_500)
hold on
plot(meanBetween100_300)
hold on
plot(meanLessThan100)
hold off
title(folderName)
ylabel('mean intensity')
xlabel('slice')
legend({'SubImage','GrtrThan800','Between500-800','Between300-500','Between100-300','LessThan100'},'Location','northeast')
saveas(gcf,'ROI_3.png');





