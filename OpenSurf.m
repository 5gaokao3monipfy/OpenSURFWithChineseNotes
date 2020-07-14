function ipts=OpenSurf(img,Options)
% This function OPENSURF, is an implementation of SURF (Speeded Up Robust 
% Features). SURF will detect landmark points in an image, and describe
% the points by a vector which is robust against (a little bit) rotation 
% ,scaling and noise. It can be used in the same way as SIFT (Scale-invariant 
% feature transform) which is patented. Thus to align (register) two 
% or more images based on corresponding points, or make 3D reconstructions.
%
% This Matlab implementation of Surf is a direct translation of the 
% OpenSurf C# code of Chris Evans, and gives exactly the same answer. 
% Chris Evans wrote one of the best, well structured all inclusive SURF 
% implementations. On his site you can find Evaluations of OpenSURF 
% and the C# and C++ code. http://www.chrisevansdev.com/opensurf/
% Chris Evans gave me permisson to publish this code under the (Mathworks)
% BSD license.
%
% Ipts = OpenSurf(I, Options)
%
% inputs,
%   I : The 2D input image color or greyscale
%   (optional)
%   Options : A struct with options (see below)
%
% outputs,
%   Ipts : A structure with the information about all detected Landmark points
%     Ipts.x , ipts.y : The landmark position
%     Ipts.scale : The scale of the detected landmark
%     Ipts.laplacian : The laplacian of the landmark neighborhood
%     Ipts.orientation : Orientation in radians
%     Ipts.descriptor : The descriptor for corresponding point matching
%
% options,
%   Options.verbose : If set to true then useful information is 
%                     displayed (default false)
%   Options.upright : Boolean which determines if we want a non-rotation
%                       invariant result (default false)
%   Options.extended : Add extra landmark point information to the
%                   descriptor (default false)
%   Options.tresh : Hessian response treshold (default 0.0002)
%   Options.octaves : Number of octaves to analyse(default 5)
%   Options.init_sample : Initial sampling step in the image (default 2)
%   
% Example 1, Basic Surf Point Detection
% % Load image
%   I=imread('TestImages/test.png');
% % Set this option to true if you want to see more information
%   Options.verbose=false; 
% % Get the Key Points
%   Ipts=OpenSurf(I,Options);
% % Draw points on the image
%   PaintSURF(I, Ipts);
%
% Example 2, Corresponding points
% % See, example2.m
%
% Example 3, Affine registration
% % See, example3.m
%
% Function is written by D.Kroon University of Twente (July 2010)

% 通过文件操作将SubFunction加入到路径中
functionname='OpenSurf.m';
functiondir=which(functionname);%获取文件夹路径，比如C:\Users\lenovo\Desktop\figurematch\OpenSurf.m
functiondir=functiondir(1:end-length(functionname));%减去最后的OpenSurf.m，变为C:\Users\lenovo\Desktop\figurematch\
addpath([functiondir '/SubFunctions'])%变为C:\Users\lenovo\Desktop\figurematch\SubFunctions
       
% 将函数的输入进行处理
defaultoptions=struct('tresh',0.0002,'octaves',5,'init_sample',2,'upright',false,'extended',false,'verbose',false);%设置默认的功能选项
if(~exist('Options','var')), 
    Options=defaultoptions; 
else
    tags = fieldnames(defaultoptions);%尝试获取选项的字符串结构体名称
    for i=1:length(tags)
         if(~isfield(Options,tags{i})),  Options.(tags{i})=defaultoptions.(tags{i}); end%判断是否输入了新的选项，若没有则用默认的内容
    end
    if(length(tags)~=length(fieldnames(Options))), 
        warning('register_volumes:unknownoption','unknown options found');%有未知的选项输入时会报错
    end
end

% Create Integral Image
%构造积分图像
%积分图像中任意一点（i，j）的值为原图像左上角到任意点（i，j）相应的对焦区域的灰度值的总和
iimg=IntegralImage_IntegralImage(img);


% Extract the interest points
%先将几个用户的选项和构造好的积分图像写入到一个主计算函数的输入变量中
FastHessianData.thresh = Options.tresh;
FastHessianData.octaves = Options.octaves;
FastHessianData.init_sample = Options.init_sample;%这几个都是前面option里面有的

FastHessianData.img = iimg;%这是传入积分图像
%开始主计算函数，得到的ipts即为我们需要的检测到的特征点的全部信息的元组
ipts = FastHessian_getIpoints(FastHessianData,Options.verbose);


% Describe the interest points
%生成特征点描述符
if(~isempty(ipts))
    ipts = SurfDescriptor_DecribeInterestPoints(ipts,Options.upright, Options.extended, iimg, Options.verbose);
end





