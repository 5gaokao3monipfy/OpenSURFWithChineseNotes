% Example 2, Corresponding points
% Load images
clear all
tic
  I1=imread('datu.png');%I1必须示大一点的那张图
  I2=imread('4.jpg');
% Get the Key Points
  Options.upright=true;
  Options.tresh=0.0001;
  Ipts1=OpenSurf(I1,Options);
  Ipts2=OpenSurf(I2,Options);
% Put the landmark descriptors in a matrix
%构造每个特征点的描述子64维向量
  D1 = reshape([Ipts1.descriptor],64,[]); 
  D2 = reshape([Ipts2.descriptor],64,[]); 
% Find the best matches
  err=zeros(1,length(Ipts1));
  cor1=1:length(Ipts1); 
  cor2=zeros(1,length(Ipts1));
  %通过在两幅图中找到几个最小的描述子64维向量之间的欧式距离来找到匹配点
  for i=1:length(Ipts1)
      distance=sum((D2-repmat(D1(:,i),[1 length(Ipts2)])).^2,1);
      [err(i),cor2(i)]=min(distance);
  end
% Sort matches on vector distance
  [err, ind]=sort(err); 
  cor1=cor1(ind); 
  cor2=cor2(ind);
% Show both images
%图像拼接
  I = zeros([size(I1,1) size(I1,2)+size(I2,2) size(I1,3)]);
  
  I(1:size(I1,1),1:size(I1,2),:)=I1; I(1:size(I2,1),size(I1,2)+1:size(I1,2)+size(I2,2),:)=I2;
  figure, imshow(I/255); hold on;

% Show the best matches
%只展现所有可能匹配点的前30个
  for i=1:30,
      c=rand(1,3);
      plot([Ipts1(cor1(i)).x Ipts2(cor2(i)).x+size(I1,2)],[Ipts1(cor1(i)).y Ipts2(cor2(i)).y],'-','Color',c)
      plot([Ipts1(cor1(i)).x Ipts2(cor2(i)).x+size(I1,2)],[Ipts1(cor1(i)).y Ipts2(cor2(i)).y],'o','Color',c)
  end
  
  toc
  
  
  
  
  
  
  
  