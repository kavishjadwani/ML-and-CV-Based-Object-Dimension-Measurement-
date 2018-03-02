%%Image Acquisition
clc
clear all;
vid = videoinput('winvideo', 1, 'YUY2_640x480');%Accessing an image acquisition device
vid.Timeout = 12;%Timeout is the maximum time (in seconds) to wait to complete a read or write operation.
vid.FrameGrabInterval = 5;%For example, when you specify a FrameGrabInterval value of 3, the object acquires every third frame from the video stream
vid.FramesPerTrigger = 1;%FramesPerTrigger property specifies the number of frames the video input object acquires each time it executes a trigger using the selected video source.When the value of the FramesPerTrigger property is set to Inf, the object keeps acquiring frames until an error occurs or you issue a stop command
src = getselectedsource(vid);%to get trigger files
% src.FrameRate = '30';
vid.ReturnedColorspace = 'rgb';% to display image in rgb format
preview(vid);
start(vid);
frames = getdata(vid);
delete(vid)
clear vid
%   imshow( frames);
%  imaqmontage(frames);
 i=frames;
 
 imshow(i,'initialmagnification',100);      
% title ('workpiece image');

