function [CheekGridReliability,GridVertices,angle,Nvec] = cheekReliabilityGridNormalOverlap(GridVertices,angleThres)
% This function find whether each grid is reliable or not
% by calcurating normal of each grid

% Input
% cheekGridOut: Outout of gridCheekAre.m
% angleThres: threshold of angle between camera plane and grid surface.
% Output
% CheekGridReliability: reliability of cheek grid. If sertain grid is reliable, coreponding reliability is 1 (logical).
% GridVertices: Vertices of each grid

[mMax,nMax] = size(GridVertices);
Nvec = cell(mMax,nMax);


for m = 1:mMax
    for n = 1:nMax
        Nvec{m,n} = GetNormal( GridVertices{m,n}' );
    end
end
angle = cellfun(@getAngle, Nvec);
CheekGridReliability = (angle < angleThres);
end



function [angle] = getAngle(Nvec)
angle = rad2deg(acos(dot(Nvec,[0,0,-1])));
end