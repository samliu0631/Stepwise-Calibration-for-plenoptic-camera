function ShowDetectResults(FilePath_Raw, DefaultFileSpec_Raw,allPts,varargin)
    if nargin == 4
        GridCoords =varargin{1};
        GridCoordsX = GridCoords(:,:,1);
        GridCoordsY = GridCoords(:,:,2);
    end
    DefaultPath = '.';
    [FileList_raw, BasePath_raw]             = LFFindFilesRecursive( FilePath_Raw, DefaultFileSpec_Raw , DefaultPath );
    fprintf('Found :\n');
    disp(FileList_raw)
    %**提取标定板特征点和对应特征点的深度************************************************
    ImageNum                                            = length(FileList_raw);
    % 有效图像的序号。
    for iFile = 1:ImageNum  
        CurFname_raw                                    = FileList_raw{ iFile };                               % 读取全聚焦图
        CurFname_raw                                    = fullfile( BasePath_raw, CurFname_raw);
        CurImg_raw                                      = imread( CurFname_raw);  % 读取原始图 ，这里需要进行修改，读取可以检测出角点的原始图来。
        Current_Corner_microImg_Coord                   = allPts{iFile}; 
        CornerNum3d                                     = size(Current_Corner_microImg_Coord,1);   
        
        
%         CurImg_raw = im2double(CurImg_raw);
%         maxValue = max(max(CurImg_raw));
%         minValue = min(min(CurImg_raw));
%         CurImg_raw = (CurImg_raw-minValue)./(maxValue-minValue);
%         CurImg_ROI  = CurImg_raw(930:930+175,1650:1650+175);
%         figure;imshow(CurImg_ROI);
        
        figure;imshow(CurImg_raw);
        hold on
        if nargin ==4
            plot(GridCoordsX(:),GridCoordsY(:),'b*');
        end
        for j = 1 : CornerNum3d
            Current_Corner_microImg_Coord_tem               =  Current_Corner_microImg_Coord{j};
            if ~isempty(Current_Corner_microImg_Coord_tem)
                %plot(Current_Corner_microImg_Coord_tem(:,1)-1650+1 , Current_Corner_microImg_Coord_tem(:,2)-930+1 , '.', 'markersize',15);
                plot(Current_Corner_microImg_Coord_tem(:,1) , Current_Corner_microImg_Coord_tem(:,2) , '.', 'markersize',15);
            end 
        end
        hold off;
    end
end