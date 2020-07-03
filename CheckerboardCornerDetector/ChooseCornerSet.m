function [corners,CornerType] = ChooseCornerSet(corners1,corners2,GridCoords,  LensRadius,   ConfigBag,MinMeanResponse,Debug,RawROI)
    if isfield(ConfigBag,'CameraType')
        CameraType = ConfigBag.CameraType;
    else
        ConfigBag.CameraType = 'Raytrix';
        CameraType = 'Raytrix';
    end    
    %　ransac
    if size(corners1.p,1)>0
        %corners1      = RemoveCornerbyRANSAC( corners1,  GridCoords,  LensRadius,   ConfigBag.Error_Inner,MinMeanResponse,'score');
        corners1      = RemoveCornerbyRANSACPDF( corners1,  GridCoords,  LensRadius,   ConfigBag.Error_Inner,MinMeanResponse,'score');
    end
    if size(corners2.p,1)>0
        %corners2      = RemoveCornerbyRANSAC( corners2,  GridCoords,  LensRadius,   ConfigBag.Error_Inner,MinMeanResponse,'score');
        corners2      = RemoveCornerbyRANSACPDF( corners2,  GridCoords,  LensRadius,   ConfigBag.Error_Inner,MinMeanResponse,'score');
    end
    if Debug == true
        figure;imshow(RawROI);hold on; plot(corners1.p(:,1),corners1.p(:,2),'*');hold off;
        figure;imshow(RawROI);hold on; plot(corners2.p(:,1),corners2.p(:,2),'*');hold off;
    end

    % choose corner set.
    corner1Num   = size(corners1.p,1);
    corner2Num   = size(corners2.p,1);
    if abs(corner1Num-corner2Num) > 5
        if corner1Num > corner2Num
            corners = corners1;
            CornerType  = 1;
        else
            corners = corners2;
            CornerType  = 2;
        end
    else
        MeanResponse1   = mean(corners1.response);
        MeanResponse2   = mean(corners2.response);
        if strcmp(CameraType,'Raytrix')
            OrientScoreAve1 = CalculateOrientationConsistency(corners1.v1,corners1.v2);
            OrientScoreAve2 = CalculateOrientationConsistency(corners2.v1,corners2.v2);
            Setscore1       = MeanResponse1*(1-OrientScoreAve1);
            Setscore2       = MeanResponse2*(1-OrientScoreAve2);
        else
            Setscore1       = MeanResponse1;
            Setscore2       = MeanResponse2;
        end

        if  Setscore1  > Setscore2 || isnan(Setscore2)
            corners = corners1;
            CornerType = 1;
        else
            corners = corners2;
            CornerType = 2;
        end
    end
    if  size(corners.p,1)==2 % 如果最终只有2个点，就去掉这种情况。
        corners= [];
        CornerType =0;
        return;
    end
    
    if Debug == true
        figure;imshow(RawROI);hold on; plot(corners.p(:,1),corners.p(:,2),'*');hold off;
    end

end