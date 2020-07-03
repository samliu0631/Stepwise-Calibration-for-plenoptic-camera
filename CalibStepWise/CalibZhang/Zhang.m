% function Zhang(M,m)
%
% ***********************************************************************************
% *******          A Flexible New Technique for Camera Calibration            *******
% ***********************************************************************************
%                            7/2004    Simon Wan
%                            simonwan@hit.edu.cn
%
% Note:    M:2*N  m:2*N
% M        point on the model plane, when using M=[X,Y]' ---> M=[X,Y,1]'
% m        M's image, when using                m=[u,v]' ---> m=[u,v,1]' , so that
%          s*m = H*M , with H=A*[r1,r2,t];                  (2)
% H        homography matrix
%
% REF:	   "A Flexible New Technique for Camera Calibration"
%           - Zhengyou Zhang 
%           - Microsoft Research 
%
function  x=Zhang(M,m)

%  M=[X,Y]' ---> M=[X,Y,1]'  ;   m=[u,v]' ---> m=[u,v,1]' 
    [rows,npts]=size(M);   % 得到标定板特征点的数量  2*256
    matrixone=ones(1,npts);
    M=[M;matrixone];       % 得到特征点的齐次坐标
    num=size(m,3);
    for i=1:num
        m(3,:,i)=matrixone;   % 将观测到的特征点图像坐标转换为齐次坐标
    end
% Estimate the H
    for i=1:num
        H(:,:,i)=homography2d(M,m(:,:,i))'; %  得到两个平面之间的单映射矩阵
    end
% solve the intrinsic parameters matrix A
% A=[alpha_u skewness u0
%    0       alpha_v  v0
%    0       0        1]
% see Appendix B "Extraction of the Intrisic Parameters from Matrix B", P18
    V=[];
    for flag=1:num
        v12(:,:,flag)=[H(1,1,flag)*H(2,1,flag), H(1,1,flag)*H(2,2,flag)+H(1,2,flag)*H(2,1,flag), H(1,2,flag)*H(2,2,flag), H(1,3,flag)*H(2,1,flag)+H(1,1,flag)*H(2,3,flag), H(1,3,flag)*H(2,2,flag)+H(1,2,flag)*H(2,3,flag), H(1,3,flag)*H(2,3,flag)];
        v11(:,:,flag)=[H(1,1,flag)*H(1,1,flag), H(1,1,flag)*H(1,2,flag)+H(1,2,flag)*H(1,1,flag), H(1,2,flag)*H(1,2,flag), H(1,3,flag)*H(1,1,flag)+H(1,1,flag)*H(1,3,flag), H(1,3,flag)*H(1,2,flag)+H(1,2,flag)*H(1,3,flag), H(1,3,flag)*H(1,3,flag)];
        v22(:,:,flag)=[H(2,1,flag)*H(2,1,flag), H(2,1,flag)*H(2,2,flag)+H(2,2,flag)*H(2,1,flag), H(2,2,flag)*H(2,2,flag), H(2,3,flag)*H(2,1,flag)+H(2,1,flag)*H(2,3,flag), H(2,3,flag)*H(2,2,flag)+H(2,2,flag)*H(2,3,flag), H(2,3,flag)*H(2,3,flag)];
        V=[V;v12(:,:,flag);v11(:,:,flag)-v22(:,:,flag)];
    end
    k=V'*V;       
    [u,v,d]=svd(k);
    [e,d2]=eig(k);
    b=d(:,6);

    v0=(b(2)*b(4)-b(1)*b(5))/(b(1)*b(3)-b(2)^2);
    s=b(6)-(b(4)^2+v0*(b(2)*b(4)-b(1)*b(5)))/b(1);
    alpha_u=sqrt(s/b(1));
    alpha_v=sqrt(s*b(1)/(b(1)*b(3)-b(2)^2));
    skewness=-b(2)*alpha_u*alpha_u*alpha_v/s; 
    u0=skewness*v0/alpha_u-b(4)*alpha_u*alpha_u/s;
    A=[alpha_u skewness u0
        0      alpha_v  v0
        0      0        1];
% solve k1 k1 and all the extrisic parameters, P6
    D=[];
    d=[];
    Rm=[];
    for flag=1:num
        s=(1/norm(inv(A)*H(1,:,flag)')+1/norm(inv(A)*H(2,:,flag)'))/2;
        rl1=s*inv(A)*H(1,:,flag)';
        rl2=s*inv(A)*H(2,:,flag)';
        rl3=cross(rl1,rl2);
        RL=[rl1,rl2,rl3];
        %%%%%%%%%%%%%%%%%%%%
        % see Appendix C "Approximating a 3*3 matrix by a Rotation Matrix", P19
        [U,S,V] = svd(RL);
        RL=U*V';
        %%%%%%%%%%%%%%%%%%%%
        TL=s*inv(A)*H(3,:,flag)';
        RT=[rl1,rl2,TL];
        XY=RT*M;
        UV=A*XY;
        UV=[UV(1,:)./UV(3,:); UV(2,:)./UV(3,:); UV(3,:)./UV(3,:)];
        XY=[XY(1,:)./XY(3,:); XY(2,:)./XY(3,:); XY(3,:)./XY(3,:)];
        for j=1:npts
            D=[D; ((UV(1,j)-u0)*( (XY(1,j))^2 + (XY(2,j))^2 )) , ((UV(1,j)-u0)*( (XY(1,j))^2 + (XY(2,j))^2 )^2) ; ((UV(2,j)-v0)*( (XY(1,j))^2 + (XY(2,j))^2 )) , ((UV(2,j)-v0)*( (XY(1,j))^2 + (XY(2,j))^2 )^2) ];
            d=[d; (m(1,j,flag)-UV(1,j)) ; (m(2,j,flag)-UV(2,j))];
        end
        r13=RL(1,3);
        r12=RL(1,2);
        r23=RL(2,3);
        Q1=-asin(r13);           % Q1表示Y轴方向上的旋转
        Q2=asin(r12/cos(Q1));    % Q2表示Z轴方向上的旋转
        Q3=asin(r23/cos(Q1));    % Q3表示X周方向上的旋转。 度数表示世界坐标系向相机坐标系转换的负方向度数。
        %[cos(Q2)*cos(Q1)   sin(Q2)*cos(Q1)   -sin(Q1) ; -sin(Q2)*cos(Q3)+cos(Q2)*sin(Q1)*sin(Q3)    cos(Q2)*cos(Q3)+sin(Q2)*sin(Q1)*sin(Q3)  cos(Q1)*sin(Q3) ; sin(Q2)*sin(Q3)+cos(Q2)*sin(Q1)*cos(Q3)    -cos(Q2)*sin(Q3)+sin(Q2)*sin(Q1)*cos(Q3)  cos(Q1)*cos(Q3)];
        R_new=[Q1,Q2,Q3,TL'];
        Rm=[Rm , R_new];
    end
% using function (13), P8
    k=inv(D'*D)*D'*d;
% Complete Maximun Likelihood Estimation, using function (14), P8
    para=[Rm,k(1),k(2),alpha_u,skewness,u0,alpha_v,v0];
    %options = optimset('LargeScale','off','LevenbergMarquardt','on');
    options = optimset('LargeScale','off','Algorithm','levenberg-marquardt','Display','off','TolFun',1e-10,'TolX',1e-10,'MaxFunEvals',100000,'MaxIter',100);   
    [x,resnorm,residual,exitflag,output]  = lsqnonlin( @simon_HHH, para, [],[],options, m, M);





