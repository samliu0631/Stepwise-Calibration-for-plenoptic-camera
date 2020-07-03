function Mask = CalculateMask(SingleCornerCoords, SingleLensCenterCoords, PatchSize,ValidRadius)
    Mask               = zeros(PatchSize);
    PatchRadius        = (PatchSize-1)/2;  
    X                  = -PatchRadius : 1 : PatchRadius;
    Y                  = -PatchRadius : 1 : PatchRadius;
    [XX,YY]            = meshgrid(X,Y);
    InterpXX           = SingleCornerCoords(1)+XX; % 横坐标
    InterpYY           = SingleCornerCoords(2)+YY; % 纵坐标
    PatchCoords        = [InterpXX(:),InterpYY(:)];  
    
    Dist               = sqrt( sum( ( PatchCoords - SingleLensCenterCoords).^2 , 2 ) );  % 内点距离微透镜中心距离。
    ValidID            = Dist < ValidRadius;
    Mask(ValidID)      = 1;
end