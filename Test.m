clear; clc; close all;

X=magic(5)
X1=X;
dark1=ones(5);
rng('default')
for i=1:10
    dark1(randi([1,5]),randi([1,5]))=randi([1,25]);
end
dark1
tre=2;
X1(find(dark1>tre))=nan;
X1
Kernel=ones(3)/9;
TT=conv2(X1,Kernel,'same')
TTT=nanconv(X1,Kernel)
X1.^2
YY=conv2(X,Kernel,'same')

