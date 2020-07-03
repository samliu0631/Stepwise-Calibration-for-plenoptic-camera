function BestRadisPixValue = SearchBestRadius(RadiusSearchRangePix,Img_raw,Omiga,GridCoords, LensRadius, LensIDList,SearchThreshold)
    PatchSize           = floor(LensRadius/2);
    CurrentOmega        = Omiga;
    if  mod(PatchSize,2)==0
        PatchSize = PatchSize+1;
    end
    GridCoordsX         = GridCoords(:,:,1);
    GridCoordsY         = GridCoords(:,:,2);
    center_list         = [GridCoordsX(:),GridCoordsY(:)]';
    SearchTimes         = size(RadiusSearchRangePix,2);
    STDList             = zeros(SearchTimes,1);   
    MaxStd              = 100;
    %figure;imshow(Img_raw);hold on;%%%%%%%%%
    for SearchID = 1: SearchTimes
        CurrentRadiusPix         = RadiusSearchRangePix(SearchID); 
        if Omiga(3)>0
            CurrentOmega(3)             = CurrentRadiusPix/LensRadius;
        else
            CurrentOmega(3)             = -CurrentRadiusPix/LensRadius;
        end
        ProjPtsPerCorner         = ProjectPDF2Img(CurrentOmega, GridCoords, LensRadius, LensIDList,0);
       % plot(ProjPtsPerCorner(:,1),ProjPtsPerCorner(:,2),'*'); %%%%%%%%%%
        
        ProjNum                  = size(ProjPtsPerCorner,1);
        if ProjNum <=1
            STDList(SearchID)        = MaxStd; % if there is only one projected corner, remove the case.
        else
            StdCorners               = CalulatePatchSimularity(Img_raw,LensRadius ,PatchSize ,ProjPtsPerCorner ,center_list,SearchThreshold );
            STDList(SearchID)        = StdCorners;
        end

    end
    %hold off; %%%%%%%%%
    [STDListSort,SortID]  = sort(STDList);
    MinimamNum            = sum(STDListSort == STDListSort(1));  % the number of minimam.
    if MinimamNum > 1
        SelectedID =  round(MinimamNum/2);
    else
        SelectedID = 1;
    end
    BestRadisPixValue = RadiusSearchRangePix(SortID(SelectedID));
end
