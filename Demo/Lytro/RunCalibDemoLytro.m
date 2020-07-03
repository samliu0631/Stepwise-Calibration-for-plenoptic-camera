clc,clear

DataPath                 = 'E:\GitFlowSpace\Data\Calibration\Lytro\Raw';
ShowFlag                 = true;
NonLinearFlag            = true;
ParallelFlag             = false;
BoardCornerGap           = [8.9,8.9]; % ���ݺ��
BoardCornerXYNum         = [8,11];  %  �궨��Ĺ��в��������ݺ��

% load the information about MLA.
load([DataPath,'\lensmodel'],'LensletGridModel', 'GridCoords');
load([DataPath,'\OurNewDetectResults'], 'allPts','allClearPts','allOmega');
OmegaCell                = ConvertOmegaFormat(allOmega);


% OmegaCell           = OmegaCell([1:5]',1);
% allPts              = allPts([1:5]',1);

%******���ùⳡԲ�������������������ѱ궨************************************
[param,FrameIdUsed]      = ZhangCalibration(OmegaCell ,BoardCornerGap, BoardCornerXYNum ,ShowFlag); % zhang zhengyou Calibration
[~,paramFinal]           = DepthCalibration( param,FrameIdUsed,allPts,OmegaCell,BoardCornerGap,BoardCornerXYNum,GridCoords,ShowFlag,NonLinearFlag,ParallelFlag);

save([DataPath,'\OurCalibResult.mat'], 'paramFinal','FrameIdUsed');
