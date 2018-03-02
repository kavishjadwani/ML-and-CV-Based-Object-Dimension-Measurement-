%% Initialising the code
clc;
clear all;
close all;
%% Read Image
a1 = imread('Part3.1.jpg');
a2=  imread('Part3.2.jpg');
a3 = imread('Part3.3.jpg');
a4 = imread('Part3.4.jpg');
% figure(1);
% imshow(a);
% title('Original Image');
%% Sharpen the image
I1 = imsharpen(a1);
I2 = imsharpen(a2);
I3 = imsharpen(a3);
I4 = imsharpen(a4);
% figure(2);
% imshow(I);
% title('Sharpened Image');
%% Converting to black and white
% i = im2bw(I);
%% RGB Color Space
rmat1 = I1(:,:,1);
gmat1 = I1(:,:,2);
bmat1= I1(:,:,3);
rmat2 = I2(:,:,1);
gmat2 = I2(:,:,2);
bmat2 = I2(:,:,3);
rmat3 = I3(:,:,1);
gmat3 = I3(:,:,2);
bmat3 = I3(:,:,3);
rmat4 = I4(:,:,1);
gmat4 = I4(:,:,2);
bmat4 = I4(:,:,3);
% figure(3);
% subplot(2,2,1);
% imshow(rmat);
% title('Red Plane');
% subplot(2,2,2);
% imshow(gmat);
% title('Green Plane');
% subplot(2,2,3);
% imshow(bmat);
% title('Blue Plane');
% subplot(2,2,4);
% imshow(I);
% title('Original Image');
%% Thresholding and Segmentaion each
levelr1 = 0.12;
levelg1 = 0.10;
levelb1 = 0.215;
levelr2 = 0.12;
levelg2 = 0.10;
levelb2 = 0.215;
levelr3 = 0.12;
levelg3 = 0.10;
levelb3 = 0.215;
levelr4 = 0.12;
levelg4 = 0.10;
levelb4 = 0.215;
i11 = im2bw(rmat1,levelr1);
i12 = im2bw(gmat1,levelg1);
i13 = im2bw(bmat1,levelb1);
Isum1 = (i11&i12&i13);
i21 = im2bw(rmat2,levelr2);
i22 = im2bw(gmat2,levelg2);
i23 = im2bw(bmat2,levelb2);
Isum2 = (i21&i22&i23);
i31 = im2bw(rmat3,levelr3);
i32 = im2bw(gmat3,levelg3);
i33 = im2bw(bmat3,levelb3);
Isum3 = (i31&i32&i33);
i41 = im2bw(rmat4,levelr4);
i42 = im2bw(gmat4,levelg4);
i43 = im2bw(bmat4,levelb4);
Isum4 = (i41&i42&i43);
%% Plot Data
% figure(4);
% subplot(2,2,1);imshow(i1);title('Red Plane');
% subplot(2,2,2);imshow(i2);title('Green Plane');
% subplot(2,2,3);imshow(i3);title('Blue Plane');
% subplot(2,2,4);imshow(Isum);title('Sum of all planes');
%% Complement and filling the image
Icomp1 = imcomplement(Isum1);
Ifilled1 = imfill(Icomp1,'holes')%Fill image regions and holes
Icomp2 = imcomplement(Isum2);
Ifilled2 = imfill(Icomp2,'holes')%Fill image regions and holes

Icomp3 = imcomplement(Isum3);
Ifilled3 = imfill(Icomp3,'holes')%Fill image regions and holes

Icomp4 = imcomplement(Isum4);
Ifilled4 = imfill(Icomp4,'holes')%Fill image regions and holes

Ifilled = Ifilled1 +  Ifilled2 +  Ifilled3 +  Ifilled4;

% figure(5);
% imshow(Ifilled);
% title('Complemented Image');
%% Opening Image Tool
imtool(Ifilled);
% %% Approach 2
% mask = false(size(i));
% mask(170,70) = true;
% W = graydiffweight(i, mask, 'GrayDifferenceCutoff', 25);
% thresh = 0.01;
% [BW, D] = imsegfmm(W, mask, thresh);
% figure
% imshow(BW)
% title('Segmented Image')
imageSegmenter(I);