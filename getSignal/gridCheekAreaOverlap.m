function [GridVertices] = gridCheekAreaOverlap(Landmarks,overLapRatio,gridLengthRatio)
% This function grid chhek area into facial patch as shown in Fig.2 (b). Each patch is represented by 4 vertices.
% # Input
% - Landmarks: Detected 3D facial landmarks.
% - overLapRatio: Define how patches are overlaped each other. If overLapRatio = 0, patchese are not overlap. 
%   If overLapRatio = 0.4, 40% of the patch edge is overlaped. In this paper we set overLapRatio = 0.
% - gridLengthRatio: Define the size of each facial patch. If you want to grid cheek region into 4-by-4 patches just like Fig.2 (b), 
%    you should set gridLengthRatio = 0.25, overLapRatio = 0.
% 
% # Output
% - GridVertices: GridVertices contains vertices of each facial patch. Each cell component corresponds to the facial patch.
%   GridVertices{m,n} = [x_1, y_1, z_1; x_2, y_2, z_2; x_3, y_3, z_3; x_4, y_4, z_4]

% parameter setting
interpMethod = 'linear';


% initializing
Landmarks = squeeze(Landmarks);


% difine ROI edge points to use
leftCheekEdgePts = Landmarks(2:6,:);
rightCheekEdgePts = Landmarks(12:16,:);
centerEdgePts = [Landmarks(28,:);Landmarks(34,:)];

centerEdgeCenter = mean(centerEdgePts(:,1));
rightCheekEdgeCenter = mean(rightCheekEdgePts(:,1));
leftCheekEdgeCenter = mean(leftCheekEdgePts(:,1));
isReverse = [leftCheekEdgeCenter>centerEdgeCenter,centerEdgeCenter>rightCheekEdgeCenter];


% check landmaeks are properly detected
if ~all([all(diff(leftCheekEdgePts(:,2))>0),all(diff(rightCheekEdgePts(:,2))<0),all(diff(centerEdgePts(:,2))>0)])
    GridVertices = [];
    return
end

% interpolate edge points
[leftCheekEdgePts]=interpVerticalHelper(leftCheekEdgePts,interpMethod);
[rightCheekEdgePts]=interpVerticalHelper(flipud(rightCheekEdgePts),interpMethod);
[centerEdgePts]=interpVerticalHelper(centerEdgePts,interpMethod);

% figure out patch start point and end point along with y-axis.
[leftBeginIdx,leftEndIdx] = interDiv3d(leftCheekEdgePts,overLapRatio,gridLengthRatio);
[rightBeginIdx,rightEndIdx] = interDiv3d(rightCheekEdgePts,overLapRatio,gridLengthRatio);
[centerBeginIdx,centerEndIdx] = interDiv3d(centerEdgePts,overLapRatio,gridLengthRatio);

mMax = length(leftBeginIdx);
for rowCnt = 1:mMax
    % figure out patch start point and end point along with x-axis.
    % left cheek
    leftAbovePts =interpHorizontalHelper([leftCheekEdgePts(leftBeginIdx(rowCnt),:);centerEdgePts(centerBeginIdx(rowCnt),:)],interpMethod);
    leftBottomPts =interpHorizontalHelper([leftCheekEdgePts(leftEndIdx(rowCnt),:);centerEdgePts(centerEndIdx(rowCnt),:)],interpMethod);
    % right cheek
    rightAbovePts =interpHorizontalHelper([rightCheekEdgePts(rightBeginIdx(rowCnt),:);centerEdgePts(centerBeginIdx(rowCnt),:)],interpMethod);
    rightBottomPts =interpHorizontalHelper([rightCheekEdgePts(rightEndIdx(rowCnt),:);centerEdgePts(centerEndIdx(rowCnt),:)],interpMethod);
    
    
    % derive vertices of patch
    leftVertices = helper(leftAbovePts,leftBottomPts,overLapRatio,gridLengthRatio,isReverse(1));
    rightVertices = helper(rightAbovePts,rightBottomPts,overLapRatio,gridLengthRatio,isReverse(2));
    
    % concatination
    if rowCnt ==1
        GridVertices = horzcat(leftVertices,rightVertices);
    else
        GridVertices = vertcat(GridVertices,horzcat(leftVertices,rightVertices));
    end
end
end
function [interpPts]=interpVerticalHelper(Pts,interpMethod)
% interpolate edge points along with y-axis
yq = min(Pts(:,2)):max(Pts(:,2));
xq = interp1(Pts(:,2),Pts(:,1),yq,interpMethod);
zq = interp1(Pts(:,2),Pts(:,3),yq,interpMethod);
interpPts = [xq',yq',zq'];
end
function [interpPts]=interpHorizontalHelper(Pts,interpMethod)
% interpolate edge points along with x-axis
% if width along with x-axis is too narrow,
% interpolate edge points along with y-axis

xq = min(Pts(:,1)):max(Pts(:,1));
if ~(length(xq)<5)
    yq = interp1(Pts(:,1),Pts(:,2),xq,interpMethod); 
    zq = interp1(Pts(:,1),Pts(:,3),xq,interpMethod);
else
    % in case width along with x-axis is too narrow
    zq =  min(Pts(:,3)):max(Pts(:,3));
    yq = interp1(Pts(:,3),Pts(:,2),zq,interpMethod);
    xq = interp1(Pts(:,3),Pts(:,1),zq,interpMethod);
end
interpPts = [xq',yq',zq'];
end
function [GridVertices] = helper(abovePts,bottomPts,overLapRatio,gridLengthRatio,isReverse)

[aboveBeginIdx,aboveEndIdx] = interDiv3d(abovePts,overLapRatio,gridLengthRatio);
[bottomBeginIdx,bottomEndIdx] = interDiv3d(bottomPts,overLapRatio,gridLengthRatio);
nMax = length(aboveBeginIdx);
GridVertices = cell(1,nMax);

for columCnt = 1:nMax
    GridVertices{1,columCnt} = [abovePts(aboveBeginIdx(columCnt),:);bottomPts(bottomBeginIdx(columCnt),:);bottomPts(bottomEndIdx(columCnt),:);abovePts(aboveEndIdx(columCnt),:)];
    if isReverse
        GridVertices{1,columCnt} = flipud(GridVertices{1,columCnt});
    end
end
end
