clc,clear
WhitePath                       = 'E:\GitFlowSpace\Data\Calibration\Lytro\White';
DataPath                        = 'E:\GitFlowSpace\Data\Calibration\Lytro\Raw';
FileSpecWhite                   = '*.jpg';
DefaultFileSpec_Raw             = '*.jpg';
RoughRadius                     = 14;

%load([DataPath,'/lensmodel'], 'LensletGridModel', 'GridCoords');
[LensletGridModel,GridCoords]= GetMLAInfoByWhiteImg(WhitePath, FileSpecWhite,RoughRadius);
save([DataPath,'/lensmodel'], 'LensletGridModel', 'GridCoords');

% Detect corners
ConfigBag.neighbrs                = 35;     % ROI range 
ConfigBag.SearchThreshold         = 1.5;      % remove corenrs located on the edges of micro-images
ConfigBag.Error_Inner             = 1.5;    % the 
ConfigBag.ProjTresh               = 1.5;      % remove project points  on the edges of microimage.
ConfigBag.OptThresh               = 1.5;
ConfigBag.delta                   = 1.5;     % Gaussian filter delta.
ConfigBag.Optdelta                = 0.5;
ConfigBag.FilterRadius            = [1,3];   %%%%%%%%
ConfigBag.CameraType              = 'Lytro';
ConfigBag.FilePath_Raw            = DataPath;
ConfigBag.DefaultFileSpec_Raw     = DefaultFileSpec_Raw ;
ShowFlag                          = false;

[allPts,allClearPts,allOmega ]    = DetectCornersOurs(GridCoords,LensletGridModel,ConfigBag,0);
save([DataPath,'/OurNewDetectResults'], 'allPts','allClearPts','allOmega');

% Show the detect results.
%load([DataPath,'/OurNewDetectResults'], 'allPts','allClearPts');
%ShowDetectResults(DataPath, DefaultFileSpec_Raw,allPts,GridCoords);
ShowDetectResults(DataPath, DefaultFileSpec_Raw,allPts);
