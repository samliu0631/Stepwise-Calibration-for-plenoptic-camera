function cost  = PDFErrorAllParamRealSpace( params ,OmigaCell, BoardCornerGap, BoardCornerXYNum,FrameIdUsed)
    K1 = params(1);
    K2 = params(2);
    fx = params(3);
    fy = params(4);
    cx = params(5);
    cy = params(6);
    k1 = params(7);
    k2 = params(8);
    A = -1/K2;
    B = -K1/K2;
    ext_param           = params(9:end);
    ImageNum            = length(ext_param)/6;     % 表示拍摄的次数。
    
    %**********************************************************************************
    % 计算特征点的世界坐标下的坐标。
    X_index                 = 0:1:(BoardCornerXYNum(1)-1);                    % X这里表示纵坐标。 这里的特征点顺序是从上到下，从左到右。所有代码都要按照这个顺序。
    Y_index                 = 0:1:(BoardCornerXYNum(2)-1);                    % Y这里表示横坐标。
    BoardCornerNum          = BoardCornerXYNum(1)*BoardCornerXYNum(2);
    CornerX_W               = X_index.*BoardCornerGap(1);
    CornerY_W               = Y_index.*BoardCornerGap(2);
    [X,Y]                   = ndgrid(CornerX_W,CornerY_W);
    CornerXYZ_World         = zeros(4,BoardCornerNum);
    CornerXYZ_World(1,:)    = reshape(X,1,BoardCornerNum);
    CornerXYZ_World(2,:)    = reshape(Y,1,BoardCornerNum);
    CornerXYZ_World(4,:)    = ones(1,BoardCornerNum);  % 特征点4维齐次世界坐标。
    CornerXYZ_WorldSN       = CornerXYZ_World(1:3,:);  % 特征点4维齐次世界坐标。
    cost = zeros(ImageNum*BoardCornerNum,3);
    for n = 1:ImageNum        
%         % rotation and transformation
        RtMatrix = SetAxisSam(ext_param(6 * n - 5 : 6 * n));
        CurrentFrameID  = FrameIdUsed(n);
        OmigaXYZ        = OmigaCell{CurrentFrameID};
        CornerPF        = size(OmigaXYZ,1);
        for j =1: CornerPF
            R  = OmigaXYZ(j,3);
            lx = OmigaXYZ(j,1)-cx;
            ly = OmigaXYZ(j,2)-cy;
            
            % convert from pdf to camera coordinates.
            Pz = 1/(B + A*R);
            Px = Pz*lx/fx;
            Py = Pz*ly/fy;
            
            %
            Pxi     =  Px;
            Pyi     =  Py;
            Pzi     =  Pz;
            % correct lateral distortion.
%             rReal = (Px/Pz)^2+(Py/Pz)^2;
%             Pparam = [k2^2, 2*k1*k2, (2*k2+k1^2), 2*k1 , 1, -rReal ];
%             r_result  = roots(Pparam);
%             r_result(imag(r_result)~=0) = [];
%             r_result(r_result<=0) =[];
%             [~,idx] = min(abs(rReal-r_result));
%             r_ideal = r_result(idx);
%             delta   = (1+k1*r_ideal+k2*r_ideal^2);
%             Pxi     =  Px/delta;
%             Pyi     =  Py/delta;
%             Pzi     =  Pz;
            
            % convert ideal camera coordinates to world coordinates.
            P = RtMatrix(1:3,1:3)'*([Pxi;Pyi;Pzi]-RtMatrix(1:3,4));
            reprojError     = (P-CornerXYZ_WorldSN(:,j))';
            %reprojError     = sqrt( sum( ( P-CornerXYZ_WorldSN(:,j))'.^2 , 2) );
            %cost            = [cost;reprojError] ;
            cost((n-1)*CornerPF+j,:)=reprojError;
        end
    end
    cost= cost(:);
end


