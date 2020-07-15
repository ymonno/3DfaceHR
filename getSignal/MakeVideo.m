function [videoFileName] = MakeVideo(path_to_images,filename,frameRate)
% path_to_images: foldername of input pictures
% filename: name of the out video
addpath(genpath(path_to_images));
imageNames = dir(fullfile(path_to_images, '*.png'));
videoFileName = fullfile(path_to_images, filename);
if(~exist(path_to_images,'dir'))
    mkdir(path_to_images)
end
outputVideo = VideoWriter(videoFileName);
outputVideo.FrameRate = frameRate;
open(outputVideo)
for ii = 1:length(imageNames)
   img = imread(fullfile(imageNames(ii).name));
   writeVideo(outputVideo,img)
   
end
close(outputVideo)
end