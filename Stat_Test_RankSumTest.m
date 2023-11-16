clc;clear all; close all;

n1=15
n2=15
mu_R=n1*(n1+n2+1)/2
sigma_R=sqrt((n1*n2*(n1+n2+1)/12))
R=278 
z=(R-mu_R)/sigma_R