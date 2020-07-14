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

% ͨ���ļ�������SubFunction���뵽·����
functionname='OpenSurf.m';
functiondir=which(functionname);%��ȡ�ļ���·��������C:\Users\lenovo\Desktop\figurematch\OpenSurf.m
functiondir=functiondir(1:end-length(functionname));%��ȥ����OpenSurf.m����ΪC:\Users\lenovo\Desktop\figurematch\
addpath([functiondir '/SubFunctions'])%��ΪC:\Users\lenovo\Desktop\figurematch\SubFunctions
       
% ��������������д���
defaultoptions=struct('tresh',0.0002,'octaves',5,'init_sample',2,'upright',false,'extended',false,'verbose',false);%����Ĭ�ϵĹ���ѡ��
if(~exist('Options','var')), 
    Options=defaultoptions; 
else
    tags = fieldnames(defaultoptions);%���Ի�ȡѡ����ַ����ṹ������
    for i=1:length(tags)
         if(~isfield(Options,tags{i})),  Options.(tags{i})=defaultoptions.(tags{i}); end%�ж��Ƿ��������µ�ѡ���û������Ĭ�ϵ�����
    end
    if(length(tags)~=length(fieldnames(Options))), 
        warning('register_volumes:unknownoption','unknown options found');%��δ֪��ѡ������ʱ�ᱨ��
    end
end

% Create Integral Image
%�������ͼ��
%����ͼ��������һ�㣨i��j����ֵΪԭͼ�����Ͻǵ�����㣨i��j����Ӧ�ĶԽ�����ĻҶ�ֵ���ܺ�
iimg=IntegralImage_IntegralImage(img);


% Extract the interest points
%�Ƚ������û���ѡ��͹���õĻ���ͼ��д�뵽һ�������㺯�������������
FastHessianData.thresh = Options.tresh;
FastHessianData.octaves = Options.octaves;
FastHessianData.init_sample = Options.init_sample;%�⼸������ǰ��option�����е�

FastHessianData.img = iimg;%���Ǵ������ͼ��
%��ʼ�����㺯�����õ���ipts��Ϊ������Ҫ�ļ�⵽���������ȫ����Ϣ��Ԫ��
ipts = FastHessian_getIpoints(FastHessianData,Options.verbose);


% Describe the interest points
%����������������
if(~isempty(ipts))
    ipts = SurfDescriptor_DecribeInterestPoints(ipts,Options.upright, Options.extended, iimg, Options.verbose);
end





