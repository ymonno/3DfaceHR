function gatherLandmarks(folder,videoName,smoothPts)

[~,videoName,~] = fileparts(videoName);
list = dir(fullfile(folder,'*png.mat'));
for i = 1:length(list)
    [trackedLandmarks{i}] = helper(folder,list,i);
end
try
[trackedLandmarks] = smootheLandmarks(trackedLandmarks,smoothPts);
catch
    keyboard
end
save(fullfile(folder,[videoName,'_3DtrackedLandmarks_frames']),'trackedLandmarks')

end

function [trackedLandmarks] = helper(folder,list,i)
load(fullfile(folder,list(i).name))

if exist('Landmarks')
    if length(size(Landmarks))==3
        Landmarks = Landmarks(1,:,:);
    end
        trackedLandmarks = squeeze(Landmarks);
        trackedLandmarks(:,3) = (-1)*trackedLandmarks(:,3);
    else
        trackedLandmarks = [];
    end
end