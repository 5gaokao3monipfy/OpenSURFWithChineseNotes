function ipts=FastHessian_getIpoints(FastHessianData,verbose)
% filter index map

filter_map = [0,1,2,3;
    1,3,4,5;
    3,5,6,7;
    5,7,8,9;
    7,9,10,11]+1;%ÿһ�ж�Ӧ��ͬ���˲�����
%����ڶ��飺15��27��39��51����2��4��5��6��
%�����飺27��51��75��99��4��6��7��8��

np=0; ipts=struct;

% Build the response map
%���ò�����������˲���ģ��ߴ������ͼ����ȡHession������Ӧ��
responseMap=FastHessian_buildResponseMap(FastHessianData);

% Find the maxima acrros scale and space
%���������Ƕ�λ������
for o = 1:FastHessianData.octaves%һ���ö�������Ӧͼ��
    for i = 1:2%ÿһ�������Σ�1��2��3��ź�2��3��4�������Ͱ�һ���е���Ӧͼ�񶼰�����
        b = responseMap{filter_map(o,i)};%bottom��
        m = responseMap{filter_map(o,i+1)};%middle
        t = responseMap{filter_map(o,i+2)};%top
        
        % loop over middle response layer at density of the most
        % sparse layer (always top), to find maxima across scale and space
        [c,r]=ndgrid(0:t.width-1,0:t.height-1);%���ndgrid�������÷�������meshgrid�����ǹ���һ���������������е���������ֵ�����ڽ���ͨ������������������
        r=r(:); c=c(:);
        %��ÿ��ͼ���ϵ�ÿ��������ռ������ںͳ߶������ڵ���Ӧֵ�Ƚ�
       % 3D�Ǽ���ֵ����
        p=find(FastHessian_isExtremum(r, c, t, m, b,FastHessianData));%�õ��˸ôαȽϵ�ĳһ��������������λ������
        for j=1:length(p)
            ind=p(j);%�õ�
            [ipts,np]=FastHessian_interpolateExtremum(r(ind), c(ind), t, m, b, ipts,np);%ÿһ�ζ������һ��3D���Ƶõ�������������Ϊ���룬�Դﵽɸѡ�����������
        end
    end
end

% Show laplacian and response maps with found interest-points
%���µ������������ǻ����м����ͼ�ģ��Ƿ񻭳���������������option���������������verbose����Ϊ�漴��
%���ԾͲ���������
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
