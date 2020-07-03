function PatchInterp = ExtractPatchFromRaw(CurImg_rawGray,PointRawCoords,PatchSize)
    PatchRadius        = (PatchSize-1)/2;  
    X2                  = -PatchRadius-2 : 1 : PatchRadius+2;
    Y2                  = -PatchRadius-2 : 1 : PatchRadius+2;
    [XX2,YY2]            = meshgrid(X2,Y2);   
    OriginXX           = round(PointRawCoords(1))+XX2;
    OriginYY           = round(PointRawCoords(2))+YY2;
    PatchOrgin         = CurImg_rawGray(  Y2+round(PointRawCoords(2)) ,X2+round(PointRawCoords(1)) );
    X                  = -PatchRadius : 1 : PatchRadius;
    Y                  = -PatchRadius : 1 : PatchRadius;
    [XX,YY]            = meshgrid(X,Y);
    InterpXX           = PointRawCoords(1)+XX; % ºá×ø±ê
    InterpYY           = PointRawCoords(2)+YY; % ×Ý×ø±ê
    PatchInterp        = interp2(OriginXX,OriginYY,PatchOrgin,InterpXX,InterpYY,'linear');

end