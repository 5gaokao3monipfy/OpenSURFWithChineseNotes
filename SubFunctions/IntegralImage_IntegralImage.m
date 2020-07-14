function pic=IntegralImage_IntegralImage(I)
% This function IntegralImage_IntegralImage will ..
%
% J = IntegralImage_IntegralImage( I )
%  
%  inputs,
%    I : An 2D image color or greyscale
%  
%  outputs,
%    J : The integral image 
%  
% Function is written by D.Kroon University of Twente (July 2010)

% Convert Image to double
%根据图像的像素值的类型来进行归一化处理，令所有的值缩到0-1之间
switch(class(I));
    case 'uint8'
        I=double(I)/255;
    case 'uint16'
        I=double(I)/65535;
    case 'int8'
        I=(double(I)+128)/255;
    case 'int16'
        I=(double(I)+32768)/65535;
    otherwise
        I=double(I);
end

% Convert Image to greyscale
%将图像转化为灰度图像
if(size(I,3)==3)%若检测到是第三维是3的矩阵（RGB图像）
	cR = .2989; cG = .5870; cB = .1140;
	I=I(:,:,1)*cR+I(:,:,2)*cG+I(:,:,3)*cB;
end

% Make the integral image
pic = cumsum(cumsum(I,1),2);%运用cumsum内置函数来进行积分图像的构造，cumsum用两次是因为用一次只是求行之和或者列之和，用两次
%才是求包含的方阵的所有元素之和












