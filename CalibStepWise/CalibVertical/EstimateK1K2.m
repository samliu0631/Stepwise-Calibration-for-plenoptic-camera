% 根据最小二乘法，利用光场圆域数据，得到K1,K2的估计值。
function [K1,K2] = EstimateK1K2( BoardCornerXYNum , BoardCornerGap , RT_Init ,OmigaR)

X_index                 =  0:1:(BoardCornerXYNum(1)-1);  % X这里表示纵坐标。  所有代码中的世界坐标系中点的生成顺序都是这样
Y_index                 =  0:1:(BoardCornerXYNum(2)-1);  % Y这里表示横坐标。
BoardCornerNum          =  BoardCornerXYNum(1)*BoardCornerXYNum(2);
CornerX_W               =  X_index.*BoardCornerGap(1);
CornerY_W               =  Y_index.*BoardCornerGap(2);
[X,Y]                   =  ndgrid(CornerX_W,CornerY_W);
CornerXYZ_World         =  zeros(4,BoardCornerNum);
CornerXYZ_World(1,:)    =  reshape(X,1,BoardCornerNum);
CornerXYZ_World(2,:)    =  reshape(Y,1,BoardCornerNum);
CornerXYZ_World(4,:)    =  ones(1,BoardCornerNum);  % 特征点4维齐次世界坐标。

ImageNum                =  length(RT_Init)/6;  % 表示拍摄的次数。
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
K1                      =  x_tem(1);  % 利用广义逆矩阵求 bL0和B的最小二乘解。
K2                      =  x_tem(2);  

end
