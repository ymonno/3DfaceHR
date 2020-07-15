function Nvec = GetNormal( Prand )

%centering
cen = mean(Prand, 2);
Prand = bsxfun(@minus, Prand, cen);

[U, S, V] = svd(Prand');
Nvec = V(:, 3);
if dot(cross(Prand(:,1),Prand(:,2)),Nvec)<0
    Nvec = Nvec*(-1);
end
end