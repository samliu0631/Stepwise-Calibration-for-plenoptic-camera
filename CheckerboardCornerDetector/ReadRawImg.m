function Img_raw = ReadRawImg(BasePath_raw,FileList_raw, ID)
    CurFname_raw                = FileList_raw{ID};                            % ��ȡȫ�۽�ͼ
    CurFname_raw                = fullfile( BasePath_raw, CurFname_raw);
    CurImg_raw                  = imread( CurFname_raw);
    if  ismatrix(CurImg_raw )   % ����ԻҶȺ�rgbͼ����жϡ�
        Img_raw =CurImg_raw  ;
    else
        Img_raw = rgb2gray(CurImg_raw );
    end
    Img_raw                     = im2double(Img_raw);
end