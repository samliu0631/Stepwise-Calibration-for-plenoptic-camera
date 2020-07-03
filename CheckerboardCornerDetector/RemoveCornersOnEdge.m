function corners = RemoveCornersOnEdge(ROILeftCoords,corners, NbLensCoords,LensRadius,SearchThreshold,CurrentLensIDnearCorner)
    minX                    = ROILeftCoords(1);
    minY                    = ROILeftCoords(2);
    CornersNumROI           = size(corners.p,1);  % �ǵ����������    
    LensIDperCorner         = [];
    CornerIDnoEdges         = [];
    CornerCoordsImg         = [];
    if CornersNumROI>0
        CornerCoordsImg      = corners.p(:,1:2)+[floor(minX)-1, floor(minY)-1]; % convert to coordinates in whole image.
        for i=1:CornersNumROI
            dist_currentcorner  = sqrt(sum( ( CornerCoordsImg(i,:)-NbLensCoords ).^2  , 2 ));   % ����ÿ���㵽΢͸�����ĵľ��롣
            valueID             = find( dist_currentcorner<= (LensRadius-SearchThreshold) ); % ���ݾ��룬����ɸѡ���޳��ֲ��ڱ�Ե�ļ��㡣
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