function corners = UpdateCorner(corners,idx)
    corners.p           = corners.p(idx,:);
    corners.v1          = corners.v1(idx,:);
    corners.v2          = corners.v2(idx,:);
    corners.FocusScore  = corners.FocusScore(idx,:);
    corners.pImg        = corners.pImg(idx,:);
    corners.LensID      = corners.LensID(idx,:);
    corners.response    = corners.response(idx,:);
    corners.score       = corners.score(idx,:);
end