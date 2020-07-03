function [InnerCornerID, CountInnerNum , ErrorMean] = RANSACCalculateInnerCorner( Corner_microImg_Coord, allPts_perCorner, Error_Inner)
    if isempty(Corner_microImg_Coord)
        InnerCornerID  = [];
        CountInnerNum  = 0;
        ErrorMean      = 10000;
        return;
    end
    LensUniqueID            = unique(Corner_microImg_Coord(:,3));   % �����������΢͸����š�
    InnerCornerID           = [];
    Error_CornerSum         = 0;
    CountInnerNum           = 0;
    MaxError                = 10000;
    for i=1:length(LensUniqueID)   % ����ÿһ��΢͸��
        CurrentLensID_Error = LensUniqueID(i);   % ����ÿ��΢͸����
        ProjCornerID        = find( Corner_microImg_Coord(:,3)==CurrentLensID_Error );   % ���ֵ�϶����ҵ�������ͶӰ��������ÿ��͸��ֻ��һ����
        ProjCornerCoord     = Corner_microImg_Coord( ProjCornerID,1:2 );            % ��ȡͶӰ�������
        RealCornerID        = find( allPts_perCorner(:,3)==CurrentLensID_Error );   % Ѱ����ʵ���������Ƿ��ж�Ӧ��΢͸����
        if isempty(RealCornerID)    
            continue;           % �����ǰ΢͸��û�м�⵽�ǵ㣬 ��������
        else
            % ����error ����¼��
            RealCorner              = allPts_perCorner( RealCornerID , 1:2 );  % ��ʵ���ݵ����꣬���ֵ���ܴ��ڶ����
            Error_Corner            = sqrt( sum ( ( ProjCornerCoord - RealCorner).^2,2 ) );
            InnerCornerIDtem        = find( Error_Corner < Error_Inner);   % �ҵ��ڲ��㡣���ڲ�����ж���Ҫ���ԭ�򣬲��ܷŵ�̫��
            if ~isempty(InnerCornerIDtem)              
                InnerCornerIDSingle     = find( Error_Corner==min(Error_Corner)); % �ҵ���ǰ΢͸���ھ���ͶӰ������ĵ���Ϊ�ڵ㡣
                InnerCornerIDinArray    = RealCornerID(InnerCornerIDSingle );
                InnerCornerID           = [InnerCornerID ; InnerCornerIDinArray]; % �ҵ���Ϊ�ڵ�ĵ㡣
                Error_Corner            = Error_Corner(InnerCornerIDSingle );         % ѡȡ�ڲ������
                Error_CornerSum         = Error_CornerSum + sum(Error_Corner);  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%�����д��󡣾���ά�����⡣
                CountInnerNum           = CountInnerNum + length(InnerCornerIDSingle );
            end
        end
    end
    if CountInnerNum<=2  % ���ֻ�е�ǰ������ο��㣨2���㣩���������� �������ֱ����������ֹ������Ӱ�졣
        ErrorMean   = MaxError;
    else
        ErrorMean   = Error_CornerSum/CountInnerNum;
    end
    
end