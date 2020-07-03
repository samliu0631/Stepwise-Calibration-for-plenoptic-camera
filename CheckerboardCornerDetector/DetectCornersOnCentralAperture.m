function corner = DetectCornersOnCentralAperture(ImgCenter,ConfigBag)
    %[corner,~]  = detectCheckerboardPoints(ImgCenter);                       % 检测特征点，会有不准确和检测不全的情况。需要进行改进
    if isfield(ConfigBag,'F_RecoverStruct')
        F_RecoverStruct = ConfigBag.F_RecoverStruct;
    else
        ConfigBag.F_RecoverStruct = true;
        F_RecoverStruct           = true;
    end
    
    corners = findCornersOrigin(ImgCenter,0.01,1);
    if F_RecoverStruct==true
        chessboards = chessboardsFromCorners(corners);
        if isempty(chessboards)
            corner = [];
            return;
        end
        ChessArray  = chessboards{1,1};
        
        ID = zeros(4,1);
        ID(1) = ChessArray(1,1);
        ID(2) = ChessArray(1,end);
        ID(3) = ChessArray(end,1);
        ID(4) = ChessArray(end,end);
        IDind = 1:4;
        
        CornerCoords4 = corners.p(ID,:);
        [~,id]= sort(CornerCoords4(:,1),'ascend');
        id2   = id(1:2);
        id3   = id(3:4);
        [~,id]= sort(CornerCoords4(id2,2),'ascend');
        minid = id2(id(1));
        [~,id]= sort(CornerCoords4(id3,2),'ascend');
        maxid = id3(id(2));
        
        
        IDind([minid;maxid])=[];
        CornerCoords2 = corners.p(ID(IDind'),:);
        if CornerCoords2(1,1)<CornerCoords2(2,1)
            leftid = IDind(1);
        else
            leftid = IDind(2);
        end
        
        if minid ==1 && leftid ==2
            ChessArray = ChessArray';
        end
        if minid ==2 && leftid ==4
            ChessArray = fliplr(ChessArray);
        end
        if minid ==2 && leftid ==1
            ChessArray = fliplr(ChessArray);
            ChessArray = ChessArray';
        end
        if minid ==3 && leftid ==4
            ChessArray = flipud(ChessArray); % 上下翻转
            ChessArray = ChessArray';
        end
        if minid ==3 && leftid ==1
            ChessArray = flipud(ChessArray); % 上下翻转
        end
        if minid ==4 && leftid ==2
            ChessArray = flipud(ChessArray); % 上下翻转
            ChessArray = fliplr(ChessArray);
        end
        if minid ==4 && leftid ==3
            ChessArray = flipud(ChessArray); % 上下翻转
            ChessArray = fliplr(ChessArray);
            ChessArray = ChessArray';
        end
        cornerID  = ChessArray(:);
        corner    = corners.p(cornerID,:)+1;
    else
        corner    = corners.p+1;
    end
       
    corner    = (corner)./2; % 因为插过值，所以要除以2.
    if ( corner(1,1) > corner(end,1) ) && ( (corner(1,2) > corner(end,2)) )           % 为了保证检测顺序。是从上向下，并从左向右。 
       corner =   flipud(corner); % 上下翻转
    end
end