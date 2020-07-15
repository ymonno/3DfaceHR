function run_getSignals_2DLand_Tracking_withOut_VisibilityCheck(folder,movingWindowWidth,frameRate,movie2Use)

% Run respective code which gets BVP signals for a movie with sliding window. The estimated BVP is stored in .mat file.
% 
% # Input
% - folder: Relative or absolute path to the movie folder. We assume the name of the video is 'video.avi'.
% - movingWindowWidth: Width of moving window for the BVP estimation. We use 10 sec in the paper.
% - frameRate: Framerate of the input video.
% - angleThres: Threshold of the angle between the camera plane and the facial patch. We use 75 [degrees] for our proposed method.
% - movie2Use: Define which part of movie to use. If you want to use 5 sec. to 45 sec. of the movie, `movie2Use = [5 45]`. 

videoFileName = fullfile(folder,'video.avi');
matFolder = fullfile(folder,'mat');
if ~exist(matFolder)
mkdir(matFolder)
end


movingAveShift = 1; % stride of sliding window
numMovingWin = floor((movie2Use(end)-movie2Use(1)-movingWindowWidth)/movingAveShift);
angleThres = Inf;
for movingWinCnt = 0:numMovingWin
    

    
    
    startTime = movie2Use(1)+movingWinCnt*movingAveShift;
    endTime = startTime+movingWindowWidth;%-1/frameRate;
    matName = sprintf('bvpSignal2DLand_Tracking_withOut_VisibilityCheck_%02dsec-%02dsec.mat',startTime,endTime);%+1/frameRate);
    
    if ~exist(fullfile(matFolder,matName),'file')
            [bvpCandidates,~,time,CheekGridReliability] = getSignals_2DLand_Tracking_withOut_VisibilityCheck(videoFileName,startTime,endTime,angleThres);
            savehelper(bvpCandidates,frameRate,time,matFolder,matName,CheekGridReliability)
    end
    
end
end
function savehelper(bvpCandidates,frameRate,time,matFolder,matName,CheekGridReliability)
save(fullfile(matFolder,matName),'bvpCandidates','frameRate','time','CheekGridReliability')
end