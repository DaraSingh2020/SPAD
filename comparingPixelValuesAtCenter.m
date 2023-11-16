close all;
clear all;
clc;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Addresses %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

path_11='F:\test_PythonCode_04082022\11_P5mw_exp5.36_20nsOffset_18psdelay_mirror_1000img_Pol_Conc\';
splittedPath=strsplit(path_11,'\');
folderName_11_=cell2mat(splittedPath(end-1));
folderName_11=strrep(folderName_11_,'_','-');

path_12='F:\test_PythonCode_04082022\12_P100mw_exp5.36_20nsOffset_18psdelay_mirror_1000img_NoSourcePol_Conc\';
splittedPath=strsplit(path_12,'\');
folderName_12_=cell2mat(splittedPath(end-1));
folderName_12=strrep(folderName_12_,'_','-');


path_13='F:\test_PythonCode_04082022\13_P5mw_exp5.36_20nsOffset_18psdelay_mirror_1000img_NoSourcePol_Conc\';
splittedPath=strsplit(path_13,'\');
folderName_13_=cell2mat(splittedPath(end-1));
folderName_13=strrep(folderName_13_,'_','-');

path_13U='F:\test_PythonCode_04082022\13_P5mw_exp5.36_20nsOffset_18psdelay_mirror_1000img_NoSourcePol_NOConc_psinc3Unchecked\';
splittedPath=strsplit(path_13U,'\');
folderName_13U_=cell2mat(splittedPath(end-1));
folderName_13U=strrep(folderName_13U_,'_','-');


path_14='F:\test_PythonCode_04082022\14_P1mw_exp5.36_20nsOffset_18psdelay_mirror_1000img_NoSourcePol_NOConc_psinc3Unchecked\';
splittedPath=strsplit(path_14,'\');
folderName_14_=cell2mat(splittedPath(end-1));
folderName_14=strrep(folderName_14_,'_','-');


path_15='F:\test_PythonCode_04082022\15_P5mw_exp5.36_20nsOffset_18psdelay_mirror_1000img_NoSourcePol_NOConc_psinc3checked\';
splittedPath=strsplit(path_15,'\');
folderName_15_=cell2mat(splittedPath(end-1));
folderName_15=strrep(folderName_15_,'_','-');

path_16='F:\test_PythonCode_04082022\16_P100mw_exp5.36_20nsOffset_18psdelay_mirror_1000img_NoSourcePol_NOConc_psinc3checked\';
splittedPath=strsplit(path_16,'\');
folderName_16_=cell2mat(splittedPath(end-1));
folderName_16=strrep(folderName_16_,'_','-');

path_17='F:\test_PythonCode_04082022\17_P100mw_exp5.36_20nsOffset_18psdelay_mirror_1000img_NoSourcePol_NOConc_psinc3checked_SidePath_notCorrect\';
splittedPath=strsplit(path_17,'\');
folderName_17_=cell2mat(splittedPath(end-1));
folderName_17=strrep(folderName_17_,'_','-');

path_18='F:\test_PythonCode_04082022\18_P5mw_exp5.36_20nsOffset_18psdelay_mirror_1000img_NoSourcePol_NOConc_psinc3checked_SidePath\';
splittedPath=strsplit(path_18,'\');
folderName_18_=cell2mat(splittedPath(end-1));
folderName_18=strrep(folderName_18_,'_','-');

path_19='F:\test_PythonCode_04082022\19_P100mw_exp5.36_20nsOffset_18psdelay_mirror_1000img_NoSourcePol_NOConc_psinc3checked_SidePath\';
splittedPath=strsplit(path_19,'\');
folderName_19_=cell2mat(splittedPath(end-1));
folderName_19=strrep(folderName_19_,'_','-');

path_20='F:\test_PythonCode_04082022\20_P100mw_exp5.36_20nsOffset_18psdelay_mirror_1000img_NoSourcePol_NOConc_psinc3checked_SidePath_16.5WD\';
splittedPath=strsplit(path_20,'\');
folderName_20_=cell2mat(splittedPath(end-1));
folderName_20=strrep(folderName_20_,'_','-');

path_21='F:\test_PythonCode_04082022\21_P5mw_exp5.36_20nsOffset_18psdelay_mirror_1000img_NoSourcePol_NOConc_psinc3checked_SidePath_16.5WD\';
splittedPath=strsplit(path_21,'\');
folderName_21_=cell2mat(splittedPath(end-1));
folderName_21=strrep(folderName_21_,'_','-');

path_22='F:\test_PythonCode_04082022\22_P200mw_exp5.36_20nsOffset_18psdelay_mirror_1000img_NoSourcePol_NOConc_psinc3checked_SidePath_16.5WD\';
splittedPath=strsplit(path_22,'\');
folderName_22_=cell2mat(splittedPath(end-1));
folderName_22=strrep(folderName_22_,'_','-');

path_23='F:\test_PythonCode_04082022\23_P200mw_exp5.36_30nsOffset_18psdelay_3lightUKph_1000img_NoSourcePol_NOConc_psinc3checked_SidePath_16.5WD\';
splittedPath=strsplit(path_23,'\');
folderName_23_=cell2mat(splittedPath(end-1));
folderName_23=strrep(folderName_23_,'_','-');

path_24='F:\test_PythonCode_04082022\24_P50mw_exp5.36_30nsOffset_18psdelay_3lightUKph_1000img_NoSourcePol_NOConc_psinc3checked_SidePath_16.5WD\';
splittedPath=strsplit(path_24,'\');
folderName_24_=cell2mat(splittedPath(end-1));
folderName_24=strrep(folderName_24_,'_','-');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  Choosing the ROI based on the first image of the first folder and
%%%%%%  prepare the intial values for that purpose.

imagePrefix='image_';
imageName1=strcat(path_11,'image_0.tiff');
image1=imread(imageName1);
adjustedImage1=imadjust(image1);

fileN_Start=0;
fileN_End=999;
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



for folder=11:24

    
    Path=strcat('path=path_',num2str(folder),';');
    eval(Path);
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
    helper=strcat('folderName=folderName_',num2str(folder),';');
    eval(helper);
    Title=(folderName(1:40));

    title(Title)
    ylabel('mean intensity')
    xlabel('slice')
    saveAs=strcat(Title,'.png');
    saveas(gcf,saveAs);
    
    variableName=strcat('p',num2str(folder),'_meanBetween100_300=meanBetween100_300;');
    eval(variableName);

end


figure(3)
ylabel('mean intensity')
xlabel('slice')

plot(p11_meanBetween100_300)
hold on
plot(p13_meanBetween100_300)
hold on
plot(p14_meanBetween100_300)
hold on
plot(p15_meanBetween100_300)
hold on
plot(p18_meanBetween100_300)
hold off
legend({'p11','p13','p14','p15','p18'},'Location','n    ortheast')
saveas(gcf,'ROI_1.png');


