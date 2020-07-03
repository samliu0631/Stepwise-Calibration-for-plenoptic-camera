function [corners,MaxSetOrient] = RemoveCornerbyRANSACPDF( corners,GridCoords,  LensRadius,   Error_Inner, MinMeanResponse, Method)
    % if there is only two corners. the corner orientation is the dominent
    % factor.
    MaxOrienConsist             = 0.6; % 0.3
    V1                          = corners.v1;
    V2                          = corners.v2;
    response                    = corners.response;    
    allPts_perCorner            = [corners.pImg,corners.LensID];    
    RANSACEvaluteMethod         =  Method;%'score';
    EpipolarDist                = 3 ; % should relatively large.
    GridCoordsX                 = GridCoords(:,:,1);
    GridCoordsY                 = GridCoords(:,:,2);
    center_list                 = [GridCoordsX(:),GridCoordsY(:)]';  
    MaxInnerNum                 = 0;
    MaxInnerCornerID            = [];
    MinError                    = 10000;
    MaxSetScore                 = -1000;
    MaxSetOrient                = 1000;
    CornerNumCurrent            = size(allPts_perCorner,1);     % 当前检测出的特征点的总数。    
    if isempty(allPts_perCorner)
        return;
    end
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
                    % 计算 pdf
                    CurrentPts = [allPts_perCorner(i,:);allPts_perCorner(j,:)];
                    Omega      = CalculatePlenopticDiscFeatureLSM(CurrentPts,GridCoords );                    
                    if ( abs(Omega(3)) >= 2 ) && ( abs(Omega(3))<20 )  %  给虚深度设置一个大致范围，防止无效计算。
                        Corner_microImg_Coord       = ProjectPDF2Img(Omega, GridCoords, LensRadius,LensUniqueID ,0);
                        [InnerCornerID, CountInnerNum , ErrorMean] = RANSACCalculateInnerCorner( Corner_microImg_Coord, allPts_perCorner, Error_Inner); % 根据投影点和实测点，计算内点。                                                                      
                        if strcmp(RANSACEvaluteMethod,'score')
                            v1_currentset               = V1(InnerCornerID,:);
                            v2_currentset               = V2(InnerCornerID,:);
                            response_currentset            = response(InnerCornerID,:);
                            [ScoreSet,OrientScoreAve]   = CalculateCornerSetScore(v1_currentset,v2_currentset,response_currentset, CountInnerNum);
                            if ScoreSet > MaxSetScore
                                MaxInnerCornerID                = InnerCornerID;  % 找到最大内点序列
                                MaxSetScore                     = ScoreSet;
                                MaxSetOrient                    = OrientScoreAve;
                                if ( size(MaxInnerCornerID,1) > 0.7*CornerNumCurrent ) && (OrientScoreAve<MaxOrienConsist)
                                    BreakFlag = true;
                                    break;
                                end
                            end
                        else 
                            if strcmp(RANSACEvaluteMethod,'number')
                                if CountInnerNum > MaxInnerNum || (CountInnerNum==MaxInnerNum)&&( ErrorMean < MinError) % 对最大内点序列的数据进行记录。
                                    MaxInnerNum                     = CountInnerNum;
                                    MinError                        = ErrorMean;
                                    MaxInnerCornerID                = InnerCornerID;  % 找到最大内点序列。
                                    if ( size(MaxInnerCornerID,1) > 0.7*CornerNumCurrent ) 
                                        BreakFlag = true;
                                        break;
                                    end
                                end
                            end
                        end
                        
                        
                    end
                end
            end
        end
    end
    
    CornerNum            = size(MaxInnerCornerID,1);
    [~,OrientScoreAve]   = CalculateCornerSetScore(  V1(MaxInnerCornerID,:) ,  V2(MaxInnerCornerID,:) , response(MaxInnerCornerID,:), CornerNum);
    if CornerNum <= 2
        LowScore  = sum( corners.response(MaxInnerCornerID)< MinMeanResponse ) ; 
        if  LowScore==0 && OrientScoreAve < MaxOrienConsist
            corners = UpdateCorner(corners,MaxInnerCornerID);
            return;
        else
            MaxInnerCornerID = [];
            corners = UpdateCorner(corners,MaxInnerCornerID);
            return;
        end
    else
        MeanResponse  = mean( corners.response(MaxInnerCornerID)) ; 
        if MeanResponse < MinMeanResponse || OrientScoreAve > MaxOrienConsist
            corners = UpdateCorner(corners,[]);
        else
            corners = UpdateCorner(corners,MaxInnerCornerID);     
        end
          
    end


end



function [ScoreSet,OrientScoreAve] = CalculateCornerSetScore(v1_currentset,v2_currentset,score_currentset,CountInnerNum)

% 可能方向计算这里除了问题。
    v1             = v1_currentset;
    v2             = v2_currentset;    
    OrientScoreAve = CalculateOrientationConsistency(v1,v2);
    AverageScore   = mean(score_currentset);
    ScoreSet       = AverageScore*CountInnerNum*(1-OrientScoreAve);
end






