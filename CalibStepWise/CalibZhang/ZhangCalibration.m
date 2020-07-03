function [param,FrameIdUsed] = ZhangCalibration(  OmigaCell, BoardCornerGap_in, BoardCornerXYNum_in,ShowFlag)
    % 标定板参数设置***************************************************************
    BoardCornerGap           = BoardCornerGap_in;               % 标定板上特征点之间的间隔。先纵，后横  
    BoardCornerXYNum         = BoardCornerXYNum_in;             % 标定板上的特征点数量  先纵，后横   
    FrameNum                 = size(OmigaCell,1);               % num表示一共拍摄了多少帧图像
    BoardCornerNum           = BoardCornerXYNum(1)*BoardCornerXYNum(2);    
    CornerXYZ_TotalImg_All   = [];
    FrameIdUsed              = [];
    for i=1:FrameNum
        OmigaCurrentFrame       = OmigaCell{i};
        CornerNumCurrentFrame   = size(OmigaCurrentFrame,1);        
        if CornerNumCurrentFrame==BoardCornerNum
            %meanOmegaZ          = mean(OmigaCurrentFrame(:,3));
            %if (meanOmegaZ <0 && meanOmegaZ <-13 && meanOmegaZ >-35)||(meanOmegaZ >0 && meanOmegaZ <6) % R-B <-6
                CornerXYZ_TotalImg_All = [CornerXYZ_TotalImg_All;OmigaCurrentFrame(:,1:2)];
                FrameIdUsed     = [FrameIdUsed;i];
            %end            
        end
    end
    ValidNum   = size(FrameIdUsed,1);
    
    % 调用张正友标定法进行初始参数估计**************************************************************************
    
    X_index                  = 0:1:(BoardCornerXYNum(1)-1);                    % X这里表示纵坐标。 这里的特征点顺序是从上到下，从左到右。所有代码都要按照这个顺序。
    Y_index                  = 0:1:(BoardCornerXYNum(2)-1);                    % Y这里表示横坐标。
    CornerX_W                = X_index.*BoardCornerGap(1);
    CornerY_W                = Y_index.*BoardCornerGap(2);
    [X,Y]                    = ndgrid(CornerX_W,CornerY_W);
    CornerXYZ_World          = zeros(4,BoardCornerNum);
    CornerXYZ_World(1,:)     = reshape(X,1,BoardCornerNum);
    CornerXYZ_World(2,:)     = reshape(Y,1,BoardCornerNum);
    CornerXYZ_World(4,:)     = ones(1,BoardCornerNum);  % 特征点4维齐次世界坐标。

    M                        = [CornerXYZ_World(2,:);-( BoardCornerXYNum(1)-1 ) * BoardCornerGap(1)+CornerXYZ_World(1,:)];  % 表示标定板的特征点坐标。 单位是mm 张正友方法标定板世界坐标中。原点在标定板左下角。X轴向右，Y轴向下。
    m                        = reshape(CornerXYZ_TotalImg_All', 2 ,BoardCornerNum ,ValidNum );  % 真实图像不需要翻转
    M                        = double(M);
    m                        = double(m);
    para                     = Zhang(M,m);        %调用张正友算法

    %**显示张正友标定结果***************************************************************************************
    k1                        = para(ValidNum*6+1);
    k2                        = para(ValidNum*6+2);
    A                         = [para(ValidNum*6+3) para(ValidNum*6+4) para(ValidNum*6+5); 0 para(ValidNum*6+6) para(ValidNum*6+7); 0,0,1];
    if ShowFlag==true
       k1
       k2
       A
    end
    %参数初始化***********************************************************************
    cx                        = para(ValidNum*6+5);         % para(num*6+5);
    cy                        = para(ValidNum*6+7);         % para(num*6+7);
    fx                        = para(ValidNum*6+3);
    fy                        = para(ValidNum*6+6);
    %fL                        = para(num*6+3)*sx*4      % 从张正友标定结果中分解出fL。
    % 估计旋转平移参数
    RT_myW2ZhangW             = [ pi, 0, pi/2, 0 , -( BoardCornerXYNum(1)-1 ) * BoardCornerGap(1) ,0];   % 这个是本文世界坐标系和张正友世界坐标系的刚体变换参数
    RtMatrix_myW2ZhangW       = SetAxisSam( RT_myW2ZhangW );
    R_Zhang                   = ones(4,4);
    RT_Init                   = zeros(1,6*ValidNum);
    for i=1:ValidNum
        RT_current              = para(i*6-5: i*6);  % 当前帧通过张正友标定法算出的旋转角度和平移参数
        Q1                      = RT_current(1);
        Q2                      = RT_current(2);
        Q3                      = RT_current(3);
        R_Zhang(1:3,1:3)        = [cos(Q2)*cos(Q1)   sin(Q2)*cos(Q1)   -sin(Q1) ; -sin(Q2)*cos(Q3)+cos(Q2)*sin(Q1)*sin(Q3)    cos(Q2)*cos(Q3)+sin(Q2)*sin(Q1)*sin(Q3)  cos(Q1)*sin(Q3) ; sin(Q2)*sin(Q3)+cos(Q2)*sin(Q1)*cos(Q3)    -cos(Q2)*sin(Q3)+sin(Q2)*sin(Q1)*cos(Q3)  cos(Q1)*cos(Q3)];
        R_Zhang(1:3,4)          = RT_current(4:6)';
        %Rt_final                = R_Zhang;
        Rt_final                = R_Zhang * RtMatrix_myW2ZhangW;  % 确定从自定世界坐标系 到 张正友世界坐标系 再到 相机坐标系 的旋转平移矩阵。
        RT_Init(i*6-5:i*6)      = GetAxisSam( Rt_final ); 
        %RT_Init(i*6)            = RT_Init(i*6)+ fL;   % 张正友标定和光场相机标定在z轴上相差一个焦距的距离。
        RT_Init(i*6)            = RT_Init(i*6);
    end
    param =[fx,fy,cx,cy,k1,k2,RT_Init];
end