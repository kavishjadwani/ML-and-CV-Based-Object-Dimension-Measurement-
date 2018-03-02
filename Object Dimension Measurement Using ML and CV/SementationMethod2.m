5%% Initialising the code
clc;
clear all;
close all;
%% Read Image
a = imread('tf28.jpg');
figure(1);
imshow(a);
title('Original Image');
%% Sharpen the image
I = imsharpen(a);
figure(2);
imshow(I);
title('Sharpened Image');
%% Converting to black and white
i = im2bw(I);
%% RGB Color Space
rmat = I(:,:,1);
gmat = I(:,:,2);
bmat = I(:,:,3);
figure(3);
subplot(2,2,1);
imshow(rmat);
title('Red Plane');
subplot(2,2,2);
imshow(gmat);
title('Green Plane');
subplot(2,2,3);
imshow(bmat);
title('Blue Plane');
subplot(2,2,4);
imshow(I);
title('Original Image');
%% Thresholding and Segmentaion each
levelr = 0.12;
levelg = 0.10;
levelb = 0.215;
i1 = im2bw(rmat,levelr);
i2 = im2bw(gmat,levelg);
i3 = im2bw(bmat,levelb);
Isum = (i1&i2&i3);

%% Plot Data
figure(4);
subplot(2,2,1);imshow(i1);title('Red Plane');
subplot(2,2,2);imshow(i2);title('Green Plane');
subplot(2,2,3);imshow(i3);title('Blue Plane');
subplot(2,2,4);imshow(Isum);title('Sum of all planes');
%% Complement the image
Icomp = imcomplement(Isum);
Ifilled = imfill(Icomp,'holes')%Fill image regions and holes
figure(5);
imshow(Ifilled);
d = imdistline;
title('Complemented Image');

