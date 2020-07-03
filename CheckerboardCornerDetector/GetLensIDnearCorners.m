function LensIDnearCorner = GetLensIDnearCorners(corner,neighbrs,GridCoords,LensletGridModel)
    GridCoordsX                 = GridCoords(:,:,1);
    GridCoordsY                 = GridCoords(:,:,2);
    center_list                 = [GridCoordsX(:),GridCoordsY(:)]';
    radius                      = [ (LensletGridModel.HSpacing)/2 ,  (LensletGridModel.VSpacing)/2 ];
    centers_scaled              = center_list ./ (2 * radius') + 0.5 ;
    LensIDnearCorner            = zeros(size(corner, 1), neighbrs);                             
    for i =1:size(corner,1)
        dist                    = sqrt(sum((centers_scaled' - corner(i,:)).^2, 2));        % ����ǵ㵽΢͸�����ĵ����ꡣ
        [~, ids]                = sort(dist);                                              % �Լ���ɴ�С��������
        ids                     = ids(1:neighbrs);                                         % ѡ������ǵ������12��΢͸�����õ����Ӧ����š�
        LensIDnearCorner(i, :)     = ids;                                                     % ��ÿ���ǵ��Ӧ��΢͸����Ž��м�¼��
    end
end
