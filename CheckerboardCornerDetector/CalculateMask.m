function Mask = CalculateMask(SingleCornerCoords, SingleLensCenterCoords, PatchSize,ValidRadius)
    Mask               = zeros(PatchSize);
    PatchRadius        = (PatchSize-1)/2;  
    X                  = -PatchRadius : 1 : PatchRadius;
    Y                  = -PatchRadius : 1 : PatchRadius;
    [XX,YY]            = meshgrid(X,Y);
    InterpXX           = SingleCornerCoords(1)+XX; % ������
    InterpYY           = SingleCornerCoords(2)+YY; % ������
    PatchCoords        = [InterpXX(:),InterpYY(:)];  
    
    Dist               = sqrt( sum( ( PatchCoords - SingleLensCenterCoords).^2 , 2 ) );  % �ڵ����΢͸�����ľ��롣
    ValidID            = Dist < ValidRadius;
    Mask(ValidID)      = 1;
end