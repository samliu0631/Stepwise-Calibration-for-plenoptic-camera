function [RawROI,ROILeftCoords] = FormROIImg(CurImg_raw,NbLensCoords,LensRadius)
    RawImgSizetem       = size(CurImg_raw);
    RawImgSize          = [ RawImgSizetem(2), RawImgSizetem(1)];
    % ����ȷ������Ȥ����Ĵ��·�Χ
    maxX                = min( max(NbLensCoords(:,1))+4*LensRadius   , RawImgSize(1) ); %%%%%%%%%%
    minX                = max( min(NbLensCoords(:,1))-4*LensRadius   , 1 );
    maxY                = min( max(NbLensCoords(:,2))+4*LensRadius   , RawImgSize(2) );
    minY                = max( min(NbLensCoords(:,2))-4*LensRadius   , 1 );
    % ����Ȥ������ȡ���������ȣ�
    RawROI              = CurImg_raw(floor(minY):floor(maxY) , floor(minX):floor(maxX));                    % ͼ����ȡ�����ݺ��
    MaxPixel            = max(max(RawROI));
    MinPixel            = min(min(RawROI));
    RawROI              = (RawROI-MinPixel)./(MaxPixel-MinPixel);                                  % �������ȵ�����
    ROILeftCoords       = [minX,minY];
end