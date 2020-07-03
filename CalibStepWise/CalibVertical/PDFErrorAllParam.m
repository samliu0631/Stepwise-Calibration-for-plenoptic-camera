function cost  = PDFErrorAllParam( params ,OmigaCell, BoardCornerGap, BoardCornerXYNum,FrameIdUsed)
    weight =80; %32;%
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
    ext_param   = params(9:end-3);
    k3 = params(end-2);
    k4 = params(end-1);
    k5 = params(end);
    
    
    
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
        % rotation and transformation
        RT = SetAxisSam(ext_param(6 * n - 5 : 6 * n));
        Xc = RT(1:3, 1:3)*CornerXYZ_WorldSN + RT(1:3, 4);
        
        %lens distortion
        CameraXIdeal  = Xc(1,:);
        CameraYIdeal  = Xc(2,:);
        CameraZIdeal  = Xc(3,:);
        r2            = (CameraXIdeal./CameraZIdeal).^2 + (CameraYIdeal./CameraZIdeal).^2;
        CameraXReal   = (1 + k1*r2 + k2*(r2).^2).* CameraXIdeal;
        CameraYReal   = (1 + k1*r2 + k2*(r2).^2).* CameraYIdeal;
        Xc(1:2,:)     = [CameraXReal;CameraYReal];
        
        % projection
        wx = fx.*Xc(1,:)./Xc(3,:);
        wy = fy.*Xc(2,:)./Xc(3,:);
        R = (1./(A.*Xc(3,:))) - B/A;
        wx = wx+cx;
        wy = wy+cy;
        
        % add depth distortion error
        rdot = sqrt(r2).*( k3 + k4.*R );
        Rd = R+k5.*rdot;
        R  = Rd;        
        
        % calculate cost.
        CurrentFrameID  = FrameIdUsed(n);
        OmigaXYZ        = OmigaCell{CurrentFrameID};
        reprojError     = [wx',wy',R']-OmigaXYZ;
        
%         % add weight
%         XdivZ  = mean(abs(reprojError(:,1))./abs(reprojError(:,3)));
%         YdivZ  = mean(abs(reprojError(:,2))./abs(reprojError(:,3)));
%         weight = max(XdivZ,YdivZ);
%         reprojError(:,3)= reprojError(:,3).*weight; % ����Ȩ��
%         
        % collect cost.
        cost            = [cost;reprojError] ;
    end

    cost(:,3) = cost(:,3).*weight;
end


