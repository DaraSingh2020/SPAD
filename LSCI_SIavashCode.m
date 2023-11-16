% Testing SPAD camera 
% v4: 1/22/21 
% Try to remove the spot form 01/18/21 data 
% v6: 01/23/21 done parts: showing the LSCI with/without hotspot (tryied on 01/20/21 data)
% v7: add pile-up correction to the system. 
% Pile-up correction for 10 bit images: n=-ln(1-m/255)*255
% Pile-up correction for 8 bit images: n= -ln(1-m/1020)*1020
% v8: just a different date: 01-18-21 data aquisition duty 60% and f 5.6

% for next verion, remove the very low density data (maybe intensity below 10)

close all
clear all
warning off
tic

frequency = 20e6;             % 20 MHZ
dutyCycle = 0.5;             % Duty cycle 
gateLength= 13.1;            % Gate length 
imageN = 90;            % Number of Images REcorded 
shift = 1e-9;           % shift is 1 ns 
%select_frame_no = [70] %[20]; % which frame 
frame_no_period = 200; %50;   % number of cycle

% Dir2='D:\SPADv2\test\20210120\test_112021_13ns_DarkImage_gated\'; 
darkImageDir='C:\SPAD\test\test_112021_13ns_DarkImage_gated\';
darkImageN = 99; 

% dark image to find the hot spots 
dark1=double(gpuArray(imread([darkImageDir,'image_',int2str(darkImageN),'.tiff']))); 
threshold=11; % used to be 100 top 2.1% 
SizeDark1=(find(dark1>threshold));

[f,p] = uigetfile({'D:\*.tiff;*.*','All Files'}, 'MultiSelect', 'on');
    fileName     = strcat(p,f);
    fileQuanty   = size(fileName,2);
    incr_row_col = 1;
    startRow     = 4;
    endRow       = 252; 
    startCol     = 4;
    endCol       = 508;
    rowPxl       = (endRow - startRow)/incr_row_col+1;
    colPxl       = (endCol - startCol)/incr_row_col+1;
    halfSpeckleWindowSize = (7-1)/2;  % 7x7 or 5x5
    
select_frame_no = [1,10,20,25,30,35,40,45,50,55,60,70];  % which frame     
for ii = 1:12
    period_qty = fileQuanty/frame_no_period;

    K_sp = zeros(rowPxl,colPxl,1);
    hwait = waitbar(0);
    numImage=0;
        for k=1:fileQuanty
            if rem(k,frame_no_period)==select_frame_no(ii)
                numImage=numImage+1; 
                period_no = fix(k/frame_no_period) + 1;
                tempdata = imread(fileName{1,k});

                tempdata = double(tempdata);
                tempdata1 = tempdata;
                tempdata(find(dark1>threshold))=nan; % hotspot correction  
                tempdata2=-log(1-tempdata/1020)*1020; % pile-up corrcetion on the hot spot corrected data 
                %tempdata        = imread(fileName);
                imdata(:,:,numImage)          = double(tempdata);
                for i = startRow:incr_row_col:endRow
                    for j = startCol:incr_row_col:endCol
                        speckleWindow = tempdata(i-halfSpeckleWindowSize:i+halfSpeckleWindowSize,j-halfSpeckleWindowSize:j+halfSpeckleWindowSize);
                        K_sp_HS((i-startRow)/incr_row_col+1,(j-startCol)/incr_row_col+1,numImage) = std(speckleWindow,'omitnan')/mean(speckleWindow,'omitnan');

                        speckleWindow = tempdata1(i-halfSpeckleWindowSize:i+halfSpeckleWindowSize,j-halfSpeckleWindowSize:j+halfSpeckleWindowSize);
                        K_sp((i-startRow)/incr_row_col+1,(j-startCol)/incr_row_col+1,numImage) = std(speckleWindow,'omitnan')/mean(speckleWindow,'omitnan');

                        speckleWindow = tempdata2(i-halfSpeckleWindowSize:i+halfSpeckleWindowSize,j-halfSpeckleWindowSize:j+halfSpeckleWindowSize);
                        K_sp_HS_PU((i-startRow)/incr_row_col+1,(j-startCol)/incr_row_col+1,numImage) = std(speckleWindow,'omitnan')/mean(speckleWindow,'omitnan');
                    end
                end

        waitbar(k/fileQuanty,hwait,num2str(k),'fontzise',30)     
            end
        end
    Kmean_2D(:,:,ii) = mean(K_sp,3);       
    Kmean_2D_HS(:,:,ii) = mean(K_sp_HS,3); 
    Kmean_2D_HS_PU(:,:,ii) = mean(K_sp_HS_PU,3); 
end
close(hwait);

%% temporal K
% for k=1:fileQuanty
%   tempdata        = imread(fileName{1,k});
%   imdata(:,:,k)          = double(tempdata);
% end
% for i = startRow:incr_row_col:endRow
%     for j = startCol:incr_row_col:endCol
%         Kmean_2D(i,j) = std(imdata(i,j,:))/mean(imdata(i,j,:));
%     end
% end
% flow = 1./Kmean_2D(:,:).^2;
  
%%
flow = 1./Kmean_2D(:,:).^2;
imagesc(flow/mean2(flow))
% imshow(Kmean_2D)
title('no correction')
colormap default
caxis([0.2 2]);
colorbar

figure
flow_HS = 1./Kmean_2D_HS(:,:).^2;
imagesc(flow_HS/mean2(flow))
% imshow(Kmean_2D)
title('Hot-Spot Correction')
colormap default
caxis([0.2 2]);
colorbar


figure
flow_HS_PU = 1./Kmean_2D_HS_PU(:,:).^2;
imagesc(flow_HS_PU/mean2(flow))
% imshow(Kmean_2D)
title('Hot-Spot & Pile-Up Correction')
colormap default
caxis([0.2 2]);
colorbar

% This part of the code was added by myself(Faraneh) on Spe29th, 2021
figure
% flow = 1./Kmean_2D(:,:).^2;
% imagesc(flow)
imagesc(flow_HS_PU)
% imshow(Kmean_2D)
 title('nn')
colormap default
 caxis([0 100.0]);
colorbar
%%
% mesh(imdata(:,:,12))
%title(p(end-2:end-1))
%colormap default
% caxis([0 1e6]);
% colorbar

% %%
% for i=1:10
%     subplot(5,2,i)
%     imshow((1./Kmean_2D(:,:,i)).^2)
%     title_no = num2str(23+i);
%     title(title_no,'fontsize',16);
%     colormap default
%     colorbar
%     %caxis([200 250]);
% end
% %colorbar('hot','location','eastoutside');
% %%
% 
% % [f,p] = uigetfile({'F:\*.tif;*.*','All Files'},'Open raw images', 'MultiSelect', 'on');
% % tempdata        = imread(f);
% % imdata          = double(tempdata);
% 
% taoc = zeros(rowPxl,colPxl);
% hwait = waitbar(0); 
% for i = 1:size(K_sp,1)
%      for j = 1:size(K_sp,2)
%          taoc(i,j) = taocfit(T,Kmean_2D(i,j));
% %             taoc = x(1);
% %             beta = x(2);
%      end
%      waitbar(((i-1)*size(K_sp,1)+j)/(size(K_sp,1)*size(K_sp,1)),hwait,['row ', num2str(i)],'fontzise',30)
%  end
% %taoc = taocfit(T,Kmean_2D);
% close(hwait);
% LSCIflow = 1./taoc;
% %%
% imshow(LSCIflow/mean(LSCIflow(:)))
% caxis([0 30]);
% colorbar('hot','location','eastoutside');
toc

%%
axisRange = [0 200];
figure
subplot(3,4,1)
flow_HS_PU = 1./Kmean_2D_HS_PU(:,:,1).^2;
imagesc(flow_HS_PU)
% imshow(Kmean_2D)
title('1 Hot-Spot & Pile-Up Correction')
colormap default
caxis(axisRange);
colorbar

subplot(3,4,2)
flow_HS_PU = 1./Kmean_2D_HS_PU(:,:,2).^2;
imagesc(flow_HS_PU)
% imshow(Kmean_2D)
title('10 Hot-Spot & Pile-Up Correction')
colormap default
caxis(axisRange);
colorbar

subplot(3,4,3)
flow_HS_PU = 1./Kmean_2D_HS_PU(:,:,3).^2;
imagesc(flow_HS_PU)
% imshow(Kmean_2D)
title('20 Hot-Spot & Pile-Up Correction')
colormap default
caxis(axisRange);
colorbar

subplot(3,4,4)
flow_HS_PU = 1./Kmean_2D_HS_PU(:,:,4).^2;
imagesc(flow_HS_PU)
% imshow(Kmean_2D)
title('25 Hot-Spot & Pile-Up Correction')
colormap default
caxis(axisRange);
colorbar

subplot(3,4,5)
flow_HS_PU = 1./Kmean_2D_HS_PU(:,:,5).^2;
imagesc(flow_HS_PU)
% imshow(Kmean_2D)
title('30 Hot-Spot & Pile-Up Correction')
colormap default
caxis(axisRange);
colorbar

subplot(3,4,6)
flow_HS_PU = 1./Kmean_2D_HS_PU(:,:,6).^2;
imagesc(flow_HS_PU)
% imshow(Kmean_2D)
title('35 Hot-Spot & Pile-Up Correction')
colormap default
caxis(axisRange);
colorbar

subplot(3,4,7)
flow_HS_PU = 1./Kmean_2D_HS_PU(:,:,6).^2;
imagesc(flow_HS_PU)
% imshow(Kmean_2D)
title('40 Hot-Spot & Pile-Up Correction')
colormap default
caxis(axisRange);
colorbar

subplot(3,4,8)
flow_HS_PU = 1./Kmean_2D_HS_PU(:,:,6).^2;
imagesc(flow_HS_PU)
% imshow(Kmean_2D)
title('45 Hot-Spot & Pile-Up Correction')
colormap default
caxis(axisRange);
colorbar

subplot(3,4,9)
flow_HS_PU = 1./Kmean_2D_HS_PU(:,:,6).^2;
imagesc(flow_HS_PU)
% imshow(Kmean_2D)
title('50 Hot-Spot & Pile-Up Correction')
colormap default
caxis(axisRange);
colorbar

subplot(3,4,10)
flow_HS_PU = 1./Kmean_2D_HS_PU(:,:,6).^2;
imagesc(flow_HS_PU)
% imshow(Kmean_2D)
title('55 Hot-Spot & Pile-Up Correction')
colormap default
caxis(axisRange);
colorbar

subplot(3,4,11)
flow_HS_PU = 1./Kmean_2D_HS_PU(:,:,6).^2;
imagesc(flow_HS_PU)
% imshow(Kmean_2D)
title('60 Hot-Spot & Pile-Up Correction')
colormap default
caxis(axisRange);
colorbar

subplot(3,4,12)
flow_HS_PU = 1./Kmean_2D_HS_PU(:,:,6).^2;
imagesc(flow_HS_PU)
% imshow(Kmean_2D)
title('70 Hot-Spot & Pile-Up Correction')
colormap default
caxis(axisRange);
colorbar