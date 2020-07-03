function [Param2stStep, paramFinal] = DepthCalibration(param1stStep,FrameIdUsed,allPts,OmigaCell,BoardCornerGap,BoardCornerXYNum,GridCoords,ShowFlag,NonLinearFlag, varargin)
%flag : 0 without final optimization. 1 with final optimization
% ShowFlag : true :show process. false : don't show process
% Select the plenoptic disc features of used frames.
if (nargin == 10)    % if there is another input parameters.
    ParallelFlag = varargin{1};
    NonLinearMethod = '2DCorner';
end
if (nargin == 11)    % if there is another input parameters.
    ParallelFlag = varargin{1};
    NonLinearMethod = varargin{2}; % 2DCorner or PDF
end

FrameNumUsed        = size(FrameIdUsed,1);
CornerNumOnBoard    = BoardCornerXYNum(1)*BoardCornerXYNum(2);
allPtsUsed          = cell(FrameNumUsed,1);
OmigaR              = zeros(FrameNumUsed*CornerNumOnBoard,1);
for i=1:FrameNumUsed
    CurrentFrameID      = FrameIdUsed(i);
    OmigaXYZ            = OmigaCell{CurrentFrameID};
    OmigaR((i-1)*CornerNumOnBoard+1:i*CornerNumOnBoard)  = OmigaXYZ(:,3);
    allPtsUsed{i}       = allPts{CurrentFrameID };
end
Rt_est           = param1stStep(7:end);

% estimate the value of K1,K2
[K1,K2]          = EstimateK1K2( BoardCornerXYNum,BoardCornerGap ,Rt_est,OmigaR );

TolFunThresh  = 1e-7;
MatIterNum    = 50;
% nonlinear optimization
if ShowFlag==true
    option           = optimset('Display','iter','TolFun',TolFunThresh,'TolX',TolFunThresh,'MaxFunEvals',100000,'MaxIter',MatIterNum,'Algorithm','levenberg-marquardt');%'PlotFcns', @optimplotfirstorderopt,
else
    if  ParallelFlag ==true
        option           = optimset('Display','off','TolFun',TolFunThresh,'TolX',TolFunThresh,'MaxFunEvals',100000,'MaxIter',MatIterNum,'Algorithm','levenberg-marquardt','UseParallel',true);
    else
        option           = optimset('Display','off','TolFun',TolFunThresh,'TolX',TolFunThresh,'MaxFunEvals',100000,'MaxIter',MatIterNum,'Algorithm','levenberg-marquardt');
    end
end
param_init       = double([K1, K2,0,0,0]);
fx_est = param1stStep(1);
fy_est = param1stStep(2);
cx_est = param1stStep(3);
cy_est = param1stStep(4);
k1_est = param1stStep(5);
k2_est = param1stStep(6);

ParamKnown       = double([fx_est,fy_est,cx_est,cy_est,k1_est ,k2_est ,Rt_est]);
paramOptimized   = lsqnonlin(@(x) K1K2PDFError( x , ParamKnown ,  OmigaCell ,BoardCornerGap, BoardCornerXYNum, FrameIdUsed ), param_init,[],[],option);
%paramOptimized   = lsqnonlin(@(x) RawImageProjectError( x ,allPtsUsed, ParamKnown, BoardCornerGap, BoardCornerXYNum  , GridCoords), param_init,[],[],option);
%showerror        = RawImageProjectError( paramOptimized ,allPtsUsed, ParamKnown, BoardCornerGap, BoardCornerXYNum  , GridCoords);

%paramOptimized    = param_init;
Param2stStep      = paramOptimized;

% nonlinear optimize for all parameters
if NonLinearFlag==true
    param_init3rdStep = [paramOptimized(1:2),param1stStep,paramOptimized(3:end)];
    switch NonLinearMethod
        case  '2DCorner'
            paramFinal        = lsqnonlin(@(x) RawImageProjectErrorAllParam( x ,allPtsUsed, BoardCornerGap, BoardCornerXYNum  , GridCoords), param_init3rdStep,[],[],option);
            %showerrorFinal    = RawImageProjectErrorAllParam( paramFinal ,allPtsUsed, BoardCornerGap, BoardCornerXYNum  , GridCoords);
        case 'PDF'
            paramFinal        = lsqnonlin(@(x)PDFErrorAllParam( x ,OmigaCell, BoardCornerGap, BoardCornerXYNum,FrameIdUsed), param_init3rdStep,[],[],option);
            %showerrorFinal    = RawImageProjectErrorAllParam( paramFinal ,allPtsUsed, BoardCornerGap, BoardCornerXYNum  , GridCoords);
%         case 'PDFRealSpace'
%             paramFinal        = lsqnonlin(@(x)PDFErrorAllParamRealSpace( x ,OmigaCell, BoardCornerGap, BoardCornerXYNum,FrameIdUsed), param_init3rdStep,[],[],option);
%             %showerrorFinal    = RawImageProjectErrorAllParam( paramFinal ,allPtsUsed, BoardCornerGap, BoardCornerXYNum  , GridCoords);
        otherwise
            fprintf('Error nonlinear optimaztion methods\n');
            paramFinal        = [paramOptimized(1:2),param1stStep,paramOptimized(3:end)];
    end
else
    paramFinal        = [paramOptimized(1:2),param1stStep,paramOptimized(3:end)];
end

if ShowFlag ==true
    disp('nonlinear optimization for all parameters');
    showerrorFinal    = RawImageProjectErrorAllParam( paramFinal ,allPtsUsed, BoardCornerGap, BoardCornerXYNum  , GridCoords);
    showMeanErrorFinal  = mean(  sqrt( sum(showerrorFinal.^2 ,2)))
end

end





















