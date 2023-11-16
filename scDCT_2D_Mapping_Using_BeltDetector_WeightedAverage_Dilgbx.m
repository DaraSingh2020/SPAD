clc;
close all;
clear all;
prompt = {'\bf\fontsize{12} Enter Root Directory:',...
          '\bf\fontsize{12} Enter Number of Images:',...
          '\bf\fontsize{12} Enter Belt Tickness:',...
          '\bf\fontsize{12} Enter Window Size:',...
          '\bf\fontsize{12} Enter Number of Pixels in 1mm'};
dlgtitle = '2D Mapping Parameters';
dims = [1 60];
definput = {'I:\Solid_Phantom_Comp_scDCT_with_LSCI\1mm_scDCT\Phantom_src30_2ms_5Fr_1mm_1\Pos0\','500','1','7','34'};
opts.Interpreter = 'tex';
opts.WindowStyle = 'normal'; 
inputData = inputdlg(prompt,dlgtitle,dims,definput,opts);
rootDirectory = (inputData{1});
fileQuantity = str2double(inputData{2});
step = str2double(inputData{3});
windowSize  = str2double(inputData{4});
radiusConversionF  = str2double(inputData{5});


for innerRadiusMM = 1:6
tic
warning off
clearvars -except rootDirectory fileQuantity step windowSize radiusConversionF innerRadiusMM

depth = 1; % Phantom depth size
cd(rootDirectory(1:end-5))

X = double(gpuArray(imread(strcat(rootDirectory, sprintf('img_%09d', 1), '_Default_000.tif'))))*0;
[columnsInImage, rowsInImage] = meshgrid(1:size(X,1), 1:size(X,2));
X_mask = X;

Kernel=ones(windowSize,windowSize,'gpuArray')/windowSize^2;
loopStart=0;
loopEnd=fileQuantity-1;

outerRadiusMM = innerRadiusMM + step;
innerRadiusPix=round(innerRadiusMM*radiusConversionF);
outerRadiusPix=round(outerRadiusMM*radiusConversionF);

parfor counter=loopStart:loopEnd
    imageName=strcat(rootDirectory, sprintf('img_%09d', counter), '_Default_000.tif');
    imageCPU = imread(imageName);
    mask=detectorMask(imageCPU,columnsInImage, rowsInImage,outerRadiusPix,innerRadiusPix);
    image=double(gpuArray(imageCPU));
    imageSquare=image.^2;
    imageSquareMean=conv2(imageSquare,Kernel,'same');
    imageMean=conv2(image,Kernel,'same');
    imageMeanSquare=imageMean.^2;
    image=sqrt(abs(imageSquareMean-imageMeanSquare))./imageMean;
    image(~mask)= 0; 
    X= X + image;   
    X_mask = X_mask + mask;
end

X_mask_inv=1./X_mask;
X_mask_inv(isinf(X_mask_inv))=0;
X = X.*X_mask_inv;
Kmean_2D = X;   

%%
% L1 = 1;
% H1 = 2048;

% % For 2048, UK_Phantom: 1mm
L1 = 1;
H1 = 2048;
limitX = (L1:H1);
limitY = (L1:H1);
Kmean_2D_Crop = Kmean_2D((limitX(1):limitX(end)),(limitY(1):limitY(end)));

figure
flow = (1./Kmean_2D_Crop.^2);
normalizedFlow=flow/mean2(flow);
imagesc(normalizedFlow) 
titleSTR=strcat('windowSize', num2str(windowSize),'R1=',num2str(innerRadiusMM),'mm R2=',num2str(outerRadiusMM),'mm');
title(titleSTR)
colormap(hot)
axis off;
%hco = colorbar('hot','Location','eastoutside');
colorbar
set(hco,'FontSize',20, 'FontWeight','Bold')
set(gca,'fontsize',20)
x0=20;
y0=20;
width = 650;
height = 500;
set(gcf,'position',[x0,y0,width,height])
ax1 = gca;                   % gca = get current axis
ax1.YAxis.Visible = 'off';   % remove y-axis
ax1.XAxis.Visible = 'off';   % remove x-axis
set(gca,'XTickLabel',{' '})
set(gca,'YTickLabel',{' '})
caxis([0.01,1.6])
%pngFigureName1=strcat('Phantom_Weighted_Mask_','windowSize',num2str(windowSize),'_Pixel_',depth,'mm_R1_',num2str(innerRadiusMM),'mm_R2_',num2str(outerRadiusMM),'mm.png');
%saveas(gcf,pngFigureName1); 
%pngFigureName2=strcat('Phantom_Weighted_Mask_','windowSize',num2str(windowSize),'_Pixel_',depth,'mm_R1_',num2str(innerRadiusMM),'mm_R2_',num2str(outerRadiusMM),'mm.fig');
%saveas(gcf,pngFigureName2);


image8=uint8(255 * mat2gray(imadjust(normalizedFlow)));
rgbImage = cat(3, image8, image8, image8);
C = strsplit(rootDirectory,'\');
namePart_1=C{end-2};
namePart_2=strcat('_R1_',num2str(innerRadiusMM),'mm_R2_',num2str(outerRadiusMM),'mm');
imageName=strcat(namePart_1,namePart_2,'.jpg');

size(rgbImage)
imwrite(rgbImage,imageName,'jpg')

% str = ['Phantom_Weighted_Mask_','windowSize', num2str(windowSize),'_Pixel_',depth,'mm_R1_',num2str(innerRadiusMM),'mm_R2_',num2str(outerRadiusMM * 10),'mm = X;']; eval(str);
% str2 = ['save(''Phantom_Weighted_Mask_','windowSize', num2str(windowSize),'_Pixel_',depth,'mm_R1_',num2str(innerRadiusMM),'mm_R2_',num2str(outerRadiusMM * 10),'mm'', ''Phantom_Weighted_Mask_','windowSize', num2str(windowSize),'_Pixel_',depth,'mm_R1_',num2str(innerRadiusMM),'mm_R2_',num2str(outerRadiusMM * 10),'mm*'');'];
% str3 = ['save(''Phantom_Weighted_Mask_','windowSize', num2str(windowSize),'_Pixel_',depth,'mm_R1_',num2str(innerRadiusMM),'mm_R2_',num2str(outerRadiusMM * 10),'mm'');'];
% eval(str2);
% eval(str3);
toc

end

%% FUNCTION

function mask=detectorMask(imageCPU,columnsInImage, rowsInImage,outerRadiusPix,innerRadiusPix)
    imageCPU = imbinarize(uint16(imageCPU));
    LabeledMatrix = bwlabel(imageCPU, 8);               % Determine the connected components
    S = regionprops(LabeledMatrix, 'Area');             % Compute the area of each component
    P = max( [S.Area] );
    NewX = ismember(LabeledMatrix, find([S.Area] >= P));% Remove small objects.
    op = imopen (NewX, ones(5,5));
    LabeledMatrix = bwlabel(op, 8);                     % Determine the connected components
    S = regionprops(LabeledMatrix, 'Area');             % Compute the area of each component
    P = max( [S.Area] );
    opg = ismember(LabeledMatrix, find([S.Area] >= P)); % Remove small objects.
    cl = imclose (opg, ones(5,5));
    cl(:,:,1) = imfill(double(cl(:,:,1)));
    Fcl = imfill (double(cl));
    stats = regionprops('table',Fcl,'Centroid','EquivDiam');
    centerX = stats.Centroid(1);
    centerY = stats.Centroid(2);
    mask = (rowsInImage - centerY).^2 + (columnsInImage - centerX).^2 <= outerRadiusPix.^2 & (rowsInImage - centerY).^2 + (columnsInImage - centerX).^2 >= innerRadiusPix.^2 ;
end
