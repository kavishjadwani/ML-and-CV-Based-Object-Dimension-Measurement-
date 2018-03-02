%% Image calibration
clc
clear all ;
close all;
numImages = 4;
files = cell(1, numImages);
for i = 1:numImages
files{i} = fullfile(matlabroot, 'toolbox', 'vision' , 'visiondemos','calibration','slr', sprintf('f%d.jpg',i));
end
%% Display one of the calibration images
magnification = 25;
figure; imshow(files{1}, 'InitialMagnification', magnification);
title('One of the Calibration Images');
%% Detect the checkerboard corners in the images
[imagePoints, boardSize] = detectCheckerboardPoints(files);
% Generate the world coordinates of the checkerboard corners in the
% pattern-centric coordinate system, with the upper-left corner at (0,0)
squareSize = 30.5; % in millimeters %This is the size of each B&W box of board
worldPoints = generateCheckerboardPoints(boardSize, squareSize);
%% Calibrate the camera
cameraParams = estimateCameraParameters(imagePoints, worldPoints);
%% 
k = imagePoints 
%% Evaluate calibration accuracy
figure; showReprojectionErrors(cameraParams);
title('Reprojection Errors');
%% Read the image to be measured
imOrig = imread(fullfile(matlabroot, 'toolbox', 'vision', 'visiondemos','calibration', 'slr', 'fc16.jpg'));
figure; imshow(imOrig, 'InitialMagnification', magnification);
title('Input Image');
%% Undistort the image
[im, newOrigin] = undistortImage(imOrig, cameraParams, 'OutputView', 'full');
figure; imshow(im, 'InitialMagnification', magnification);
title('Undistorted Image');
%% Segment Object
% Convert the image to the HSV color space.
imHSV = rgb2hsv(im);

% Get the saturation channel.
saturation = imHSV(:, :, 2);

% Threshold the image
t = graythresh(saturation);
imCoin = (saturation > t);

figure; imshow(imCoin, 'InitialMagnification', magnification);
title('Segmented Coins');
%% Detect Dimensions
% Find connected components.
blobAnalysis = vision.BlobAnalysis('AreaOutputPort', true,'CentroidOutputPort', false,'BoundingBoxOutputPort', true,'MinimumBlobArea', 200, 'ExcludeBorderBlobs', true);
[areas, boxes] = step(blobAnalysis, imCoin);
%%

% Sort connected components in descending order by area
[~, idx] = sort(areas, 'Descend');
%%

% Get the two largest components.
boxes = double(boxes(idx(1:2), :));
%% 
% Adjust for coordinate system shift caused by undistortImage
boxes(:, 1:2) = bsxfun(@plus, boxes(:, 1:2), newOrigin);
%% 
% Reduce the size of the image for display.
scale = magnification / 100;
imDetectedCoins = imresize(im, scale);

%% Insert labels for the coins.
imDetectedCoins = insertObjectAnnotation(imDetectedCoins, 'rectangle',scale * boxes, 'penny');
figure; imshow(imDetectedCoins);
title('Detected Coins');
%% Detect Checker board
% Detect the checkerboard.
[imagePoints, boardSize] = detectCheckerboardPoints(im);
i = imagePoints
j = boardSize

%% Compute rotation and translation of the camera.
[R, t] = extrinsics(i, worldPoints, cameraParams)

%% Measure object 1
% Get the top-left and the top-right corners.
box1 = double(boxes(1, :));
imagePoints1 = [box1(1:1); box1(1) + box1(3), box1(2)];

% Get the world coordinates of the corners
worldPoints1 = pointsToWorld(cameraParams, R, t, imagePoints1);

% Compute the diameter of the coin in millimeters.
d = worldPoints1(2, :) - worldPoints1(1, :);
diameterInMillimeters = hypot(d(1), d(2));
fprintf('Measured diameter of one penny = %0.2f mm\n', diameterInMillimeters);
%% Measure objct2
% Get the top-left and the top-right corners.
% box2 = double(boxes(2, :));
% imagePoints2 = [box2(1:2); box2(1) + box2(3), box2(2)];
% 
% % Apply the inverse transformation from image to world
% worldPoints2 = pointsToWorld(cameraParams, R, t, imagePoints2);
% 
% % Compute the diameter of the coin in millimeters.
% d = worldPoints2(2, :) - worldPoints2(1, :);
% diameterInMillimeters = hypot(d(1), d(2));
% fprintf('Measured diameter of the other penny = %0.2f mm\n', diameterInMillimeters);
% 
% 
