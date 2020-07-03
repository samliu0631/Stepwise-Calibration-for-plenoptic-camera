function corners = RemoveCornersOnEdge(ROILeftCoords,corners, NbLensCoords,LensRadius,SearchThreshold,CurrentLensIDnearCorner)
    minX                    = ROILeftCoords(1);
    minY                    = ROILeftCoords(2);
    CornersNumROI           = size(corners.p,1);  % 角点的总数量。    
    LensIDperCorner         = [];
    CornerIDnoEdges         = [];
    CornerCoordsImg         = [];
    if CornersNumROI>0
        CornerCoordsImg      = corners.p(:,1:2)+[floor(minX)-1, floor(minY)-1]; % convert to coordinates in whole image.
        for i=1:CornersNumROI
            dist_currentcorner  = sqrt(sum( ( CornerCoordsImg(i,:)-NbLensCoords ).^2  , 2 ));   % 计算每个点到微透镜中心的距离。
            valueID             = find( dist_currentcorner<= (LensRadius-SearchThreshold) ); % 根据距离，进行筛选，剔除分布在边缘的检测点。
            if ~isempty(valueID)
                CornerIDnoEdges         = [CornerIDnoEdges;i];
                LensIDperCorner        = [LensIDperCorner;  CurrentLensIDnearCorner(valueID) ];
            end
        end
    end    
    corners.p          = corners.p(CornerIDnoEdges,:);
    corners.LensID     = LensIDperCorner;
    corners.pImg       = CornerCoordsImg(CornerIDnoEdges,:);
    corners.response   = corners.response(CornerIDnoEdges,:);
end