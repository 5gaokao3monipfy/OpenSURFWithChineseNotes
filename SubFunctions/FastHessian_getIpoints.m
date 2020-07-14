function ipts=FastHessian_getIpoints(FastHessianData,verbose)
% filter index map

filter_map = [0,1,2,3;
    1,3,4,5;
    3,5,6,7;
    5,7,8,9;
    7,9,10,11]+1;%每一行对应不同的滤波器组
%比如第二组：15，27，39，51。（2，4，5，6）
%第三组：27，51，75，99（4，6，7，8）

np=0; ipts=struct;

% Build the response map
%采用不断增大盒子滤波器模板尺寸与积分图像求取Hession矩阵响应，
responseMap=FastHessian_buildResponseMap(FastHessianData);

% Find the maxima acrros scale and space
%接下来就是定位特征点
for o = 1:FastHessianData.octaves%一共用多少组响应图像
    for i = 1:2%每一组用两次，1，2，3序号和2，3，4，这样就把一组中的响应图像都包含了
        b = responseMap{filter_map(o,i)};%bottom，
        m = responseMap{filter_map(o,i+1)};%middle
        t = responseMap{filter_map(o,i+2)};%top
        
        % loop over middle response layer at density of the most
        % sparse layer (always top), to find maxima across scale and space
        [c,r]=ndgrid(0:t.width-1,0:t.height-1);%这个ndgrid函数的用法类似于meshgrid，都是构造一个矩阵来储存所有点的坐标横纵值，用于进行通过矩阵来对坐标运算
        r=r(:); c=c(:);
        %对每层图像上的每个像素与空间邻域内和尺度邻域内的响应值比较
       % 3D非极大值抑制
        p=find(FastHessian_isExtremum(r, c, t, m, b,FastHessianData));%得到了该次比较的某一层的所有特征点的位置索引
        for j=1:length(p)
            ind=p(j);%得到
            [ipts,np]=FastHessian_interpolateExtremum(r(ind), c(ind), t, m, b, ipts,np);%每一次都会把上一次3D抑制得到的特征点再作为输入，以达到筛选特征点的作用
        end
    end
end

% Show laplacian and response maps with found interest-points
%底下的这两个部分是画出中间过程图的，是否画出可以在主函数的option里面调，就是设置verbose参数为真即可
%所以就不做累述了
if(verbose)
    % Show the response map
    if(verbose)
        fig_h=ceil(length(responseMap)/3);
        h=figure;  set(h,'name','Laplacian');
        for i=1:length(responseMap), 
            pic=reshape(responseMap{i}.laplacian,[responseMap{i}.width responseMap{i}.height]);
            subplot(3,fig_h,i); imshow(pic,[]); hold on;
        end
        h=figure; set(h,'name','Responses');
        h_res=zeros(1,length(responseMap));
        for i=1:length(responseMap), 
            pic=reshape(responseMap{i}.responses,[responseMap{i}.width responseMap{i}.height]);
            h_res(i)=subplot(3,fig_h,i); imshow(pic,[]); hold on;
        end
    end
    
    % Show the maximum points
    disp(['Number of interest points found ' num2str(np)]);
    scales=zeros(1,length(responseMap));
    scaley=zeros(1,length(responseMap));
    scalex=zeros(1,length(responseMap));
    for i=1:length(responseMap)
        scales(i)=responseMap{i}.filter*(2/15);
        scalex(i)=responseMap{i}.width/size(FastHessianData.img,2);
        scaley(i)=responseMap{i}.height/size(FastHessianData.img,1);
    end
    for i=1:np
        [t,ind]=min((scales-ipts(i).scale).^2);
        plot(h_res(ind),ipts(i).y*scaley(ind)+1,ipts(i).x*scalex(ind)+1,'o','color',rand(1,3));
    end
end
