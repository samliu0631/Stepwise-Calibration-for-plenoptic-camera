function  [corners1,corners2,RawROI] = DetectCorner(CurrentLensIDnearCorner, Img_raw, LensRadius, GridCoords,LensletGridModel , templateCell, ConfigBag, DetectTresh, Debug)
    if isfield(ConfigBag,'CameraType')
        CameraType = ConfigBag.CameraType;
    else
        ConfigBag.CameraType = 'Raytrix';
        CameraType = 'Raytrix';
    end
    % obtain the ROI.
    GridCoordsX                 = GridCoords(:,:,1);
    GridCoordsY                 = GridCoords(:,:,2);
    NbLensCoords                = [ GridCoordsX(CurrentLensIDnearCorner)'  , GridCoordsY(CurrentLensIDnearCorner)' ];
    [RawROI,ROILeftCoords]      = FormROIImg(Img_raw,NbLensCoords,LensRadius);
    
    %MaskImg=GenerateMaskImg(NbLensCoords,LensRadius,RawROI,ROILeftCoords);
    
    % Detect corners within ROI.
    [corners1,corners2]          = findCorners(RawROI,templateCell,DetectTresh);

    if Debug == true
        figure;imshow(RawROI);hold on; plot(corners1.p(:,1),corners1.p(:,2),'*');hold off;
        figure;imshow(RawROI);hold on; plot(corners2.p(:,1),corners2.p(:,2),'*');hold off;
    end

    % Remove corners on the edges.
    corners1                     = RemoveCornersOnEdge(ROILeftCoords,corners1, NbLensCoords,LensRadius,ConfigBag.SearchThreshold,CurrentLensIDnearCorner);
    corners2                     = RemoveCornersOnEdge(ROILeftCoords,corners2, NbLensCoords,LensRadius,ConfigBag.SearchThreshold,CurrentLensIDnearCorner);
    if Debug == true
        figure;imshow(RawROI);hold on; plot(corners1.p(:,1),corners1.p(:,2),'*');hold off;
        figure;imshow(RawROI);hold on; plot(corners2.p(:,1),corners2.p(:,2),'*');hold off;
    end

    % calculate orientation and focal score.
    [corners1,ImgBag]            = CalculateCornerOrientationAndFocusScore(RawROI,corners1,CameraType);
    [corners2,~]                 = CalculateCornerOrientationAndFocusScore(RawROI,corners2,CameraType);
    

    % refine corners and remove corners with low quality.
    if strcmp(CameraType,'Raytrix')
        corners1                     = RefineSelectedCorners(corners1,ImgBag,GridCoords,LensRadius);
        corners2                     = RefineSelectedCorners(corners2,ImgBag,GridCoords,LensRadius);
    end
    corners1                     = RemoveCornerwithLowQuality(corners1,-1);
    corners2                     = RemoveCornerwithLowQuality(corners2,-1);

    if Debug == true
        figure;imshow(RawROI);hold on; plot(corners1.p(:,1),corners1.p(:,2),'*');hold off;
        figure;imshow(RawROI);hold on; plot(corners2.p(:,1),corners2.p(:,2),'*');hold off;
    end
end





function MaskImg=GenerateMaskImg(NbLensCoords,LensRadius,RawROI,ROILeftCoords)
    TrueDiameter= LensRadius*2;
    CircleSize  = ceil(TrueDiameter)+1;
    if mod(CircleSize,2)==0  % make sure the circlesize is odd.
        CircleSize = CircleSize+1;
    end
    minX                    = ROILeftCoords(1);
    minY                    = ROILeftCoords(2);
    Mask        = zeros(CircleSize,CircleSize);
    x           = 1:CircleSize;
    y           = 1:CircleSize;
    [xx,yy]     = meshgrid(x,y);
    xy          = [xx(:),yy(:)];
    center      = [CircleSize+1,CircleSize+1]/2;
    distance    = sqrt(sum((xy-center).^2,2));
    Mask(distance<(TrueDiameter/2-1)) = 1;     % narrow 1 pixel.
    figure;imshow(Mask);
    % produce mask image.
    ImgSize     = size(RawROI);
    MaskImg     = zeros(size(RawROI)+[10,10]);
    %MaskImg     = zeros(size(RawROI));
    PatchRadius = (CircleSize-1)/2;
    X2          = -PatchRadius : 1 : PatchRadius;
    Y2          = -PatchRadius : 1 : PatchRadius;
    LensCoords  = NbLensCoords+[5,5];
    %LensCoords  = NbLensCoords;
    for i=1:size(LensCoords,1)
        Coords = LensCoords(i,:);
        FillPatchInterp3 = FillPatchtoRaw(Mask,Coords,CircleSize,'nearest');
        FillPatchInterp3(isnan(FillPatchInterp3))=0;
        MaskImg( round(Coords(2))+Y2-(floor(minY)-1) ,round(Coords(1))+X2 -(floor(minX)-1) )= MaskImg( round(Coords(2))+Y2-(floor(minY)-1) ,round(Coords(1))+X2-(floor(minX)-1) )+FillPatchInterp3;
    end
    figure;imshow(MaskImg);
    MaskImg = MaskImg(6:ImgSize(1)+5,6:ImgSize(2)+5);
    figure;imshow(MaskImg);
end