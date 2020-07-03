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
    CornerNumCurrent            = size(allPts_perCorner,1);     % ��ǰ�������������������
    LensUniqueID                = unique(allPts_perCorner(:,3));   % �����������΢͸����š� 
    BreakFlag                   = false;
    for i = 1:CornerNumCurrent-1   % iterate through all corners.
        if  BreakFlag == true
            break;
        end
        for j= i+1:CornerNumCurrent
            % �����ж��������ж��Ƿ��ǹ涨΢͸�����͡�
            if ~ismember(allPts_perCorner(i,3),LensUniqueID)
                continue;
            end
            if ~ismember(allPts_perCorner(j,3),LensUniqueID)
                continue;
            end
            LensIDRef                       = allPts_perCorner(i,3);    % ��ȡ�ο��������
            CornerRefCoord                  = allPts_perCorner(i,1:2);
            LensRefCenterCoord              = [ center_list( 1, LensIDRef )',center_list( 2, LensIDRef )' ];
            LensIDComp                      = allPts_perCorner(j,3);    % ��ȡ���յ������
            CornerCompCoord                 = allPts_perCorner(j,1:2);
            LensCompCenterCoord             = [ center_list( 1, LensIDComp )',center_list( 2, LensIDComp )' ];
            if LensIDRef ~= LensIDComp  % �������ͬһ��΢͸��
                EpipolarVector              = LensCompCenterCoord- LensRefCenterCoord;
                Distance_Center             = sqrt( sum( EpipolarVector.^2, 2 ) );
                EpipolarUnitVector          = EpipolarVector./Distance_Center;
                CornerVector                = CornerCompCoord - CornerRefCoord;
                Dist_CornerEpipolar         = sqrt( sum( ( cross( [EpipolarUnitVector,0]  ,[CornerVector,0]) ).^2) );
                if Dist_CornerEpipolar< EpipolarDist   % Ҫ�ҵ��ڶԼ��߷�Χ�ڵĵ������м��㡣
                    Disparity                   = CornerVector*EpipolarUnitVector';       % �������������������ȵ�ʱ��Ҫ���ǵ��Լ��ߡ�������Ҫ�޸���һ�¡�
                    Virtual_raw                 = Disparity/Distance_Center;
                    VirtualDepth                = 1/(1-Virtual_raw);               % ��������ȡ�
                    if (VirtualDepth>=2)&&(VirtualDepth<20)  % �����������һ�����·�Χ����ֹ��Ч���㡣
                        Corner3DCoord               = LensRefCenterCoord+( CornerRefCoord - LensRefCenterCoord )*VirtualDepth; % ����ռ�3d������
                        Corner_microImg_Coord       = ReProjectCorner2InnerLens(Corner3DCoord, VirtualDepth, LensRadius, LensUniqueID ,center_list); % ���ռ�3d��ͶӰ��ԭʼͼ
                        [InnerCornerID, CountInnerNum , ErrorMean] = RANSACCalculateInnerCorner( Corner_microImg_Coord, allPts_perCorner, Error_Inner); % ����ͶӰ���ʵ��㣬�����ڵ㡣
                        
                        if CountInnerNum > MaxInnerNum || (CountInnerNum==MaxInnerNum)&&( ErrorMean < MinError) % ������ڵ����е����ݽ��м�¼��
                            MaxInnerNum                     = CountInnerNum;
                            MinError                        = ErrorMean;
                            MaxInnerCornerID                = InnerCornerID;  % �ҵ�����ڵ����С�
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
