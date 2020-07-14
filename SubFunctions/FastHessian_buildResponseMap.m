function responseMap=FastHessian_buildResponseMap(FastHessianData)
%在SURF中，图片的大小是一直不变的，不同的octave层得到的待检测图片是改变高斯模糊尺寸大小得到的，
%同一个octave中个的图片用到的高斯模板尺度不同
% Calculate responses for the first 4 FastHessianData.octaves:
% Oct1: 9,  15, 21, 27
% Oct2: 15, 27, 39, 51
% Oct3: 27, 51, 75, 99
% Oct4: 51, 99, 147,195
% Oct5: 99, 195,291,387

% Deallocate memory and clear any existing response layers
%初始化响应层矩阵
responseMap=[]; j=0;


% Get image attributes
w = (size(FastHessianData.img,2) / FastHessianData.init_sample);
h = (size(FastHessianData.img,1)/ FastHessianData.init_sample);%图层的行数，和列数风别除以采样间隔
s = (FastHessianData.init_sample);

% Calculate approximated determinant of hessian values
%开始进行多层不同大小滤波器滤波
%输入为宽，高，采样间隔，滤波器的尺度
if (FastHessianData.octaves >= 1)
    j=j+1; responseMap{j}=FastHessian_ResponseLayer(w,   h,   s,   9);
    j=j+1; responseMap{j}=FastHessian_ResponseLayer(w, h, s, 15);
    j=j+1; responseMap{j}=FastHessian_ResponseLayer(w, h, s, 21);
    j=j+1; responseMap{j}=FastHessian_ResponseLayer(w, h, s, 27);
end
%每算一次，滤波器的尺度就更新，j就加一，就构造一个新的滤波图层
%滤波器的在图像上的作用方阵的中心点的间隔也随着尺度的增加而增加
if (FastHessianData.octaves >= 2)
    j=j+1; responseMap{j}=FastHessian_ResponseLayer(w / 2, h / 2, s * 2, 39);
    j=j+1; responseMap{j}=FastHessian_ResponseLayer(w / 2, h / 2, s * 2, 51);
end

if (FastHessianData.octaves >= 3)
    j=j+1; responseMap{j}=FastHessian_ResponseLayer(w / 4, h / 4, s * 4, 75);
    j=j+1; responseMap{j}=FastHessian_ResponseLayer(w / 4, h / 4, s * 4, 99);
end

if (FastHessianData.octaves >= 4)
    j=j+1; responseMap{j}=FastHessian_ResponseLayer(w / 8, h / 8, s * 8, 147);
    j=j+1; responseMap{j}=FastHessian_ResponseLayer(w / 8, h / 8, s * 8, 195);
end

if (FastHessianData.octaves >= 5)
    j=j+1; responseMap{j}=FastHessian_ResponseLayer(w / 16, h / 16, s * 16, 291);
    j=j+1; responseMap{j}=FastHessian_ResponseLayer(w / 16, h / 16, s * 16, 387);
end
%当滤波器的组数默认为5时，一共有12个滤波结果


% Extract responses from the image
%接下来开始进行为了求高斯二阶黑森矩阵值的盒子滤波器近似计算处理
for i=1:length(responseMap);
    responseMap{i}=FastHessian_buildResponseLayer(responseMap{i},FastHessianData);
end


