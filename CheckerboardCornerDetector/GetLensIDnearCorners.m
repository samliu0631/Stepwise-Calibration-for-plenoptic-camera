function LensIDnearCorner = GetLensIDnearCorners(corner,neighbrs,GridCoords,LensletGridModel)
    GridCoordsX                 = GridCoords(:,:,1);
    GridCoordsY                 = GridCoords(:,:,2);
    center_list                 = [GridCoordsX(:),GridCoordsY(:)]';
    radius                      = [ (LensletGridModel.HSpacing)/2 ,  (LensletGridModel.VSpacing)/2 ];
    centers_scaled              = center_list ./ (2 * radius') + 0.5 ;
    LensIDnearCorner            = zeros(size(corner, 1), neighbrs);                             
    for i =1:size(corner,1)
        dist                    = sqrt(sum((centers_scaled' - corner(i,:)).^2, 2));        % 计算角点到微透镜中心的坐标。
        [~, ids]                = sort(dist);                                              % 对间距由大到小进行排序。
        ids                     = ids(1:neighbrs);                                         % 选出距离角点最近的12个微透镜，得到其对应的序号。
        LensIDnearCorner(i, :)     = ids;                                                     % 对每个角点对应的微透镜序号进行记录。
    end
end
