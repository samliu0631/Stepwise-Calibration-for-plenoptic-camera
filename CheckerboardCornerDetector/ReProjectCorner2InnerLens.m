function  Corner_microImg_Coord= ReProjectCorner2InnerLens(Corner3DCoord, vitualDepth, microImgRad, LensUniqueID ,center_list ) 
    Current_Corner_raw                      =  Corner3DCoord;
    Current_Corner_Depth                    =  vitualDepth;
    Lens_D                                  =  microImgRad*2;
    LensValuenum                            =  length(LensUniqueID);
    Corner_microImg_Coord                   = [];
    for m= 1: LensValuenum
        Lens_CoorX                          = center_list( 1 , LensUniqueID(m) );                                   % 微透镜中心X像素坐标。
        Lens_CoorY                          = center_list( 2 , LensUniqueID(m) );                                   % 微透镜中心Y像素坐标。
        Total_PointX                        = Current_Corner_raw(1)   ;                                             % 全聚焦点的原始图像素X横坐标。
        Total_PointY                        = Current_Corner_raw(2)   ;                                             % 全聚焦点的原始图像素Y坐标。
        Dx_lensCen2TotalPoint               = (Lens_CoorX-Total_PointX);                                            % 微透镜圆心相对于期棋盘中心x方向偏移
        Dy_lensCen2TotalPoint               = (Lens_CoorY-Total_PointY);                                            % 微透镜圆心相对于期棋盘中心y方向偏移
        Xpixel_Coord                        = Lens_CoorX -Dx_lensCen2TotalPoint/Current_Corner_Depth;
        Ypixel_Coord                        = Lens_CoorY -Dy_lensCen2TotalPoint/Current_Corner_Depth;
        R_UnderLens                         = sqrt( Dx_lensCen2TotalPoint^2+Dy_lensCen2TotalPoint^2 )/Current_Corner_Depth; %  表示微透镜图像中心到像素平面成像点的距离。
        if( R_UnderLens > (Lens_D/2-1) )    % 判断投影点是否投射出微透镜图像区域。
            continue;
        end
        Corner_microImg_Coord               = [ Corner_microImg_Coord; [Xpixel_Coord,Ypixel_Coord,LensUniqueID(m)] ];  % 记录检测出的微透镜图像中角点的位置,微透镜类型，序号。
    end
end