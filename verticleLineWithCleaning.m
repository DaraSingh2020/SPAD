function imageWithLine=verticleLineWithCleaning(inputImage,threshhold)

% We need to calculate gradients on intense pixels. I don't care about
% slope between pixel values 0 and 1, for example. but I care about slope 
% between 3 and 4.

inputImage=inputImage-threshhold;
inputImage(inputImage<0)=0;
inputImage(:,359:361)=5;
imageWithLine=inputImage;
end


