function Omiga  = CalculatePlenopticDiscFeatureLSM(allPts_perCorner,GridCoords )
    GridCoordsX     = GridCoords(:,:,1);
    GridCoordsY     = GridCoords(:,:,2);
    pixels          = allPts_perCorner(:,1:2);
    LensID          = allPts_perCorner(:,3);
    MicroImgCenterX = GridCoordsX(LensID);
    MicroImgCenterY = GridCoordsY(LensID);
    data_x          = [repmat([-1,0],numel(MicroImgCenterX),1),(MicroImgCenterX-pixels(:,1)),MicroImgCenterX];  % -1  0
    data_y          = [repmat([0,-1],numel(MicroImgCenterY),1),(MicroImgCenterY-pixels(:,2)),MicroImgCenterY];  %  0 -1
    window_data     = [data_x;data_y];
    [~,~,V]         = svd(window_data);
    v               = V(:,end);
    v               = v/v(end);
    w               = v(1:2)';
    R               = v(3);
    Omiga           = [w,R];
end