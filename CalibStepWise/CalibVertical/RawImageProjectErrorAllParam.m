function cost =RawImageProjectErrorAllParam( params , data , BoardCornerGap, BoardCornerXYNum  , GridCoords )
    K1 = params(1);
    K2 = params(2);
    
    fx = params(3);
    fy = params(4);
    cx = params(5);
    cy = params(6);
    k1 = params(7);
    k2 = params(8);  
    
    ext_param = params(9:end-3);
    k3 = params(end-2);
    k4 = params(end-1);
    k5 = params(end);
    
    GridCoordsX         = GridCoords(:,:,1);
    GridCoordsY         = GridCoords(:,:,2);
    CornerNumOnBoard    = BoardCornerXYNum(1)*BoardCornerXYNum(2);
    ImageNum            = length(ext_param)/6;     % ��ʾ����Ĵ�����

    cost =[];
    %**********************************************************************************
    % ��������������������µ����ꡣ
    X_index                 = 0:1:(BoardCornerXYNum(1)-1);                    % X�����ʾ�����ꡣ �����������˳���Ǵ��ϵ��£������ҡ����д��붼Ҫ�������˳��
    Y_index                 = 0:1:(BoardCornerXYNum(2)-1);                    % Y�����ʾ�����ꡣ
    BoardCornerNum          = BoardCornerXYNum(1)*BoardCornerXYNum(2);
    CornerX_W               = X_index.*BoardCornerGap(1);
    CornerY_W               = Y_index.*BoardCornerGap(2);
    [X,Y]                   = ndgrid(CornerX_W,CornerY_W);
    CornerXYZ_World         = zeros(4,BoardCornerNum);
    CornerXYZ_World(1,:)    = reshape(X,1,BoardCornerNum);
    CornerXYZ_World(2,:)    = reshape(Y,1,BoardCornerNum);
    CornerXYZ_World(4,:)    = ones(1,BoardCornerNum);  % ������4ά����������ꡣ
    CornerXYZ_WorldSN       = CornerXYZ_World(1:3,:);  % ������4ά����������ꡣ

    for n = 1:ImageNum
        RT = SetAxisSam(ext_param(6 * n - 5 : 6 * n));
        Xc = RT(1:3, 1:3)*CornerXYZ_WorldSN + RT(1:3, 4);
        
        %******�������ģ��*************************************************************
        CameraXIdeal  = Xc(1,:);
        CameraYIdeal  = Xc(2,:);
        CameraZIdeal  = Xc(3,:);
        r2            = (CameraXIdeal./CameraZIdeal).^2 + (CameraYIdeal./CameraZIdeal).^2;
        CameraXReal   = (1 + k1*r2 + k2*(r2).^2).* CameraXIdeal;
        CameraYReal   = (1 + k1*r2 + k2*(r2).^2).* CameraYIdeal;
        Xc(1:2,:)     = [CameraXReal;CameraYReal];           
        
        
        % ���㵱ǰ֡����
        data_current      = data{n}; % ��ǰ֡���м�����΢͸��ͼ���еĽǵ�
        for j=1:CornerNumOnBoard
            data_current_element                = double(data_current{j});                 % ��Ӧÿ���ռ��������Ӧ��ԭʼͼ�Ľǵ�
            if size(data_current_element,1)==0                                     % �����ǰ��û�м���ԭʼͼ�ϵĽǵ㣬
                continue;
            end
            CornerCoord_rawImg                  = data_current_element(:,1:2);     % ��Ӧԭʼͼ�нǵ��ͼ������         
            Corner_lensID                       = data_current_element(:,3);       % ��Ӧԭʼͼ�е�΢͸���������ꡣ
            Lens_CoorX                          = GridCoordsX(Corner_lensID);                                             % ΢͸������X�������ꡣ
            Lens_CoorY                          = GridCoordsY(Corner_lensID); 
            %*****************************************************************
            ucs             = Lens_CoorX;
            vcs             = Lens_CoorY;
            du = fx * Xc(1, j) - Xc(3, j).*(ucs - cx);
            dv = fy * Xc(2, j) - Xc(3, j).*(vcs - cy);

            nominator = 1./( K1 * Xc(3, j) + K2 );
            du = nominator.*du;

            dv = nominator.*dv;
            us = ucs + du;
            vs = vcs + dv;
            corn_est= [us,vs];
            corns =CornerCoord_rawImg;
            err = corns - corn_est;
            cost =[cost; err];
            %cost=[cost; sqrt(sum(err.^2, 2))];
        end
        
    end
end