% Function : Detect checkerboard corners within light field raw image.
function  [allPts,allClearPts,allOmega]     = DetectCornersOurs(GridCoords,LensletGridModel,ConfigBag,varargin)
    MaxPDRadius = 100;
    if nargin == 4
        Debug = varargin{1};
    else
        Debug =  false;
    end
    MinMeanResponse                 = 0.025;  % 这个阈值要调整一下
    DetectTresh                     = 0.02;
    Filtersize                      = 7; 

    LensRadius                      = LensletGridModel.HSpacing/2;
    CellRGBLensID                   = ExtractRGBLensID(GridCoords,LensletGridModel); 
    [FileList_raw, BasePath_raw]    = ReadRawImgInfo(ConfigBag.FilePath_Raw, ConfigBag.DefaultFileSpec_Raw);    % Get image numbers and names from image lists.
    ImageNum                        = length(FileList_raw);   % Get the number of image number.                                
    allPts                          = cell(ImageNum,1);
    allClearPts                     = cell(ImageNum,1);    
    allOmega                        = cell(ImageNum,1);    
    templateCell                    = CreateTemplate(ConfigBag.FilterRadius);
    for id = 1:ImageNum  
        %tic;
        Img_raw_nonfilter           = ReadRawImg(BasePath_raw,FileList_raw, id);  % Read the raw light field image.  
        [Img_raw,Img_raw2]          = ImagePreprocess(Img_raw_nonfilter,Filtersize ,ConfigBag.delta,ConfigBag.Optdelta);                
        ImgCenter                   = FormCenterAperture(Img_raw,GridCoords);     % form central aperture.        
        cornerCenter                = DetectCornersOnCentralAperture(ImgCenter,ConfigBag);  % extract corners roughly on sub image.        
        LensIDnearCorner            = GetLensIDnearCorners(cornerCenter,ConfigBag.neighbrs,GridCoords,LensletGridModel); % get the lenses which are neighbor of each corner.       
        CornerNumCurrentFrame       = size(LensIDnearCorner,1);
        CellCornerInfoPerFrame      = cell(CornerNumCurrentFrame,1);                   
        CellClearCornerInfoPerFrame = cell(CornerNumCurrentFrame,1);
        CellOmegaPerFrame           = cell(CornerNumCurrentFrame,1);
        for corn_id                 = 1:CornerNumCurrentFrame   %%%%%%%%%%% for each corner       
            % detect corner set.
            CurrentLensIDnearCorner    = LensIDnearCorner(corn_id,:);
            [corners1,corners2,RawROI] = DetectCorner(CurrentLensIDnearCorner, Img_raw, LensRadius, GridCoords,LensletGridModel , templateCell, ConfigBag, DetectTresh, Debug);
            % choose corner set.
            [corners,CornerType]       = ChooseCornerSet(corners1,corners2,GridCoords,  LensRadius,   ConfigBag,MinMeanResponse,Debug,RawROI);
            % validate corners
            if CornerType==0||mean(corners.response) < MinMeanResponse || isempty(corners.response) % if there is no corners left or only corners left with low quality.
                continue;
            end
            if size(corners.p,1) ==1
                CellCornerInfoPerFrame{corn_id}             = [corners.pImg,corners.LensID];
                CellClearCornerInfoPerFrame{corn_id}        = [corners.pImg,corners.LensID];
                CellOmegaPerFrame{corn_id}                  = [];
                continue;
            end
            % optimize corners.
            [Omega,ClearType,ClearPts_perCorner]       = OptimizeCorner(corners,CellRGBLensID,Img_raw2,Img_raw,GridCoords,LensRadius,ConfigBag,templateCell,CornerType,Debug);
            % Corners Reprojection.
            if ClearType == 0 && strcmp(ConfigBag.CameraType,'Raytrix')
                continue;
            end
            
            if isempty(Omega)    % remove obvious error detection
               continue;
            else               
                if abs(Omega(3)) >= MaxPDRadius
                    continue;
                end
            end         
            
            ProjPtsPerCorner         = ProjectPDF2Img(Omega, GridCoords, LensRadius, -1,ConfigBag.ProjTresh);
            if Debug == true
                figure;imshow(Img_raw);hold on; plot(ProjPtsPerCorner(:,1),ProjPtsPerCorner(:,2),'*');hold off;
            end
            % save results
            CellCornerInfoPerFrame{corn_id}             = ProjPtsPerCorner;
            CellClearCornerInfoPerFrame{corn_id}        = ClearPts_perCorner;
            CellOmegaPerFrame{corn_id}                  = Omega;
        end
        allPts{id}          = CellCornerInfoPerFrame;
        allClearPts{id}     = CellClearCornerInfoPerFrame;
        allOmega{id}        = CellOmegaPerFrame;
        %toc;
        ShowResultofSingleFrame(Img_raw,CellCornerInfoPerFrame);
    end    
end




















