function [Img_raw,Img_raw2] =ImagePreprocess(Img_raw_nonfilter,size ,delta,Optdelta)
    G                           = fspecial('gaussian', size ,delta);   % Gaussian filter
    Img_raw                     = imfilter(Img_raw_nonfilter, G, 'conv');
    Imgmax                      = max(max(Img_raw));               % adjust the illuminate.
    Imgmin                      = min(min(Img_raw));
    Img_raw                     = (Img_raw-Imgmin)/(Imgmax-Imgmin);
    
    G2                           = fspecial('gaussian', size ,Optdelta);   % Gaussian filter
    Img_raw2                     = imfilter(Img_raw_nonfilter, G2, 'conv');
    Imgmax2                      = max(max(Img_raw2));               % adjust the illuminate.
    Imgmin2                      = min(min(Img_raw2));
    Img_raw2                     = (Img_raw2-Imgmin2)/(Imgmax2-Imgmin2);
end