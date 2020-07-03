function ImgOut = FormCenterAperture(CurImg_raw,GridCoords)
    GridCoordsX                 = GridCoords(:,:,1);
    GridCoordsY                 = GridCoords(:,:,2);
    GridX                       = GridCoordsX(:);
    GridY                       = GridCoordsY(:);
    Microlens_list              = [GridX,GridY];
    center_list                 = Microlens_list';
    CenterImageSize             = size(GridCoordsX);
    CenterImageSize             = [CenterImageSize(2),CenterImageSize(1)];
    b                   = size(CurImg_raw,3);                                  % 判断图像的通道数。
    sizeraw             = size(CurImg_raw);
    img_center          = zeros(CenterImageSize(2),CenterImageSize(1),b);   % 对中心图像赋初值。
    for k=1:b
        centerImgX      = round(center_list(1,:))';
        centerImgY      = round(center_list(2,:))';
        centerImgX( find(centerImgX>sizeraw(2)) )  =  sizeraw(2);           % 对超过图像范围的微透镜中心位置进行赋值 ，因为只提取微透镜中心位置。
        centerImgY( find(centerImgY>sizeraw(1)) )  =  sizeraw(1);
        LensID  = (centerImgX-1).*sizeraw(1) +centerImgY;
        tem     = CurImg_raw(LensID);
        img_center(:,:,k)=reshape(tem ,CenterImageSize(2),CenterImageSize(1));
    end
    %***对中心图像进行上采样，减少透镜六边形排布的影响*******************
   
    CenterImgSize       = size(img_center);
    % 首先判断 第一行和第二行那个靠前。    
    if GridCoordsX(1,1)< GridCoordsX(2,1)
        OddInterIndex       = [1    :  0.5   :  CenterImgSize(2)+0.5]';
        EvenInterIndex      = [0.5  :  0.5   :  CenterImgSize(2)]';
    else
        OddInterIndex       = [0.5  :  0.5   :  CenterImgSize(2)]';
        EvenInterIndex      = [1    :  0.5   :  CenterImgSize(2)+0.5]';
    end
    VertialInterIndex       = [1:0.5:CenterImgSize(1)+0.5]';
    
    % 对奇数行进行插值。
    CenterImg_odd           = img_center(1:2:end,:);
    CenterImg_oddnew        = zeros(size(CenterImg_odd,1),2*CenterImgSize(2));  % 横向插值两倍。
    for i   = 1:CenterImgSize(1)/2
        interPixel = interp1(double([1:CenterImgSize(2)]'), double(CenterImg_odd (i,:)' ), double(OddInterIndex) ,'linear');
        CenterImg_oddnew(i,:) =interPixel';
    end
    %figure; imshow(CenterImg_oddnew);    
    
    % 对偶数行进行插值
    CenterImg_even          = img_center(2:2:end,:);    
    CenterImg_evennew       = zeros(size(CenterImg_even,1) ,2*CenterImgSize(2));
    for i  = 1:CenterImgSize(1)/2
        interPixel = interp1(double([1:CenterImgSize(2)]'), double(CenterImg_even (i,:)' ), double(EvenInterIndex),'linear' );
        CenterImg_evennew(i,:) =interPixel';
    end
    %figure; imshow(CenterImg_evennew);
    
    % 奇偶图像拼合
    CenterImgNew = zeros( CenterImgSize(1),2*CenterImgSize(2) );
    CenterImgNew(1:2:end,:)=    CenterImg_oddnew;
    CenterImgNew(2:2:end,:)=    CenterImg_evennew;
    %figure; imshow(CenterImgNew);
    
    % 对纵向进行插值
    CenterImg_Final= zeros( 2*CenterImgSize(1),2*CenterImgSize(2) );
   for i=1:2*CenterImgSize(2)  % 偶数行
        interPixel = interp1(double([1:CenterImgSize(1)]'), double(CenterImgNew (:,i) ), double(VertialInterIndex),'linear' );
        CenterImg_Final(:,i) =interPixel;
   end
    %figure; imshow(CenterImg_Final);
   
    CenterImg_Final( isnan(CenterImg_Final) ) =0;
    % Low-pass filter the image
    
    G                       = fspecial('gaussian',3,3);
    ImgOut                  = imfilter(CenterImg_Final, G, 'conv');
    %ImgOut = CenterImg_Final;
    maxvalue                = max(max(ImgOut));
    minvalue                = min(min(ImgOut));
    ImgOut                  = (ImgOut-minvalue)./(maxvalue-minvalue);

end