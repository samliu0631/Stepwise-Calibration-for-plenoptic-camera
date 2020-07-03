function  StdCorners  = CalulatePatchSimularity(CurImg_raw,LensRadius ,PatchSize ,ResultCorner_microImg_Coord ,center_list,SearchThreshold ) % SAD���ƽ������BֵӰ��ܴ�  

    LensAbsID               = ResultCorner_microImg_Coord(:,3);                             % ΢͸���ľ���ID
    LensCenterCoords        = [center_list(1,LensAbsID)',center_list(2,LensAbsID)'];        % ΢͸����������
    InnerCornerCoords       = ResultCorner_microImg_Coord(:,1:2);                           % ���������ڵ����ꡣ
  
    PatchNum                = size(InnerCornerCoords,1); 
    if PatchNum < 2
       sprintf('There are not enough patches. Simularity is set to 0.\n'); 
       StdCorners = 0;
       return;
    end
    PatchList               = zeros(PatchSize,PatchSize,PatchNum);
    MaskList                = zeros(PatchSize,PatchSize,PatchNum);
    ValidRadius             = LensRadius-SearchThreshold;
    for i = 1 : PatchNum        
        PatchList(:,:,i) = ExtractPatchFromRaw(CurImg_raw,InnerCornerCoords(i,:),PatchSize);      
        MaskList(:,:,i)  = CalculateMask(InnerCornerCoords(i,:), LensCenterCoords(i,:), PatchSize,ValidRadius);
    end
    PatchListValid = PatchList.*MaskList;
 
    PatchMean     = sum(PatchListValid,3)./sum(MaskList,3);
    MinusValue    = PatchListValid-PatchMean.*MaskList;
    
    
    StdPatch      = sqrt( sum(MinusValue.^2,3)./sum(MaskList,3) );
    
    
    StdCorners    = sum(sum(StdPatch))/( PatchSize^2 );
end






