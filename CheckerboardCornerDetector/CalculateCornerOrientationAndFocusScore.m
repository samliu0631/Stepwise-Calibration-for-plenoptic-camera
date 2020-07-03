function [corners,ImgBag] = CalculateCornerOrientationAndFocusScore(img,corners,varargin)
    if nargin>2
        CameraType =varargin{1};
    else
        CameraType = 'Raytrix';
    end
    % sobel masks
    du = [-1 0 1; -1 0 1; -1 0 1];
    dv = du';    
    if strcmp(CameraType,'Raytrix')
        r  = 10;
    else
        r  = 4;
    end
    % compute image derivatives (for principal axes estimation)
    img_du     = conv2(double(img),du,'same');
    img_dv     = conv2(double(img),dv,'same');
    img_angle  = atan2(img_dv,img_du);        % the direction of the gradient.
    img_weight = sqrt(img_du.^2+img_dv.^2);   % the value of gradient.

    % correct angle to lie in between [0,pi]
    img_angle(img_angle<0)  = img_angle(img_angle<0)+pi;
    img_angle(img_angle>pi) = img_angle(img_angle>pi)-pi;
    
    width  = size(img_du,2);
    height = size(img_dv,1);

    % init orientations to invalid (corner is invalid iff orientation=0)
    corners.v1 = zeros(size(corners.p,1),2);
    corners.v2 = zeros(size(corners.p,1),2);

    % for all corners do
    for i=1:size(corners.p,1)

      % extract current corner location
      cu = corners.p(i,1);
      cv = corners.p(i,2);

      % estimate edge orientations
      img_angle_sub  = img_angle(max(cv-r,1):min(cv+r,height),max(cu-r,1):min(cu+r,width));
      img_weight_sub = img_weight(max(cv-r,1):min(cv+r,height),max(cu-r,1):min(cu+r,width));
      [v1,v2] = edgeOrientations(img_angle_sub,img_weight_sub);
      corners.v1(i,:) = v1;
      corners.v2(i,:) = v2;
    end  
    
    % Calculate Gradient Score.
    DetectedNum     = size(corners.p,1);
    if strcmp(CameraType,'Raytrix') 
        rScore          = 2;
    else
        rScore          = 1;
    end
    FocusScore      = zeros(DetectedNum,1);
    for i=1 :DetectedNum
        cu              = round(corners.p(i,1));
        cv              = round(corners.p(i,2));
        img_weight_sub  = img_weight(max(cv-rScore,1):min(cv+rScore,height),max(cu-rScore,1):min(cu+rScore,width));
        FocusScore(i)   = mean2(img_weight_sub);
    end
    corners.FocusScore  = FocusScore;
    
    % Calculate Corner Score.
    %corners = scoreCorners(img,img_angle,img_weight,corners,8);
    corners.score =  corners.response.*corners.FocusScore;
    
    ImgBag.img_du =img_du;
    ImgBag.img_dv =img_dv;
    ImgBag.img_angle =img_angle;
    ImgBag.img_weight =img_weight;
    
end