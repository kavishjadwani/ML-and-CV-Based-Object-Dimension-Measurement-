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
% % Display one of the calibration images
 magnification = 25;
% figure; imshow(files{1}, 'InitialMagnification', magnification);
% title('One of the Calibration Images');
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
% figure; showReprojectionErrors(cameraParams);
% title('Reprojection Errors');
%% Read dxf File
[filename, pathname] = uigetfile({'*.dxf'},'Open File','Multiselect','off'); % choose file to open
addpath(pathname); % add path to the matlab search path
    %if filename==0
       % errordlg('no file selected','file error');return
   % end
    
%addpath(pathname); % add path to the matlab search path
%%
fid=fopen(filename); % open file
dxfdata=textscan(fid,'%s'); % read dxf file as cell array of strings dxfdata
%%
fclose(fid); % close file to accelerate further computation
dxfdata=dxfdata{1,1}; % reshape array
%%%%%%end%%%%%%%%  get file


%%%%%%begin%%%%%%%%  get dxf data
%%
version=strcmp('$ACADVER',dxfdata(1:10)); % get version somewhere at the beginning of the .dxf header
%%
    if sum (version)==0
        b=warndlg('corrupted file header/file version...problems may occur during processing ','file error');
        uiwait(b);clear b;
        version=('unknown');
    else         
        version=dxfdata{(find(version==1)+2)}; % +2...acadversion (-> autodesk(r) dxf reference)        
            switch (version)
                case('AC1014')
                    version=('Acad R 14');
                case('AC1015')
                    version=('Acad R 2000');
                case('AC1018')
                    version=('Acad R 2004');
                case('AC1021')
                    version=('Acad R 2007');
                otherwise
                    version=('unknown');
                    b=warndlg('corrupted file header/file version...problems may occur during processing ','file error');
                    uiwait(b);clear b;
            end
    end
%%
dxfinfo=struct([]); % file info
dxfinfo(1).pathname=pathname;
dxfinfo(1).filename=filename;
dxfinfo(1).dxfversion=version;
clear filename pathname version
%%

beg=strcmp('ENTITIES',dxfdata); % cut out dxf entity data block to increase speed and reduce required memory  
    if sum(beg)==0
        b=errordlg('corrupted dxf file, processing stopped ','file error');
        uiwait(b);clear;return
    end
beg=find(beg==1);               
endsec=strcmp('ENDSEC',dxfdata);
endsec=find(endsec==1);
endsec=endsec(endsec>beg);
endsec=endsec(1);
dxfdata=dxfdata(beg:endsec); 
clear beg endsec;

tic;
%%%%%%begin%%%%%%%%  get indices + total... 
% of line no's of all treated entities, total=all indices in ascend order+no of last line of dxf block 
    
    %%
circles=strcmp('AcDbCircle',dxfdata);
circles=find(circles==1);
    if isempty (circles)
        clear circles;
    else
        if exist ('total','var')==0
            total=(circles);
        else
            total=[total;circles];
        end        
    end
     
    
     
    %%
total=sort(total);
total=[total;length(dxfdata)]; % add no of last line in dxfdata
%%%%%%%end%%%%%%%  get indices + total


%%%%%%begin%%%%%% data extraction 
%%%%%%%%%%%%%%%%%%% case circles %%%%%%%%%%%%%%%%%%%%%%%%%%
 %% 
if exist ('circles','var')==1
    
    
    circleslayers=cell(length(circles),1);              %#ok<NASGU> % get entity layernames
    circleslayers=dxfdata(circles-2); 
    

        for a=1:length(circles)
            if str2double(dxfdata(circles(a)+1))==39
                circles(a)=circles(a)+2;
            end
        end
        
    circles(:,2:5)=zeros;
    circles(:,2)=str2double(dxfdata(circles(:,1)+2));   % center x
    circles(:,3)=str2double(dxfdata(circles(:,1)+4));   % center y
    circles(:,4)=str2double(dxfdata(circles(:,1)+6));   % center z
    circles(:,5)=str2double(dxfdata(circles(:,1)+8));   % radius
%     circles(:,1)=1:length(circles);                     % no.

 ki = 2 * circles(:,5)
end   
% i = str2double(dxfdata(circles(:,1)+8)); 
 %%
%%%%%%end%%%%%% data extraction

%%%%%%end%%%%%%  get dxf data

clear a b total fid dxfdata % delete garbage

toc;
%% Read Image
vid = videoinput('winvideo', 2, 'YUY2_640x480');%Accessing an image acquisition device
%%
vid.Timeout = 12;%Timeout is the maximum time (in seconds) to wait to complete a read or write operation.
vid.FrameGrabInterval = 5;%For example, when you specify a FrameGrabInterval value of 3, the object acquires every third frame from the video stream
vid.FramesPerTrigger = 1;%FramesPerTrigger property specifies the number of frames the video input object acquires each time it executes a trigger using the selected video source.When the value of the FramesPerTrigger property is set to Inf, the object keeps acquiring frames until an error occurs or you issue a stop command
%%
src = getselectedsource(vid);%to get trigger files
vid.ReturnedColorspace = 'rgb';% to display image in rgb format
start(vid);
frames = getdata(vid);
delete(vid)
%%
clear vid;
 p=frames;
 imshow(i,'initialmagnification',100)
 %%
a = p;
% figure(1);
% imshow(a);
% title('Original Image');
%% Undistort the image
[im, newOrigin] = undistortImage(a, cameraParams, 'OutputView', 'full');
% figure; imshow(im, 'InitialMagnification', magnification);
% title('Undistorted Image');
%% Sharpen the image
I = imsharpen(im);
% figure(2);
% imshow(I);
% title('Sharpened Image');
%% Converting to black and white
i = im2bw(I);
%% RGB Color Space
rmat = I(:,:,1);
gmat = I(:,:,2);
bmat = I(:,:,3);
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
levelr = 0.12;
levelg = 0.10;
levelb = 0.215;
i1 = im2bw(rmat,levelr);
i2 = im2bw(gmat,levelg);
i3 = im2bw(bmat,levelb);
Isum = (i1&i2&i3);
%% Plot Data
% figure(4);
% subplot(2,2,1);imshow(i1);title('Red Plane');
% subplot(2,2,2);imshow(i2);title('Green Plane');
% subplot(2,2,3);imshow(i3);title('Blue Plane');
% subplot(2,2,4);imshow(Isum);title('Sum of all planes');
%% Complement the image
Icomp = imcomplement(Isum);
Ifilled = imfill(Icomp,'holes')%Fill image regions and holes
 figure;
 imshow(Ifilled);
d = imdistline;
%title('Complemented Image');
imCoin = Ifilled;
% figure; imshow(imCoin, 'InitialMagnification', magnification);
% title('Segmented Coins');
%%
% Find connected components.
blobAnalysis = vision.BlobAnalysis('AreaOutputPort', true,...
    'CentroidOutputPort', false,...
    'BoundingBoxOutputPort', true,...
    'MinimumBlobArea', 200, 'ExcludeBorderBlobs', true);
[areas, boxes] = step(blobAnalysis, imCoin);

% Sort connected components in descending order by area
[~, idx] = sort(areas, 'Descend');

% Get one largest components.
boxes = double(boxes(idx(1:1), :));

% Adjust for coordinate system shift caused by undistortImage
boxes(:, 1:2) = bsxfun(@plus, boxes(:, 1:2), newOrigin);

% Reduce the size of the image for display.
scale = magnification / 100;
imDetectedCoins = imresize(im, scale);

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
% 
% Compute the diameter of the coin in millimeters.
d = worldPoints1(2, :) - worldPoints1(1, :);
diameterInMillimeters = hypot(d(1), d(2));
fprintf('Measured  Length of Workpiece1 = %0.2f mm\n', diameterInMillimeters  );
%% Comparison
r = ki - diameterInMillimeters
if (r > 0.5 || r < -0.5)
    fprintf('Part is Defective please repair or replace it because....');
    fprintf('\n In a True Zero Defective approach , there a  no unimportant items":Phil Crosby');
end 
    