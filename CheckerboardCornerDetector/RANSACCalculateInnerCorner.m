function [InnerCornerID, CountInnerNum , ErrorMean] = RANSACCalculateInnerCorner( Corner_microImg_Coord, allPts_perCorner, Error_Inner)
    if isempty(Corner_microImg_Coord)
        InnerCornerID  = [];
        CountInnerNum  = 0;
        ErrorMean      = 10000;
        return;
    end
    LensUniqueID            = unique(Corner_microImg_Coord(:,3));   % 检测出特征点的微透镜编号。
    InnerCornerID           = [];
    Error_CornerSum         = 0;
    CountInnerNum           = 0;
    MaxError                = 10000;
    for i=1:length(LensUniqueID)   % 对于每一个微透镜
        CurrentLensID_Error = LensUniqueID(i);   % 遍历每个微透镜。
        ProjCornerID        = find( Corner_microImg_Coord(:,3)==CurrentLensID_Error );   % 这个值肯定能找到。并且投影的特征点每个透镜只有一个。
        ProjCornerCoord     = Corner_microImg_Coord( ProjCornerID,1:2 );            % 提取投影点的坐标
        RealCornerID        = find( allPts_perCorner(:,3)==CurrentLensID_Error );   % 寻找真实点数据中是否有对应的微透镜。
        if isempty(RealCornerID)    
            continue;           % 如果当前微透镜没有检测到角点， 则跳过。
        else
            % 计算error 并记录。
            RealCorner              = allPts_perCorner( RealCornerID , 1:2 );  % 真实数据点坐标，这个值可能存在多个。
            Error_Corner            = sqrt( sum ( ( ProjCornerCoord - RealCorner).^2,2 ) );
            InnerCornerIDtem        = find( Error_Corner < Error_Inner);   % 找到内部点。在内部点的判断上要坚持原则，不能放的太宽。
            if ~isempty(InnerCornerIDtem)              
                InnerCornerIDSingle     = find( Error_Corner==min(Error_Corner)); % 找到当前微透镜内距离投影点最近的点作为内点。
                InnerCornerIDinArray    = RealCornerID(InnerCornerIDSingle );
                InnerCornerID           = [InnerCornerID ; InnerCornerIDinArray]; % 找到作为内点的点。
                Error_Corner            = Error_Corner(InnerCornerIDSingle );         % 选取内部点的误差。
                Error_CornerSum         = Error_CornerSum + sum(Error_Corner);  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%这里有错误。矩阵维度问题。
                CountInnerNum           = CountInnerNum + length(InnerCornerIDSingle );
            end
        end
    end
    if CountInnerNum<=2  % 如果只有当前的自身参考点（2个点）符合条件。 这种情况直接抛弃。防止噪声的影响。
        ErrorMean   = MaxError;
    else
        ErrorMean   = Error_CornerSum/CountInnerNum;
    end
    
end