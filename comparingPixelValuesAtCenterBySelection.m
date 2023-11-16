close all;
clear all;
clc;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Addresses %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
selectRectangle=1;
numberOfComparision=3;
xMin=210;
yMin=90;
width=100;
height=80;
xMax=xMin+width;
yMax=yMin+height;

for i=1:numberOfComparision
    [file,path] = uigetfile('F:\*.tiff', 'MultiSelect','on');
    splittedPath=strsplit(path,'\');
    folderName_=cell2mat(splittedPath(end-1));
    folderName=strrep(folderName_,'_','-');

    imagePrefix='image_';
    imageName=strcat(path,'image_0.tiff');
    image1=imread(imageName);
    adjustedImage=imadjust(image1);

    fileN_Start=0;
    fileN_End=length(file)-1;
    fileLength=fileN_End-fileN_Start+1;
    
    if selectRectangle==1
        [xMin,yMin,width,height,selectRectangle]=ChooseRectangle(selectRectangle,xMin,yMin,width,height,adjustedImage);
    end

    
%     Path=strcat('path=path_',num2str(folder),';');
%     eval(Path);
    sumBetween100_300=zeros(fileLength,1);
    meanBetween100_300=zeros(fileLength,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    imageName=strcat(path,'image_',num2str(0),'.tiff');
    image=double(imread(imageName));
    subImage=image(yMin:yMax,xMin:xMax);

    between100_300=(subImage>100 & subImage<300);



    for imageN_=fileN_Start:fileN_End
        imageName=strcat(path,'image_',num2str(imageN_),'.tiff');
        imageN=imageN_+1;
        image=double(imread(imageName));
        subImage=image(yMin:yMax,xMin:xMax);
    
    
        countBetween100_300=sum(between100_300,'all');
        subImage_Between100_300=between100_300.*subImage;
        sumBetween100_300(imageN)=sum(subImage_Between100_300,'all');
        meanBetween100_300(imageN)=sumBetween100_300(imageN)/countBetween100_300;
    
    end


    figure(2)
    plot(meanBetween100_300)
%     helper=strcat('folderName=folderName_',num2str(folder),';');
%     eval(helper);
    Title=(folderName(1:40));

    title(Title)
    ylabel('mean intensity')
    xlabel('slice')
    saveAs=strcat(Title,'.png');
    saveas(gcf,saveAs);
    
    
    variableName=folderName(1:3);
    variableName=strrep(variableName,'-','_');
    variableName_=strcat('V_',variableName,'=meanBetween100_300;');
    eval(variableName_);

end

return



figure(3)
ylabel('mean intensity')
xlabel('slice')

plot(V_4_P)
hold on
plot(V_5_P)
hold on
plot(V_6_P)

hold off
legend({'V-4-P','V-5-P','V-6-P'},'Location','northeast')
saveas(gcf,'ROI_1.png');







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% DO NOT TOUCH THE FUNCTION BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function[xMin,yMin,width,height,selectRectangle]=ChooseRectangle(selectRectangle,xMin,yMin,width,height,adjustedImage)
while selectRectangle==1
    figure(1)
    imshow(adjustedImage);
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
selectRectangle=0;
end