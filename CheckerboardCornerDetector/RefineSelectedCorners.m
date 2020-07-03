function corners = RefineSelectedCorners(corners,ImgBag,GridCoords,LensRadius)
    img_du          = ImgBag.img_du ;
    img_dv          = ImgBag.img_dv;
    img_angle       = ImgBag.img_angle;
    img_weight      = ImgBag.img_weight;
    % subpixel refinement
    refineRadius    = 4;
    p_old           = corners.p;
    corners         = refineCorners(img_du,img_dv,corners,refineRadius,GridCoords,LensRadius); % 4 10 may be too large .
    offset          = corners.p-p_old;
    corners.pImg    = corners.pImg+offset; % update pImg.
    
    % make v1(:,1)+v1(:,2) positive (=> comparable to c++ code)
    idx = corners.v1(:,1)+corners.v1(:,2)<0;
    corners.v1(idx,:) = -corners.v1(idx,:);

    % make all coordinate systems right-handed (reduces matching ambiguities from 8 to 4)
    corners_n1 = [corners.v1(:,2) -corners.v1(:,1)];
    flip       = -sign(corners_n1(:,1).*corners.v2(:,1)+corners_n1(:,2).*corners.v2(:,2));
    corners.v2 = corners.v2.*(flip*ones(1,2));
end