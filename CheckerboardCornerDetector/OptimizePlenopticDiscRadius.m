function PDRadius = OptimizePlenopticDiscRadius(Img_raw, Omiga, GridCoords,LensRadius,LensIDList,SearchThreshold)

    InitRadiusPix           = abs(Omiga(3)*LensRadius);  
    
    % Coarse optimization.
    OptStep                 = 2;
    RadiusRange             = OptStep*[-3:3];                 
    RadiusSearchRangePix    = InitRadiusPix+RadiusRange;       
    BestRadisPix            = SearchBestRadius(RadiusSearchRangePix,Img_raw,Omiga,GridCoords, LensRadius, LensIDList,SearchThreshold);
    
    % accurate optimization
    AccurateOptStep         = 0.4; 
    AccurateRadiusRange     = AccurateOptStep*[-5:5];
    AcRadiusSearchRangePix  = BestRadisPix+AccurateRadiusRange;
    BestRadisPix            = SearchBestRadius(AcRadiusSearchRangePix,Img_raw,Omiga,GridCoords, LensRadius, LensIDList,SearchThreshold);

    PDRadius                = BestRadisPix/LensRadius;  % 记录优化后的深度值。
    if Omiga(3)<0
         PDRadius= -PDRadius;
    end
end
