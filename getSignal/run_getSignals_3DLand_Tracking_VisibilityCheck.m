function run_getSignals_3DLand_Tracking_VisibilityCheck(folder,movingWindowWidth,frameRate,angleThres,movie2Use)
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

parfor movingWinCnt = 0:numMovingWin
    
    
    
    
    startTime = movie2Use(1)+movingWinCnt*movingAveShift;
    endTime = startTime+movingWindowWidth;%-1/frameRate;
    matName = sprintf('bvpSignal_3DLand_Tracking_VisibilityCheck_angleThres_%d_%02dsec-%02dsec.mat',angleThres,startTime,endTime);%+1/frameRate);
    
    if ~exist(fullfile(matFolder,matName),'file')
        [bvpCandidates,~,time,CheekGridReliability] = getSignals_3DLand_Tracking_VisibilityCheck(videoFileName,startTime+1/frameRate,endTime,angleThres);
        savehelper(bvpCandidates,frameRate,time,matFolder,matName,CheekGridReliability)
    end 
end
end
function savehelper(bvpCandidates,frameRate,time,matFolder,matName,CheekGridReliability)
save(fullfile(matFolder,matName),'bvpCandidates','frameRate','time','CheekGridReliability')
end