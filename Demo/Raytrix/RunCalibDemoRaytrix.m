clc,clear

DataPath                 = 'E:\GitFlowSpace\Data\Calibration\Raytrix\RawProc'; 
ShowFlag                 = true;
NonLinearFlag            = true;
ParallelFlag             = false;
BoardCornerGap           = [15,15];
BoardCornerXYNum         = [14,19];  %  标定板的固有参数。先纵后横

% load the information about MLA.
load([DataPath,'\lensmodel'],'LensletGridModel', 'GridCoords');
load([DataPath,'\OurNewDetectResults'], 'allPts','allClearPts','allOmega');
OmegaCell                = ConvertOmegaFormat(allOmega);


%******利用光场圆域中心特征进行张正友标定************************************
[param,FrameIdUsed]      = ZhangCalibration(OmegaCell ,BoardCornerGap, BoardCornerXYNum ,ShowFlag); % zhang zhengyou Calibration
[~,paramFinal]           = DepthCalibration( param,FrameIdUsed,allPts,OmegaCell,BoardCornerGap,BoardCornerXYNum,GridCoords,ShowFlag,NonLinearFlag,ParallelFlag);

paramFinal  = paramFinal(1:end-3);
save([DataPath,'\OurCalibResult.mat'], 'paramFinal','FrameIdUsed');


