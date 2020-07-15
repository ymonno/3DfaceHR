function [Landmarks] = smootheLandmarks(Landmarks,smoothPts)
% This function smoothe the detected landmrks using moving average in time domain.
% Smoothe Pts is the number of points to average.

numFrames = length(Landmarks);
Landmarks = cell2mat(Landmarks);
Landmarks = reshape(Landmarks,68*3,[])';
Landmarks = moving(Landmarks, smoothPts);
Landmarks = reshape(Landmarks',68,3,[]);
Landmarks = mat2cell(Landmarks,68,3,ones(1,numFrames));
Landmarks = squeeze(Landmarks)';

end