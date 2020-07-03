function [corners,MaxSetOrient] = RemoveCornerbyRANSACwithCornerNumber( corners,GridCoords,  LensRadius,   Error_Inner, MinMeanResponse)
    % if there is only two corners. the corner orientation is the dominent
    % factor.  
    allPts_perCorner            = [corners.pImg,corners.LensID];    
    EpipolarDist                = 3 ; % should relatively large.
    GridCoordsX                 = GridCoords(:,:,1);
    GridCoordsY                 = GridCoords(:,:,2);
    center_list                 = [GridCoordsX(:),GridCoordsY(:)]';  
    MaxInnerNum                 = 0;
    MaxInnerCornerID            = [];
    MinError                    = 10000;
    MaxSetOrient                = 1000;
    CornerNumCurrent            = size(allPts_perCorner,1);     % 当前检测出的特征点的总数。
    LensUniqueID                = unique(allPts_perCorner(:,3));   % 检测出特征点的微透镜编号。 
    BreakFlag                   = false;
    for i = 1:CornerNumCurrent-1   % iterate through all corners.
        if  BreakFlag == true
            break;
        end
        for j= i+1:CornerNumCurrent
            % 加入判断条件，判断是否是规定微透镜类型。
            if ~ismember(allPts_perCorner(i,3),LensUniqueID)
                continue;
            end
            if ~ismember(allPts_perCorner(j,3),LensUniqueID)
                continue;
            end
            LensIDRef                       = allPts_perCorner(i,3);    % 提取参考点的数据
            CornerRefCoord                  = allPts_perCorner(i,1:2);
            LensRefCenterCoord              = [ center_list( 1, LensIDRef )',center_list( 2, LensIDRef )' ];
            LensIDComp                      = allPts_perCorner(j,3);    % 提取对照点的数据
            CornerCompCoord                 = allPts_perCorner(j,1:2);
            LensCompCenterCoord             = [ center_list( 1, LensIDComp )',center_list( 2, LensIDComp )' ];
            if LensIDRef ~= LensIDComp  % 如果不是同一个微透镜
                EpipolarVector              = LensCompCenterCoord- LensRefCenterCoord;
                Distance_Center             = sqrt( sum( EpipolarVector.^2, 2 ) );
                EpipolarUnitVector          = EpipolarVector./Distance_Center;
                CornerVector                = CornerCompCoord - CornerRefCoord;
                Dist_CornerEpipolar         = sqrt( sum( ( cross( [EpipolarUnitVector,0]  ,[CornerVector,0]) ).^2) );
                if Dist_CornerEpipolar< EpipolarDist   % 要找到在对极线范围内的点来进行计算。
                    Disparity                   = CornerVector*EpipolarUnitVector';       % 这里利用特征点计算深度的时候，要考虑到对极线。这里需要修改正一下。
                    Virtual_raw                 = Disparity/Distance_Center;
                    VirtualDepth                = 1/(1-Virtual_raw);               % 计算虚深度。
                    if (VirtualDepth>=2)&&(VirtualDepth<20)  % 给虚深度设置一个大致范围，防止无效计算。
                        Corner3DCoord               = LensRefCenterCoord+( CornerRefCoord - LensRefCenterCoord )*VirtualDepth; % 计算空间3d特征点
                        Corner_microImg_Coord       = ReProjectCorner2InnerLens(Corner3DCoord, VirtualDepth, LensRadius, LensUniqueID ,center_list); % 将空间3d点投影到原始图
                        [InnerCornerID, CountInnerNum , ErrorMean] = RANSACCalculateInnerCorner( Corner_microImg_Coord, allPts_perCorner, Error_Inner); % 根据投影点和实测点，计算内点。
                        
                        if CountInnerNum > MaxInnerNum || (CountInnerNum==MaxInnerNum)&&( ErrorMean < MinError) % 对最大内点序列的数据进行记录。
                            MaxInnerNum                     = CountInnerNum;
                            MinError                        = ErrorMean;
                            MaxInnerCornerID                = InnerCornerID;  % 找到最大内点序列。
%                             if ( size(MaxInnerCornerID,1) >= 0.7*CornerNumCurrent )
%                                 BreakFlag = true;
%                                 break;
%                             end
                        end
                    end
                end
            end
        end
    end
    
    CornerNum            = size(MaxInnerCornerID,1);
    if CornerNum <= 2
        LowScore  = sum( corners.response(MaxInnerCornerID)< MinMeanResponse ) ; 
        if  LowScore==0 
            corners = UpdateCorner(corners,MaxInnerCornerID);
            return;
        else
            MaxInnerCornerID = [];
            corners = UpdateCorner(corners,MaxInnerCornerID);
            return;
        end
    else
        MeanResponse  = mean( corners.response(MaxInnerCornerID)) ; 
        if MeanResponse < MinMeanResponse
            corners = UpdateCorner(corners,[]);
        else
            corners = UpdateCorner(corners,MaxInnerCornerID);     
        end
          
    end


end

function corners = UpdateCorner(corners,idx)
    corners.p           = corners.p(idx,:);
    corners.pImg        = corners.pImg(idx,:);
    corners.LensID      = corners.LensID(idx,:);
    corners.response    = corners.response(idx,:);
    corners.v1          = corners.v1(idx,:);
    corners.v2          = corners.v2(idx,:);
    corners.FocusScore  = corners.FocusScore(idx,:);
    corners.score       = corners.score(idx,:);
end
