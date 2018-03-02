function varargout = GUI2(varargin)
% GUI2 MATLAB code for GUI2.fig
%      GUI2, by itself, creates a new GUI2 or raises the existing
%      singleton*.
%
%      H = GUI2 returns the handle to a new GUI2 or the handle to
%      the existing singleton*.
%
%      GUI2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI2.M with the given input arguments.
%
%      GUI2('Property','Value',...) creates a new GUI2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI2

% Last Modified by GUIDE v2.5 29-Dec-2014 11:35:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI2_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI2_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI2 is made visible.
function GUI2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI2 (see VARARGIN)

% Choose default command line output for GUI2
handles.output = hObject;
set(handles.axes1,'visible','on')
set(handles.axes2,'visible','on')
set(handles.axes4,'visible','on')
set(handles.axes6,'visible','on')
c = imread('back1.jpg');
b=imread('difulogo.jpg');
axes(handles.axes1);
cla,imshow(b);
 axes(handles.axes6);
 cla,imshow(c);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Calibration.
function Calibration_Callback(hObject, eventdata, handles)
% hObject    handle to Calibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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
axes(handles.axes2);
cla,;showReprojectionErrors(cameraParams);
handles.cameraParams=cameraParams;
handles.magnification = magnification;
guidata(hObject,handles);


% --- Executes on button press in CAD.
function CAD_Callback(hObject, eventdata, handles)
% hObject    handle to CAD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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
dxfinformation=struct2cell(dxfinfo);
ka = dxfinformation;
set(handles.text4, 'String', ka);
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

 ki = 2 * circles(:,5);
% ka = dxfinformation;
end   
% i = str2double(dxfdata(circles(:,1)+8)); 
 %%
%%%%%%end%%%%%% data extraction

%%%%%%end%%%%%%  get dxf data

clear a b total fid dxfdata % delete garbage

toc;
handles.ki = ki;
set(handles.text2, 'String', num2str(ki));
% set(handles.text4, 'String', num2str(ka));
guidata(hObject,handles);


% --- Executes on button press in Circles.
function Circles_Callback(hObject, eventdata, handles)
% hObject    handle to Circles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cameraParams = handles.cameraParams ;
magnification = handles.magnification;
%% Read Image
vid = videoinput('winvideo', 2, 'YUY2_640x480');%Accessing an image acquisition device
vid.Timeout = 12;%Timeout is the maximum time (in seconds) to wait to complete a read or write operation.
vid.FrameGrabInterval = 5;%For example, when you specify a FrameGrabInterval value of 3, the object acquires every third frame from the video stream
vid.FramesPerTrigger = 1;%FramesPerTrigger property specifies the number of frames the video input object acquires each time it executes a trigger using the selected video source.When the value of the FramesPerTrigger property is set to Inf, the object keeps acquiring frames until an error occurs or you issue a stop command
src = getselectedsource(vid);%to get trigger files
vid.ReturnedColorspace = 'rgb';% to display image in rgb format
start(vid);
cameraParams = handles.cameraParams ;
frames = getdata(vid);
delete(vid)
clear vid;
 p=frames;
%  imshow(i,'initialmagnification',100); 
a = p;
%% Undistort the image
[im, newOrigin] = undistortImage(a, cameraParams, 'OutputView', 'full');
I = imsharpen(im);
%% RGB Color Space
rmat = I(:,:,1);
gmat = I(:,:,2);
bmat = I(:,:,3);
%% Thresholding and Segmentaion each
levelr = 0.12;
levelg = 0.10;
levelb = 0.215;
i1 = im2bw(rmat,levelr);
i2 = im2bw(gmat,levelg);
i3 = im2bw(bmat,levelb);
Isum = (i1&i2&i3);
%% Complement the image
Icomp = imcomplement(Isum);
Ifilled = imfill(Icomp,'holes');%Fill image regions and holes
imCoin = Ifilled;
blobAnalysis = vision.BlobAnalysis('AreaOutputPort', true,...
    'CentroidOutputPort', false,...
    'BoundingBoxOutputPort', true,...
    'MinimumBlobArea', 200, 'ExcludeBorderBlobs', true);
[areas, boxes] = step(blobAnalysis, imCoin);
[~, idx] = sort(areas, 'Descend');
boxes = double(boxes(idx(1:1), :));
% Adjust for coordinate system shift caused by undistortImage
boxes(:, 1:2) = bsxfun(@plus, boxes(:, 1:2), newOrigin);

% Reduce the size of the image for display.
scale = magnification / 100;
imDetectedCoins = imresize(im, scale);
imDetectedCoins = insertObjectAnnotation(imDetectedCoins, 'rectangle', ...
    scale * boxes, 'Object');
axes(handles.axes4);
cla;imshow(imDetectedCoins);
squareSize = 22.5;
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
set(handles.text13, 'String',  diameterInMillimeters );
fprintf('Measured  Length of Workpiece1 = %0.2f mm\n', diameterInMillimeters  );
ki = handles.ki;
%% Comparison
r = ki - diameterInMillimeters;

if (r > 0.5 || r < -0.5)
    warndlg('The object is defective','!! Warning !!')
    fprintf('Part is Defective please repair or replace it because....');
    fprintf('\n In a True Zero Defective approach , there a  no unimportant items":Phil Crosby');
end

guidata(hObject,handles);
