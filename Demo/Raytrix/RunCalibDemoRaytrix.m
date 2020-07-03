clc,clear

DataPath                 = 'E:\GitFlowSpace\Data\Calibration\Raytrix\RawProc'; 
ShowFlag                 = true;
NonLinearFlag            = true;
ParallelFlag             = false;
BoardCornerGap           = [15,15];
BoardCornerXYNum         = [14,19];  %  �궨��Ĺ��в��������ݺ��

% load the information about MLA.
load([DataPath,'\lensmodel'],'LensletGridModel', 'GridCoords');
load([DataPath,'\OurNewDetectResults'], 'allPts','allClearPts','allOmega');
OmegaCell                = ConvertOmegaFormat(allOmega);


%******���ùⳡԲ�������������������ѱ궨************************************
[param,FrameIdUsed]      = ZhangCalibration(OmegaCell ,BoardCornerGap, BoardCornerXYNum ,ShowFlag); % zhang zhengyou Calibration
[~,paramFinal]           = DepthCalibration( param,FrameIdUsed,allPts,OmegaCell,BoardCornerGap,BoardCornerXYNum,GridCoords,ShowFlag,NonLinearFlag,ParallelFlag);

paramFinal  = paramFinal(1:end-3);
save([DataPath,'\OurCalibResult.mat'], 'paramFinal','FrameIdUsed');


