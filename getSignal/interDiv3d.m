function [beginIdx,endIdx] = interDiv3d(edgePts,overLapRatio,gridLengthRatio)
% This function inter devide the edge of cheek region (Gray bold edge in Fig.2(b)) based on 3D space distance.
% # Input 
% - edgePts: 3D edge points. edgePts(m,:) represente 3d point [x, y, z].
% - overLapRatio/gridLengthRatio: Same as __gridCheekAreaOverlap.m__.
% 
% # Output
% - beginIdx/endIdx: edgePts(beginIdx,:) = [x, y, z] which is begin point of the facial patch.

temp = diff(edgePts,1,1);
[m,~] = size(temp);
distance3D = zeros(m,1);
for i = 1:m
    distance3D(i,1) = norm(temp(i,:));
end
cumsumDistance3D = cumsum(distance3D);
totalDistance = sum(distance3D);
gridLength = totalDistance*gridLengthRatio;
ovelapLength = gridLength*overLapRatio;


beginDist =[0:gridLength-ovelapLength:totalDistance-gridLength]';
endDist = [beginDist+gridLength];

beginIdx = knnsearch(cumsumDistance3D,beginDist);
endIdx = knnsearch(cumsumDistance3D,endDist);



end
