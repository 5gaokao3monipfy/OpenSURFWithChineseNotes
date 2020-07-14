function rl=FastHessian_buildResponseLayer(rl,FastHessianData)
% This function FastHessian_buildResponseLayer will ..
%
% [rl] = FastHessian_buildResponseLayer( rl,FastHessianData )
%  
%  inputs,
%    rl : 
%    FastHessianData : 
%  
%  outputs,
%    rl : 
%  
% Function is written by D.Kroon University of Twente ()

step = fix( rl.step);                      % 滤波器采样间隔
b = fix((rl.filter - 1) / 2 + 1);         % border for this filter滤波器的边界，就是从中心到边缘的像素长度
l = fix(rl.filter / 3);                   % lobe for this filter (filter size / 3)
w = fix(rl.filter);                       % 滤波器响应长度

inverse_area = 1 / double(w * w);          % normalisation factor，就是把滤波器内的滤波后的数求平均用的
img=FastHessianData.img;%导入积分图像的数据

[ac,ar]=ndgrid(0:rl.width-1,0:rl.height-1);%一个用另一个的元素个数当作行数或者列数
ar=ar(:); ac=ac(:);%构造一维向量

% get the image coordinates
r = int32(ar * step);
c = int32(ac * step);%转为有符号的整型数据

% Compute response components
%采用盒子滤波器对高斯二阶微分模板近似处理
%三个不同的结果对应着三个不同的盒子滤波器，我们只用计算盒子滤波器的值就可以近似得到二阶高斯核函数黑森矩阵的结果
Dxx =   IntegralImage_BoxIntegral(r - l + 1, c - b, 2 * l - 1, w,img) - IntegralImage_BoxIntegral(r - l + 1, c - fix(l / 2), 2 * l - 1, l, img) * 3;%Lxx
Dyy =   IntegralImage_BoxIntegral(r - b, c - l + 1, w, 2 * l - 1,img) - IntegralImage_BoxIntegral(r - fix(l / 2), c - l + 1, l, 2 * l - 1,img) * 3;%Lyy
Dxy = + IntegralImage_BoxIntegral(r - l, c + 1, l, l,img) + IntegralImage_BoxIntegral(r + 1, c - l, l, l,img) ...%Lxy
      - IntegralImage_BoxIntegral(r - l, c - l, l, l,img) - IntegralImage_BoxIntegral(r + 1, c + 1, l, l,img);%分别通过对滤波器尺度一些加减的运算，从而计算盒子滤波器的滤波结果

% Normalise the filter responses with respect to their size
Dxx = Dxx*inverse_area;%就是把滤波器内的滤波后的数求平均用的
Dyy = Dyy*inverse_area;
Dxy = Dxy*inverse_area;

% Get the determinant of hessian response & laplacian sign
rl.responses = (Dxx .* Dyy - 0.81 * Dxy .* Dxy);%计算得到每个点的hessian矩阵的值，这个地方说的是应该为0.9而不是0.81
rl.laplacian = (Dxx + Dyy) >= 0;%计算得到每个像素点的拉普拉斯算子值






