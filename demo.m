%**************************************************************************
% Copyright (C) 2020, Yuichiro MAKI, all rights reserved.
%  Do not redistribute without permission.
%  Strictly for academic and non-commerial purpose only.
%  Use at your own risk.
%
% Please cite the following paper if you use this code.
%
% - Yuichiro Maki, Yusuke Monno, Masayuki Tanaka, and Masatoshi Okutomi,
%   "Remote Heart Rate Estimation Based on 3D Facial Landmarks",
%   International Conference of the IEEE Engineering in Medicine and 
%   Biology Society (EMBC), 2020.
%
% Contact:
%  vital-sensing@ok.sc.e.titech.ac.jp
%  Vital Sensing Group, Okutomi-Tanaka Lab., Tokyo Institute of Technology.
%
% Last Update: January 23, 2020
%**************************************************************************

% You can instantly run our whole code for our sample data and display a comparison 
% between the sequential HRs estimated by the baseline method, the proposed method, 
% and a reference contact PPG sensor visually as shown in Fig.3 of the paper.
% Estimated HR at a certain time window is stored in the corresponding matfile.

clear all; close all
%% setting
isPlot = 1;


%% parameters
path_to_dataset = 'path/to/dataset';
if strcmp(path_to_dataset,'path/to/dataset')
    path_to_dataset = './';
end
videoName = 'video.avi';
frameRate = 30;
movie2Use = [5 65];
movingWindowWidth = 10;
smoothPts = 7; % the number of smoothing Points (N = 7)
angleThresCandidate = [75,Inf];
movingWindowWidthCandidate = [10];
sceneCadidate = {'01'};
PersonCntCandidate = [1];


% %% Run our method and baseline methods
for strCnt = 1:length(sceneCadidate)
    str = ['%02d-',sceneCadidate{strCnt}];
    
    for movingWindowWidth = movingWindowWidthCandidate
        for PersonCnt =PersonCntCandidate
            
            id = sprintf(str,PersonCnt);
            folder = fullfile(path_to_dataset,'TokyoTech',id,id);
            videoFileName = fullfile(folder,videoName);
            
            disp(['Estimating BVP with proposed method (scene: ',sceneCadidate{strCnt},'person id: ',num2str(PersonCnt),')...'])
            for angleThres = angleThresCandidate
                run_getSignals_3DLand_Tracking_VisibilityCheck(folder,movingWindowWidth,frameRate,angleThres,movie2Use)% '3D landmarks + Tracking' and '3D landmarks + Tracking  Visibility Check'
            end
            
            disp(['Estimating BVP with baseline method (scene: ',sceneCadidate{strCnt},'person id: ',num2str(PersonCnt),')...'])
            run_getSignals_2DLand_Tracking_withOut_VisibilityCheck(folder,movingWindowWidth,frameRate,movie2Use) % '2D landmarks + Tracking'
            run_getSignals_2DLand_fixed1stFrame(folder,movingWindowWidth,frameRate,movie2Use) % '2D landmarks'
            
        end
    end
end

%% Plot result
if isPlot
    path_to_direc = path_to_dataset;
    [f] = makeSequentialHRGraph_TokyoTech(movingWindowWidthCandidate,frameRate,str,movie2Use,PersonCntCandidate,path_to_direc);
end