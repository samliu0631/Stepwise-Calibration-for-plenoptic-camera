clc,clear
DataPath                          = 'E:\GitFlowSpace\Data\Calibration\Raytrix\RawProc'; 
FilePath_White                    = 'E:\GitFlowSpace\Data\Calibration\Raytrix\XML'; 
DefaultFileSpec_Raw               = {'*.png'};
ConfigBag.neighbrs                = 35;     % ROI range 
ConfigBag.SearchThreshold         = 5;      % remove corenrs located on the edges of micro-images
ConfigBag.Error_Inner             = 1.5;    % the 
ConfigBag.ProjTresh               = 2;      % remove project points  on the edges of microimage.
ConfigBag.delta                   = 0.5;%1;      % Gaussian filter delta.
ConfigBag.Optdelta                = 0.5;
ConfigBag.FilterRadius            = [2,4];
ConfigBag.OptThresh               = 5;
ShowFlag                          = false;
pixelX                            = 6576;
pixelY                            = 4384;
InfoBag.FlagRemoveEdge            = false;
% load the information about MLA.
[LensletGridModel, GridCoords] = FuncGenerateMLA([pixelY,pixelX], FilePath_White ,ShowFlag,InfoBag);
save([DataPath,'\lensmodel'],'LensletGridModel', 'GridCoords');


% Detect corners.
ConfigBag.FilePath_Raw            = DataPath;
ConfigBag.DefaultFileSpec_Raw     = DefaultFileSpec_Raw ;
[allPts,allClearPts,allOmega ]    = DetectCornersOurs(GridCoords,LensletGridModel,ConfigBag);

% Save the results.
save([DataPath,'/OurNewDetectResults'], 'allPts','allClearPts','allOmega');

% Show the detect results.
load([DataPath,'/OurNewDetectResults'], 'allPts','allClearPts');
ShowDetectResults(DataPath, DefaultFileSpec_Raw,allClearPts);



