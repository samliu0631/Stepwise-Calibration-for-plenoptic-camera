function [allPts_perCorner,ClearPts_perCorner,ClearType] = SelectClearPoints(ValidCornerScores,  allPts_perCorner, CellRGBLensID)
    ClearType           = 0;
    CornerNum           = size(allPts_perCorner,1); % 检测出来的角点个数
    MaxScore            = 0;
    if CornerNum >0
        allPts_perCorner    = [allPts_perCorner , ValidCornerScores];  % 加入角点的清晰程度得分。            
        ClearityFlag        = zeros(CornerNum,1);
        for j=1:3
            CellRGBLensIDj   = CellRGBLensID{j};
            [LensIDRj,ia,~]  = intersect( double(allPts_perCorner(:,3)) , CellRGBLensIDj'  );
            if ~isempty( LensIDRj)  % 如果非空
                CurrentScore = mean(allPts_perCorner(ia,4));
                if CurrentScore >MaxScore
                    MaxScore = CurrentScore;
                    ClearTypeindex  =ia;
                    ClearType       = j;
                end
            end
        end
        if ~isempty(ClearTypeindex)  % 如果非空
            ClearityFlag(ClearTypeindex)=1;
        end
        allPts_perCorner =[allPts_perCorner,ClearityFlag];
        ClearPts_perCorner = allPts_perCorner( allPts_perCorner(:,end)>0,:);  % 如果MicroPointsPerCorner非空，才能进行清晰点的筛选。
    
    else
        allPts_perCorner        = [];
        ClearPts_perCorner      = [];        
    end
   
end