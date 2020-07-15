function [xVec,HRest,s] = gatherResult_Tokyotech(id,movingAveWidth,matNamePart,movie2Use,path_to_direc)


folder = fullfile(path_to_direc,'TokyoTech',id,id);


movingAveShift = 1;
numMovingWin = floor((movie2Use(end)-movie2Use(1)-movingAveWidth)/movingAveShift);
folderMat = fullfile(folder,'mat');
frameRate = 30;
HRest = null(1,numMovingWin);

for movingWinCnt = 1:numMovingWin
    
    startTime = movie2Use(1)+movingWinCnt*movingAveShift;
    endTime = startTime+movingAveWidth;
    
    matName = strcat(matNamePart,sprintf('_%02dsec-%02dsec.mat',startTime,endTime));
        s = load(fullfile(folderMat,matName),'bvpCandidates');
        
        
        if iscell(s.bvpCandidates)
            if isempty(s.bvpCandidates)
                HRest(1,movingWinCnt) = Inf;
                continue
            else
            s.bvpCandidates = s.bvpCandidates{1,1};
            end
        end
        if ~isempty(s.bvpCandidates)
            try
                [HRest(1,movingWinCnt),~] = signal2HeartRate(s.bvpCandidates,frameRate,0);
            catch
                keyboard
            end
            clear s
        else
            HRest(1,movingWinCnt) = Inf;
        end

end

xVec = [movie2Use(1):movie2Use(1)+numMovingWin-1]+movingAveWidth/2*ones(1,numMovingWin);



s = load(fullfile(path_to_direc,'TokyoTech',id,id,[id,'GT.mat']),'locs','GT_HR','signal','time');



end