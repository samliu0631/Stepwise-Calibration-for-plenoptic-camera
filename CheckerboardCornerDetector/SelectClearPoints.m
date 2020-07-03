function [allPts_perCorner,ClearPts_perCorner,ClearType] = SelectClearPoints(ValidCornerScores,  allPts_perCorner, CellRGBLensID)
    ClearType           = 0;
    CornerNum           = size(allPts_perCorner,1); % �������Ľǵ����
    MaxScore            = 0;
    if CornerNum >0
        allPts_perCorner    = [allPts_perCorner , ValidCornerScores];  % ����ǵ�������̶ȵ÷֡�            
        ClearityFlag        = zeros(CornerNum,1);
        for j=1:3
            CellRGBLensIDj   = CellRGBLensID{j};
            [LensIDRj,ia,~]  = intersect( double(allPts_perCorner(:,3)) , CellRGBLensIDj'  );
            if ~isempty( LensIDRj)  % ����ǿ�
                CurrentScore = mean(allPts_perCorner(ia,4));
                if CurrentScore >MaxScore
                    MaxScore = CurrentScore;
                    ClearTypeindex  =ia;
                    ClearType       = j;
                end
            end
        end
        if ~isempty(ClearTypeindex)  % ����ǿ�
            ClearityFlag(ClearTypeindex)=1;
        end
        allPts_perCorner =[allPts_perCorner,ClearityFlag];
        ClearPts_perCorner = allPts_perCorner( allPts_perCorner(:,end)>0,:);  % ���MicroPointsPerCorner�ǿգ����ܽ����������ɸѡ��
    
    else
        allPts_perCorner        = [];
        ClearPts_perCorner      = [];        
    end
   
end