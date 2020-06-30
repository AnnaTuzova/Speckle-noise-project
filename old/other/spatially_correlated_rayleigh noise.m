%spatially correlated rayleigh noise
%based on: Methods for Blind Estimation of Speckle Variance in SAR Images
%octave510
%2019.11.20 fix: x/ysize

clc
clear all

more off; %show output immediately (also fflush(stdout))

%image size
xsize = 200;
ysize = 100;

%uncorrelated gaussian noise
gn = randn(ysize, xsize);  %matrix with normally distributed random elements having zero mean and variance one

%Gaussian zero mean spatially correlated noise (GCN – Gaussian correlated noise)
gnc = randn(ysize, xsize);  %matrix with normally distributed random elements having zero mean and variance one
%f = [1 1; 1 1]; %spatial low pass filter LPF
%f = [1 1 1; 1 8 1; 1 1 1];  % LPF
f = [1 1 1; 1 1 1; 1 1 1];  % LPF
gnc = filter2(f, gnc);

%uncorrelated rayleigh noise
rn1 = rnc(gn, xsize, ysize);

size(rn1)

%correlated rayleigh noise
rn2 = rnc(gnc, xsize, ysize);

shown(rn1, 1, 100)
shown(rn2, 2, 100)

step = ones(size(rn1));
step(:, 1:end/2) = 10;

rn3 = rn1.*step;

shown(rn3, 3, 100)

rn4 = rn2 .* step;

shown(rn4, 4, 100)

disp('done')
%correlated rayleigh noise
function res = rnc(gcn, xsize, ysize)
    c=gcn(:);
    b=random('rayleigh',1,1,xsize*ysize)/1.26;  %pkg load statistics  %random
    [cc,ci]=sort(c);
    [bb,bi]=sort(b);
    c(ci)=b(bi);
    res=reshape(c, ysize, xsize);
end

function shown(mat, n, nbins)
    figure(n);
    colormap(gray);
    subplot(2,1,1)
    imagesc(mat)
    subplot(2,1,2)
    hist(mat,nbins)
end
