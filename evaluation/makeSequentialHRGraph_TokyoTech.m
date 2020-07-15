function [f] = makeSequentialHRGraph_TokyoTech(movingWindowWidthCandidate,frameRate,str,movie2Use,PersonCntCandidate,path_to_direc)


for movingAveWidth = movingWindowWidthCandidate
    for idCnt = 1:length(PersonCntCandidate)
        
        id = PersonCntCandidate(idCnt);
        id = sprintf(str,id);
        load(fullfile(path_to_direc,'TokyoTech',id,id,'video_trackedLandmarks_frames.mat'));
        
                
        matNamePart = 'bvpSignal2DLand_Tracking_withOut_VisibilityCheck';
        [xVec,HRest,s] = gatherResult_Tokyotech(id,movingAveWidth,matNamePart,movie2Use,path_to_direc);
        isDetectLandmarks = true(1,length(trackedLandmarks));
        for cnt = 1:length(trackedLandmarks)
            if isempty(trackedLandmarks(cnt).faces)
                isDetectLandmarks(1,cnt) = 0;
            end
        end
        landmarkIDX = false(1,floor(movie2Use(end)-movie2Use(1)-movingAveWidth));
        for cnt = 0:length(landmarkIDX)-1
            startTime = cnt+movie2Use(1);
            endTime = startTime+movingAveWidth;
            temp = isDetectLandmarks(startTime*frameRate:endTime*frameRate);
            landmarkIDX(cnt+1) = all(temp);        
        end
        
        

        xVec_IDX = (HRest == Inf) | (landmarkIDX==0);
        HRest(xVec_IDX) = [];
        xVec(xVec_IDX) = [];
        
        f = figure('visible','on','Position',[0, 0, 1600, 1000]);
        plot(s.locs(2:end),s.GT_HR,'-d','MarkerFaceColor',[0,0,0],'Color',[0,0,0],'LineWidth',5,'DisplayName',['Contact PPG sensor'])
        hold on;
        grid on
        
        
        plot(xVec,HRest,'s','MarkerFaceColor',[0.8500 0.3250 0.0980] ,'Color',[0.8500 0.3250 0.0980] ,'LineWidth',10,'DisplayName',['2D landmark + Tracking'])
        
        
        matNamePart = 'bvpSignal_3DLand_Tracking_VisibilityCheck_angleThres_75';
        [xVec,HRest,~] = gatherResult_Tokyotech(id,movingAveWidth,matNamePart,movie2Use,path_to_direc);
        xVec_IDX = (HRest == Inf);
        HRest(xVec_IDX) = [];
        xVec(xVec_IDX) = [];
        
        
        plot(xVec,HRest,'o','MarkerFaceColor',[0 0.4470 0.7410],'Color',[0 0.4470 0.7410] ,'LineWidth',10,'DisplayName','3D landmark + Tracking + Visibility check')
        %%
        
        gtPlot = 0;
        
        
        
        
        
        
        legend();
        xticks([5:10:65])
        xlim([5 65]);ylim([60 120])
        xticklabels({'0','10','20','30','40','50','60'})
        xlabel('Time[sec.]')
        ylabel('HR [bpm]')
        set(gca,'FontSize',35)
        
        
    end
end


