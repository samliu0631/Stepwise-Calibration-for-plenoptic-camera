function [RawROI,ROILeftCoords] = FormROIImg(CurImg_raw,NbLensCoords,LensRadius)
    RawImgSizetem       = size(CurImg_raw);
    RawImgSize          = [ RawImgSizetem(2), RawImgSizetem(1)];
    % 首先确定感兴趣区域的大致范围
    maxX                = min( max(NbLensCoords(:,1))+4*LensRadius   , RawImgSize(1) ); %%%%%%%%%%
    minX                = max( min(NbLensCoords(:,1))-4*LensRadius   , 1 );
    maxY                = min( max(NbLensCoords(:,2))+4*LensRadius   , RawImgSize(2) );
    minY                = max( min(NbLensCoords(:,2))-4*LensRadius   , 1 );
    % 感兴趣区域提取，调整亮度，
    RawROI              = CurImg_raw(floor(minY):floor(maxY) , floor(minX):floor(maxX));                    % 图像提取，先纵后横
    MaxPixel            = max(max(RawROI));
    MinPixel            = min(min(RawROI));
    RawROI              = (RawROI-MinPixel)./(MaxPixel-MinPixel);                                  % 像素亮度调整。
    ROILeftCoords       = [minX,minY];
end