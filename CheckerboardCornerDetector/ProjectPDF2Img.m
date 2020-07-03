function ProjPtsPerCorner = ProjectPDF2Img(Omega,GridCoords, LensRadius,LensIDList, ProjTresh) 
    
    PDCenter         = Omega(1:2);
    PDRadiusPixel    = abs(Omega(3)*LensRadius);    
    GridCoordsX      = GridCoords(:,:,1);
    GridCoordsY      = GridCoords(:,:,2);    
    center_list      = [GridCoordsX(:),GridCoordsY(:)]'; 
    if LensIDList == -1
        SelectLensCenter = center_list';
    else
        SelectLensCenter = center_list(:,LensIDList)';
    end
    
    if isempty(SelectLensCenter)
        ProjPtsPerCorner = [];
        return;
    end
    
    ProjPtsPerCorner = [];
    dist             = sqrt(sum( (PDCenter - SelectLensCenter).^2 , 2));
    LensID           = find(dist < abs(PDRadiusPixel));    
    LensNum          = size(LensID,1);
    if LensNum >0
        for i=1:LensNum 
            current_lense       = SelectLensCenter( LensID(i),: );
            offset              = ( 1/Omega(3) ).*(current_lense-PDCenter);  % 这里有问题，应该把半径约掉。
            offsetdist          = sqrt( sum( offset.^2 , 2 ) );
            if offsetdist <(LensRadius-ProjTresh)      % make sure the projection points is in the micro-image.
                ProjCornerCoords    = current_lense + offset;
                if LensIDList == -1
                    ProjCornerInfo      = [ProjCornerCoords, LensID(i)];
                else
                    ProjCornerInfo      = [ProjCornerCoords,LensIDList( LensID(i) )];
                end
                ProjPtsPerCorner    = [ProjPtsPerCorner;ProjCornerInfo]; 
            end
        end
    else
        ProjPtsPerCorner = [];  
    end
end