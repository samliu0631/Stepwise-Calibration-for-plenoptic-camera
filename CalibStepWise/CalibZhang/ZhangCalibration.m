function [param,FrameIdUsed] = ZhangCalibration(  OmigaCell, BoardCornerGap_in, BoardCornerXYNum_in,ShowFlag)
    % �궨���������***************************************************************
    BoardCornerGap           = BoardCornerGap_in;               % �궨����������֮��ļ�������ݣ����  
    BoardCornerXYNum         = BoardCornerXYNum_in;             % �궨���ϵ�����������  ���ݣ����   
    FrameNum                 = size(OmigaCell,1);               % num��ʾһ�������˶���֡ͼ��
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
    
    % ���������ѱ궨�����г�ʼ��������**************************************************************************
    
    X_index                  = 0:1:(BoardCornerXYNum(1)-1);                    % X�����ʾ�����ꡣ �����������˳���Ǵ��ϵ��£������ҡ����д��붼Ҫ�������˳��
    Y_index                  = 0:1:(BoardCornerXYNum(2)-1);                    % Y�����ʾ�����ꡣ
    CornerX_W                = X_index.*BoardCornerGap(1);
    CornerY_W                = Y_index.*BoardCornerGap(2);
    [X,Y]                    = ndgrid(CornerX_W,CornerY_W);
    CornerXYZ_World          = zeros(4,BoardCornerNum);
    CornerXYZ_World(1,:)     = reshape(X,1,BoardCornerNum);
    CornerXYZ_World(2,:)     = reshape(Y,1,BoardCornerNum);
    CornerXYZ_World(4,:)     = ones(1,BoardCornerNum);  % ������4ά����������ꡣ

    M                        = [CornerXYZ_World(2,:);-( BoardCornerXYNum(1)-1 ) * BoardCornerGap(1)+CornerXYZ_World(1,:)];  % ��ʾ�궨������������ꡣ ��λ��mm �����ѷ����궨�����������С�ԭ���ڱ궨�����½ǡ�X�����ң�Y�����¡�
    m                        = reshape(CornerXYZ_TotalImg_All', 2 ,BoardCornerNum ,ValidNum );  % ��ʵͼ����Ҫ��ת
    M                        = double(M);
    m                        = double(m);
    para                     = Zhang(M,m);        %�����������㷨

    %**��ʾ�����ѱ궨���***************************************************************************************
    k1                        = para(ValidNum*6+1);
    k2                        = para(ValidNum*6+2);
    A                         = [para(ValidNum*6+3) para(ValidNum*6+4) para(ValidNum*6+5); 0 para(ValidNum*6+6) para(ValidNum*6+7); 0,0,1];
    if ShowFlag==true
       k1
       k2
       A
    end
    %������ʼ��***********************************************************************
    cx                        = para(ValidNum*6+5);         % para(num*6+5);
    cy                        = para(ValidNum*6+7);         % para(num*6+7);
    fx                        = para(ValidNum*6+3);
    fy                        = para(ValidNum*6+6);
    %fL                        = para(num*6+3)*sx*4      % �������ѱ궨����зֽ��fL��
    % ������תƽ�Ʋ���
    RT_myW2ZhangW             = [ pi, 0, pi/2, 0 , -( BoardCornerXYNum(1)-1 ) * BoardCornerGap(1) ,0];   % ����Ǳ�����������ϵ����������������ϵ�ĸ���任����
    RtMatrix_myW2ZhangW       = SetAxisSam( RT_myW2ZhangW );
    R_Zhang                   = ones(4,4);
    RT_Init                   = zeros(1,6*ValidNum);
    for i=1:ValidNum
        RT_current              = para(i*6-5: i*6);  % ��ǰ֡ͨ�������ѱ궨���������ת�ǶȺ�ƽ�Ʋ���
        Q1                      = RT_current(1);
        Q2                      = RT_current(2);
        Q3                      = RT_current(3);
        R_Zhang(1:3,1:3)        = [cos(Q2)*cos(Q1)   sin(Q2)*cos(Q1)   -sin(Q1) ; -sin(Q2)*cos(Q3)+cos(Q2)*sin(Q1)*sin(Q3)    cos(Q2)*cos(Q3)+sin(Q2)*sin(Q1)*sin(Q3)  cos(Q1)*sin(Q3) ; sin(Q2)*sin(Q3)+cos(Q2)*sin(Q1)*cos(Q3)    -cos(Q2)*sin(Q3)+sin(Q2)*sin(Q1)*cos(Q3)  cos(Q1)*cos(Q3)];
        R_Zhang(1:3,4)          = RT_current(4:6)';
        %Rt_final                = R_Zhang;
        Rt_final                = R_Zhang * RtMatrix_myW2ZhangW;  % ȷ�����Զ���������ϵ �� ��������������ϵ �ٵ� �������ϵ ����תƽ�ƾ���
        RT_Init(i*6-5:i*6)      = GetAxisSam( Rt_final ); 
        %RT_Init(i*6)            = RT_Init(i*6)+ fL;   % �����ѱ궨�͹ⳡ����궨��z�������һ������ľ��롣
        RT_Init(i*6)            = RT_Init(i*6);
    end
    param =[fx,fy,cx,cy,k1,k2,RT_Init];
end