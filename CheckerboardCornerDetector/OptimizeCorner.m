function [Omega,ClearType,ClearPts_perCorner] = OptimizeCorner(corners,CellRGBLensID,Img_raw2,Img_raw,GridCoords,LensRadius,ConfigBag,templateCell,CornerType,Debug)
    ClearType = 0;
    if isfield(ConfigBag,'CameraType')
        CameraType = ConfigBag.CameraType;
    else
        ConfigBag.CameraType = 'Raytrix';
        CameraType = 'Raytrix';
    end
    
    allPts_perCorner            = [corners.pImg,  corners.LensID];
    if Debug == true
        figure;imshow(Img_raw2);hold on; plot(corners.pImg(:,1),corners.pImg(:,2),'*');hold off;
    end
    
    % calculate Plenoptic disc features roughly.
    Omega                   = CalculatePlenopticDiscFeatureLSM(allPts_perCorner,GridCoords );      
    
    % form new ROI 
    allProjPtsPerCorner      = ProjectPDF2Img(Omega, GridCoords, LensRadius,-1 ,0); % 这个需要后期测试。
    if  isempty(allProjPtsPerCorner)
        Omega     = [];
        ClearType = 0;
        ClearPts_perCorner =[];
        return;
    end
    GridCoordsX              = GridCoords(:,:,1);
    GridCoordsY              = GridCoords(:,:,2);
    NbLensCoords             = [ GridCoordsX(allProjPtsPerCorner(:,3)) , GridCoordsY(allProjPtsPerCorner(:,3)) ];
    [RawROI,ROILeftCoords]   = FormROIImg(Img_raw, NbLensCoords,   LensRadius); 
    
    % Detect corners within new ROI.
    %templateCell             = templateCell(CornerType);
    [corners1,corners2]      = findCorners(RawROI,templateCell,0.025);
    if CornerType==1
        corners = corners1;
    else
        corners = corners2;
    end
    
    % remove corner
    if  Debug ==true
        figure;imshow(RawROI);hold on; plot(corners.p(:,1),corners.p(:,2),'*');hold off;
    end
    
    corners                     = RemoveCornersOnEdge(ROILeftCoords,corners, NbLensCoords,LensRadius,ConfigBag.SearchThreshold ,allProjPtsPerCorner(:,3));
    [corners,ImgBag]            = CalculateCornerOrientationAndFocusScore(RawROI,corners);
    
    if  Debug ==true
        figure;imshow(RawROI);hold on; plot(corners.p(:,1),corners.p(:,2),'*');hold off;
    end

%     if strcmp(CameraType,'Raytrix')
%         % corner refine  
%         cornersRefine               = RefineSelectedCorners(corners,ImgBag,GridCoords,LensRadius);         % refine radius is better to be adjusted
%         cornersRefine               = RemoveCornerwithLowQuality(cornersRefine,0.003);
%         if  Debug ==true
%             figure;imshow(RawROI);hold on; plot(cornersRefine.p(:,1),cornersRefine.p(:,2),'*');hold off;
%         end       
%     else
        points             = RefineCornerSmallPatch(RawROI,CornerType, corners.p);
        offset             = points - corners.p;
        corners.pImg       = corners.pImg+offset;
        corners.p          = points;
        cornersRefine      = corners;
    %end

    % choose the corners which is close to project poinst.
    allPts_perCorner = [];
    IDList           = [];
    cornerNum        = size(cornersRefine.pImg,1);
    for id = 1 :cornerNum
       CurCornerCoords  = cornersRefine.pImg(id,:); % 
       CurLensID        = cornersRefine.LensID(id); % the refined corner's lens index.
       findFlag         = sum((allProjPtsPerCorner(:,3)==CurLensID));  
       if  findFlag==1 % if a detected point and a projected point are in the same lens.
           ProjCornerCoords = allProjPtsPerCorner( (allProjPtsPerCorner(:,3)==CurLensID) , 1:2);
           dist             = sqrt( sum( ( CurCornerCoords - ProjCornerCoords ).^2,2) );  %%the code here should be changed
           if dist < 2
               IDList            = [IDList;id];
               allPts_perCorner  = [allPts_perCorner;[CurCornerCoords,  cornersRefine.LensID(id)]];
           end
       end
    end        
    
    % make sure that there is more than 2 corners left.
    CornerNumLeft = size(IDList,1);
    if CornerNumLeft < 2
        Omega     = [];
        ClearType = 0;
        ClearPts_perCorner =[];
        return;
    end
    
    cornersInner = UpdateCorner(cornersRefine,IDList);     
    if Debug == true
        figure;imshow(Img_raw2);hold on; plot(allPts_perCorner(:,1),allPts_perCorner(:,2),'*');hold off;
    end
    
    if strcmp(CameraType,'Raytrix')
        % Classify the  corners types through corner focus scores.
        [allPts_perCorner,ClearPts_perCorner,ClearType] = SelectClearPoints(cornersInner.FocusScore, allPts_perCorner, CellRGBLensID);
        if Debug == true
            figure;imshow(Img_raw2);hold on; plot(ClearPts_perCorner(:,1),ClearPts_perCorner(:,2),'*');hold off;
        end
        if size(allPts_perCorner,1)<=1
            ClearType = 0;
            return;
        end    
        % Optimize the plenoptic disc radius by simularity.
        ClearNum                    = size(ClearPts_perCorner,1);  % 这里应该根据omega的半径判断。是否使用清晰点进行优化。
        if ClearNum >= 2            % if there are enough clear corners.
            Omega                   = CalculatePlenopticDiscFeatureLSM(ClearPts_perCorner,GridCoords );
            PDRadiusOpt             = OptimizePlenopticDiscRadius(Img_raw2, Omega, GridCoords,LensRadius,CellRGBLensID{ClearType},ConfigBag.OptThresh);
        else
            Omega                   = CalculatePlenopticDiscFeatureLSM(allPts_perCorner,GridCoords );
            PDRadiusOpt             = OptimizePlenopticDiscRadius(Img_raw2, Omega, GridCoords,LensRadius,-1,ConfigBag.OptThresh);
        end                         % ShowPDF(Img_raw,Omiga,LensRadius);
        if  abs(  abs(PDRadiusOpt) - abs(Omega(3)) ) < 3     % make sure the optimization is within the possible range.
            Omega(3) = PDRadiusOpt;
        end
    end
    
    if strcmp(CameraType,'Lytro')
        ClearType = 0;
        Omega                   = CalculatePlenopticDiscFeatureLSM(allPts_perCorner,GridCoords );
        PDRadiusOpt             = OptimizePlenopticDiscRadius(Img_raw2, Omega, GridCoords,LensRadius,-1,ConfigBag.OptThresh);
        ClearPts_perCorner      = allPts_perCorner;
        if  abs(  abs(PDRadiusOpt) - abs(Omega(3)) ) < 3     % make sure the optimization is within the possible range.
            Omega(3) = PDRadiusOpt;
        end
    end
    
end





function  points = RefineCornerSmallPatch(Ig,CornerType, pointsInterger)
    derivFilter = [-1 0 1];
    Iy = imfilter(Ig, derivFilter', 'conv');  % y方向一阶偏导
    Ix = imfilter(Ig, derivFilter, 'conv');   % x方向一阶偏导
    if CornerType ==1
        % second derivative
        Ixy = imfilter(Ix, derivFilter', 'conv');    % 二阶偏导IxIy
        IXY = Ixy;
    else
        % define steerable filter constants
        cosPi4 = coder.const(cast(cos(pi/4), 'like', Ig));      % cospi/4
        cosNegPi4 = coder.const(cast(cos(-pi/4), 'like', Ig));  % cos(-pi/4)
        sinPi4 = coder.const(cast(sin(pi/4), 'like', Ig));      % sin(pi/4)
        sinNegPi4 = coder.const(cast(sin(-pi/4), 'like', Ig));  % sin(-pi/4)
        % first derivative at 45 degrees
        I_45 = Ix * cosPi4 + Iy * sinPi4;             % 45度方向 1阶偏导
        I_45_x = imfilter(I_45, derivFilter, 'conv'); % 2阶偏导 I45Ix
        I_45_y = imfilter(I_45, derivFilter', 'conv');  % 2阶偏导  I45Iy
        I_45_45 = I_45_x * cosNegPi4 + I_45_y * sinNegPi4;  % 2阶偏导 I45In45
        IXY =I_45_45;
    end
    points              = vision.internal.calibration.checkerboard.subPixelLocation(IXY, pointsInterger);
end
