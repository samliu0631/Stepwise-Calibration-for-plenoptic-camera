% ������С���˷������ùⳡԲ�����ݣ��õ�K1,K2�Ĺ���ֵ��
function [K1,K2] = EstimateK1K2( BoardCornerXYNum , BoardCornerGap , RT_Init ,OmigaR)

X_index                 =  0:1:(BoardCornerXYNum(1)-1);  % X�����ʾ�����ꡣ  ���д����е���������ϵ�е������˳��������
Y_index                 =  0:1:(BoardCornerXYNum(2)-1);  % Y�����ʾ�����ꡣ
BoardCornerNum          =  BoardCornerXYNum(1)*BoardCornerXYNum(2);
CornerX_W               =  X_index.*BoardCornerGap(1);
CornerY_W               =  Y_index.*BoardCornerGap(2);
[X,Y]                   =  ndgrid(CornerX_W,CornerY_W);
CornerXYZ_World         =  zeros(4,BoardCornerNum);
CornerXYZ_World(1,:)    =  reshape(X,1,BoardCornerNum);
CornerXYZ_World(2,:)    =  reshape(Y,1,BoardCornerNum);
CornerXYZ_World(4,:)    =  ones(1,BoardCornerNum);  % ������4ά����������ꡣ

ImageNum                =  length(RT_Init)/6;  % ��ʾ����Ĵ�����
CornerZ_CameraAll       = [];
for i=1:ImageNum
    RtMatrix            = SetAxisSam( RT_Init( i*6-5: i*6 ) );
    CornerXYZ_Camera    = RtMatrix*CornerXYZ_World;
    CornerXYZ_Camera    = CornerXYZ_Camera./CornerXYZ_Camera(4,:);
    CornerZ_Camera      = CornerXYZ_Camera(3,:);         % Zc
    CornerZ_CameraAll   = [CornerZ_CameraAll,CornerZ_Camera];   
end
A                       =  [ones( length(OmigaR) , 1  ),  (1./CornerZ_CameraAll)'      ];
m_tem                   =  A'*(-OmigaR);
n_tem                   =  A'*A;
x_tem                   =  n_tem\m_tem;
K1                      =  x_tem(1);  % ���ù���������� bL0��B����С���˽⡣
K2                      =  x_tem(2);  

end
