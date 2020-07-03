function corners = RemoveCornerwithLowQuality(corners,tau)

    idx = corners.v1(:,1)==0 & corners.v1(:,2)==0;
    corners = RemoveCorner(corners,idx);
    
    idx = corners.score < tau;
    corners = RemoveCorner(corners,idx);
            
end
function corners = RemoveCorner(corners,idx)
    corners.p(idx,:)            = [];
    corners.v1(idx,:)           = [];
    corners.v2(idx,:)           = [];
    corners.FocusScore(idx,:)   = [];
    corners.pImg(idx,:)         = [];
    corners.LensID(idx,:)       = [];
    corners.response(idx,:)        = [];
    corners.score(idx,:)        = [];
end