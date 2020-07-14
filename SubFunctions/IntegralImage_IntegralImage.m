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
%����ͼ�������ֵ�����������й�һ�����������е�ֵ����0-1֮��
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
%��ͼ��ת��Ϊ�Ҷ�ͼ��
if(size(I,3)==3)%����⵽�ǵ���ά��3�ľ���RGBͼ��
	cR = .2989; cG = .5870; cB = .1140;
	I=I(:,:,1)*cR+I(:,:,2)*cG+I(:,:,3)*cB;
end

% Make the integral image
pic = cumsum(cumsum(I,1),2);%����cumsum���ú��������л���ͼ��Ĺ��죬cumsum����������Ϊ��һ��ֻ������֮�ͻ�����֮�ͣ�������
%����������ķ��������Ԫ��֮��












