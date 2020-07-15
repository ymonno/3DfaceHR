%**************************************************************************
% Copyright (C) 2020, Yuichiro MAKI, all rights reserved.
%  Do not redistribute without permission.
%  Strictly for academic and non-commerial purpose only.
%  Use at your own risk.
%
% Please cite the following paper if you use this code.
%  - Yuichiro Maki, Yusuke Monno, Kazunori Yoshizaki, Masayuki Tanaka, and
%    Masatoshi Okutomi, "Inter-Beat Interval Estimation from Facial Video
%    Based on Reliability of BVP Signals," International Conference of th
%    IEEE Engineering in Medicine and Biology Society (EMBC), 2019.
%
%-  Yuichiro Maki, Yusuke Monno, Masayuki Tanaka, and Masatoshi Okutomi,
%   "Remote Heart Rate Estimation Based on 3D Facial Landmarks", International Conference of th
%    IEEE Engineering in Medicine and Biology Society (EMBC), 2020.
%
% Contact:
%  vital-sensing@ok.sc.e.titech.ac.jp
%  Vital Sensing Group, Okutomi-Tanaka Lab., Tokyo Institute of Technology.
%
% Last Update: January 23, 2020
%**************************************************************************


function [bvpSignal,frameRate,time,cheekGridReliability] = getSignals_3DLand_Tracking_VisibilityCheck(videoFileName,startTime,endTime,angleThres)

% # Input 
% - videoFileName: Fullpath or relative path to the video.
% - startTime/endTime: BVP is estimated using the video within time window [startTim eendTime].
% - angleThres: An threshold of angle used in Fig.2(d)visibility check. In this paper, 
%    we use 75 [degrees] for proposed method.
% 
% # Output
% - bvpSignal: Estimated BVP signal.
% - frameRate: Framerate of the movie.
% - time: Time-stamp of the BVP.
% - cheekGridReliability: Logical matrix which represent whether facial patch is reliable(1) or not(0).

%% prepare for loading video
[direc,name] = fileparts(videoFileName);
vidObj = VideoReader(videoFileName);
frameRate = vidObj.Framerate;
freqRange = 0.7:0.001:4; %Restrict frequency to typical human heart rates.
movingAveWindow = frameRate/5; %Temporal smoothing for removing noise.

%% paraneter setting and initialization 
frames2Use = [round(startTime*frameRate+1):round(endTime*frameRate+1)];
gridLengthRatio = 0.25; % define size of each patch. When gridLengthRatio is 0.25, edge of the patch is 25% long of each cheak edge.
overLapRatio = 0; % define how each patch is overlapped. When overLapRatio is 0.1, 10 % the patch edge will be overlap.
cheekAreaGridColumn = floor(1/(gridLengthRatio-gridLengthRatio*overLapRatio));
cheekAreaGridRow = cheekAreaGridColumn;
cheekGridReliability = zeros(cheekAreaGridRow,2*cheekAreaGridColumn,length(frames2Use));
GridVertices = cell(1,length(frames2Use));


%% visibility check and tracking
% load landmarks
landmarks3DName = fullfile(direc,[name '_3DtrackedLandmarks_frames.mat']);
S = load(landmarks3DName,'trackedLandmarks');
trackedLandmarks3D = S.trackedLandmarks;
clear S
trackedLandmarks3D = trackedLandmarks3D(frames2Use);


% Grid face and visibility check
for frameCnt = 1:length(trackedLandmarks3D)
   [cheekGridReliability(:,:,frameCnt),GridVertices{frameCnt},~,~] = helper(trackedLandmarks3D{frameCnt},angleThres,overLapRatio,gridLengthRatio);
end

% We regard a patch that is visibe in all video frames as reliable.
% All reliable patches are used for BVP estimation

cheekGridReliability = all(cheekGridReliability,3);
CheekGridReliabilityIDX = find(cheekGridReliability==1);

if sum(cheekGridReliability==0)
    bvpSignal = [];
    frameRate = [];time  = [];cheekGridReliability = [];
    return
end



%% compute ICA inputs

channelIdx = [1:3]; % channel to use

% read video frame
frameCnt = 0; % initialize frame count
vidObj.CurrentTime = startTime;
time = zeros(1,length(frames2Use));
traces = zeros(length(channelIdx),length(frames2Use));

while hasFrame(vidObj) && (vidObj.CurrentTime <= endTime)
    frameCnt = frameCnt+1;
    time(frameCnt) = vidObj.CurrentTime;
    vidFrameTemp = readFrame(vidObj);
    if frameCnt==1
        imgSize = size(vidFrameTemp);
    end
    
    for channel = channelIdx
        for gridCnt = CheekGridReliabilityIDX'
            % mak mask which is visible
            bw = poly2mask(double(floor(GridVertices{frameCnt}{gridCnt}(:,1))),double(floor(GridVertices{frameCnt}{gridCnt}(:,2))),imgSize(1),imgSize(2));
            bw = find(bw==1);
            if ~isempty(bw)
                % average intensity within all visible frames
                traces(channel,frameCnt) = traces(channel,frameCnt)+mean(vidFrameTemp(bw+(channel-1)*imgSize(1)*imgSize(2)));
            end
        end
    end
end

traces = moving(traces',movingAveWindow)'; %Smooth using moving average to get rid of some noise.


%% operate ICA
%Finally, run ICA on the traces and store the independent components.
bvpSignal = [];
ica_time_IDX = 0;
numComponents = 3;

while size(bvpSignal,1)<numComponents
    bvpSignal = fastica(traces,'numOfIC',numComponents,'verbose','off','stabilization','off');
    
    % If ICA only provides one component after ten times iteration,
    % the pair of patchs is regarded as not reliable
    ica_time_IDX = ica_time_IDX +1;
    if ica_time_IDX ==10
        bvpSignal = [];
        return
    end
end

%% choose BVP signal
% We assume that BVP is more periodical than ambient light change or subject's motion,
% therefore we take the ICA output which has the most strong power spectral density in the normalized frequency domain.
for j  = 1:numComponents
    
    lambda = 100/((60/frameRate)^2);
    bvpSignal(j,:) = detrendingFilter(bvpSignal(j,:)',lambda)';
    bvpSignal(j,:) = moving(bvpSignal(j,:),movingAveWindow);
    
    %Compute pwelch.
    [pxxEst{j},f] = pwelch(bvpSignal(j,:),length(bvpSignal(j,:)),[],freqRange,frameRate);
    pxxEstNormalized{j} = pxxEst{j} / sum(pxxEst{j});
    
    %Find the peak frequencies in the distribution.
    pks = findpeaks(pxxEstNormalized{j});
    [maxFreqAmp(j),tempIdx] = max(pks);
        
end

[~, bvpIndex] = max(maxFreqAmp);
bvpSignal = bvpSignal(bvpIndex,:);

end
function [CheekGridReliability,GridVertices,angle,Nvec] = helper(Landmarks,angleThres,overLapRatio,gridLengthRatio)

% grid cheek area
[GridVertices] = gridCheekAreaOverlap(Landmarks,overLapRatio,gridLengthRatio);

% derive reliability 
[CheekGridReliability,GridVertices,angle,Nvec] = cheekReliabilityGridNormalOverlap(GridVertices,angleThres);

end
