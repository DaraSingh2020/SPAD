function [gradient_X,gradient_Y,maxIndex,originalImageWithMax]=verticleLineWithMaxGradient(inputImage,threshhold)

% We need to calculate gradients on intense pixels. I don't care about
% slope between pixel values 0 and 1, for example. but I care about slope 
% between 3 and 4.

inputImage=inputImage-threshhold;
inputImage(inputImage<0)=0;


% Calculating gradient in X and Y directions
[gradient_X,gradient_Y] = imgradientxy(inputImage,'central');

%Blur it so that the highest concentration of the extreme points show
%themseves:
blurred_X_grad = imgaussfilt(gradient_X,2);

%Calculate the sum. In MATLAB sum function calculates along the column only
verticalSum=sum(blurred_X_grad);
%verticalSum=sum(gradient_X);
verticalSum(1:50)=0;
verticalSum(end-50:end)=0;

[maxValue,maxIndex]=max(verticalSum);


maxInOriginalImage=max(max(inputImage));
originalImageWithMax=inputImage;
originalImageWithMax(:,maxIndex)=0;
end


