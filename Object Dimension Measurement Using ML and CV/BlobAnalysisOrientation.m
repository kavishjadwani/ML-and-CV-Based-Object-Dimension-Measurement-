%% Initialise code
clc;
clear all;
close all;

%%
numImages = 32;
files = cell(1, numImages);
for i = 1:numImages
    files{i} = fullfile(matlabroot, 'toolbox', 'vision', 'visiondemos', ...
        'calibration', 'slr', sprintf('tf%d.jpg', i));
end

% Display one of the calibration images
magnification = 25;
figure; imshow(files{1}, 'InitialMagnification', magnification);
title('One of the Calibration Images');
%%
% Detect the checkerboard corners in the images.
[imagePoints, boardSize] = detectCheckerboardPoints(files);

% Generate the world coordinates of the checkerboard corners in the
% pattern-centric coordinate system, with the upper-left corner at (0,0).
squareSize = 22.5; % in millimeters
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Calibrate the camera.
cameraParams = estimateCameraParameters(imagePoints, worldPoints);

% Evaluate calibration accuracy.
figure; showReprojectionErrors(cameraParams);
title('Reprojection Errors');
%% Read Image
a =  imread(fullfile(matlabroot, 'toolbox', 'vision', 'visiondemos', ...
        'calibration', 'slr', 'tf42.jpg'));
figure(1);
imshow(a);
title('Original Image');
%% Undistort the image
[im, newOrigin] = undistortImage(a, cameraParams, 'OutputView', 'full');
figure; imshow(im, 'InitialMagnification', magnification);
title('Undistorted Image');
%% Sharpen the image
I = imsharpen(im);
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
imCoin = Ifilled;
figure; imshow(imCoin, 'InitialMagnification', magnification);
title('Segmented Coins');
%%
% Find connected components.
blobAnalysis = vision.BlobAnalysis('AreaOutputPort', true,...
    'CentroidOutputPort', true,...
    'OrientationOutputPort', true,...
    'BoundingBoxOutputPort', true,...
    'MinimumBlobArea', 200, 'ExcludeBorderBlobs', true);
[areas, centroid,boxes,Orientation] = step(blobAnalysis, imCoin)
%%
areass = double(areas);
length(areas);
length(Orientation);
%%
% Sort connected components in descending order by area

c = areass + Orientation 
%%
[~, idx] = sort(areas, 'Descend')
[~,idc] = sort (c,'Descend')
%%
areas = double(areas(idx(1:1), :))
%%
% Get the two largest components.
boxes = double(boxes(idx(1:1), :))
%%
c = double(c(idc(1:1), :))
%%
orient = c - areas;
%%
imCoin = imrotate(imCoin,orient(1),'bilinear','crop');
%  imCoin2= mat2gray(imCoin1);
figure;imshow(imCoin);

%%
blobAnalysis = vision.BlobAnalysis('AreaOutputPort', true,...
    'CentroidOutputPort', false,...
    'BoundingBoxOutputPort', true,...
    'MinimumBlobArea', 200, 'ExcludeBorderBlobs', true);
%%
[areas, boxes] = step(blobAnalysis, imCoin)
%%
% Sort connected components in descending order by area
[~, idx] = sort(areas, 'Descend');

% Get the two largest components.
boxes = double(boxes(idx(1:1), :));

% Adjust for coordinate system shift caused by undistortImage
boxes(:, 1:2) = bsxfun(@plus, boxes(:, 1:2), newOrigin);

% Reduce the size of the image for display.
scale = magnification / 100;
imDetectedCoins = imresize(im, scale);
%%

% Insert labels for the coins.
imDetectedCoins = insertObjectAnnotation(imDetectedCoins, 'rectangle', ...
    scale * boxes, 'Object');
figure; imshow(imDetectedCoins);
title('Detected Coins');


%%
%Detect the checkerboard.
[imagePoints, boardSize] = detectCheckerboardPoints(im);
%% 
% imagePoints;
 worldPoints = generateCheckerboardPoints(boardSize, squareSize);
%%
% Compute rotation and translation of the camera.
[R, t] = extrinsics(imagePoints, worldPoints, cameraParams);

%%
% Get the top-left and the top-right corners.
box1 = double(boxes(1,:));
box1(1:2);
%%
imagePoints1 = [box1(1:2);box1(1) + box1(3), box1(2)];
%%
% Get the world coordinates of the corners
worldPoints1 = pointsToWorld(cameraParams, R, t, imagePoints1);
%%
worldPoints1(2, :) ;
worldPoints1(1, :);
%% 
% Compute the diameter of the coin in millimeters.
d = worldPoints1(2, :) - worldPoints1(1, :);
diameterInMillimeters = hypot(d(1), d(2));
fprintf('Measured  Length of Workpiece1 = %0.2f mm\n', diameterInMillimeters );% - 3.2
%% Calculating Breadth
%%
% Get the top-left and the top-right corners.
box1 = double(boxes(1,:));
box1(1:2);
%%
imagePoints1 = [box1(1:2);box1(1), box1(2)-box1(4)];
%%
% Get the world coordinates of the corners
worldPoints1 = pointsToWorld(cameraParams, R, t, imagePoints1);
%%
worldPoints1(2, :) ;
worldPoints1(1, :);
%% 
% Compute the diameter of the coin in millimeters.
d = worldPoints1(2, :) - worldPoints1(1, :);
diameterInMillimeters = hypot(d(1), d(2));
fprintf('Measured Breadth of Workpiece1 = %0.2f mm\n', diameterInMillimeters );%-6.2
%%
% Get the top-left and the top-right corners.
box2 = double(boxes(2, :));
imagePoints2 = [box2(1:2);box2(1), box2(2)-box2(4)];

% Apply the inverse transformation from image to world
worldPoints2 = pointsToWorld(cameraParams, R, t, imagePoints2);

% Compute the diameter of the coin in millimeters.
 
d = worldPoints2(2, :) - worldPoints2(1, :);

diameterInMillimeters = hypot(d(1), d(2));
fprintf('Measured Length of Second Object = %0.2f mm\n', diameterInMillimeters   );
%% Calculating Breadth
box2 = double(boxes(2, :));
imagePoints2 = [box2(1:2); ...
                box2(1) + box2(3), box2(2)];

% Apply the inverse transformation from image to world
worldPoints2 = pointsToWorld(cameraParams, R, t, imagePoints2);

% Compute the diameter of the coin in millimeters.
 
d = worldPoints2(2, :) - worldPoints2(1, :);

diameterInMillimeters = hypot(d(1), d(2));
fprintf('Measured Length of Second Object = %0.2f mm\n', diameterInMillimeters    );

%%
% Compute the center of the first coin in the image.
center1_image = box1(1:2) + box1(3:4)/2;

% Convert to world coordinates.
center1_world  = pointsToWorld(cameraParams, R, t, center1_image);

% Remember to add the 0 z-coordinate.
center1_world = [center1_world 0];

% Compute the distance to the camera.
distanceToCamera = norm(center1_world + t);
fprintf('Distance from the camera to the first penny = %0.2f mm\n', ...
    distanceToCamera);