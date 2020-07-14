function an=FastHessian_isExtremum(r, c,  t,  m,  b,FastHessianData)
% This function FastHessian_isExtremum will ..
%
% [an] = FastHessian_isExtremum( r,c,t,m,b,FastHessianData )
%  
%  inputs,
%    r : 行坐标索引
%    c : 列坐标索引
%    t : 
%    m : 
%    b : 
%    FastHessianData : 
%  
%  outputs,
%    an : 
%  
% Function is written by D.Kroon University of Twente (July 2010)

% bounds check
%检测滤波器有没有超过到边界
layerBorder = fix((t.filter + 1) / (2 * t.step));
bound_check_fail=(r <= layerBorder | r >= t.height - layerBorder | c <= layerBorder | c >= t.width - layerBorder);

% check the candidate point in the middle layer is above thresh 

candidate = FastHessian_getResponse(m,r,c,t);%把目标点滤波后的响应值提取出来是，所有响应点组成的一个列向量，比如对于第一层就是34608*1的一个double列向量
treshold_fail=candidate < FastHessianData.thresh;%若目标点的响应值小于某个阈值，则舍弃该点

an=(~bound_check_fail)&(~treshold_fail);%在边界上的点以及响应值小于某个阈值的点舍弃
for rr = -1:1
    for  cc = -1:1
          %  if any response in 3x3x3 is greater then the candidate is not a maximum
          %将经过hessian矩阵处理过的每个像素点与其3维领域的26个点进行大小比较，如果它是这26个点中的最大值或者最小值则判断为特征点
          check1=FastHessian_getResponse(t,r + rr, c + cc, t) >= candidate;
          check2=FastHessian_getResponse(m,r + rr, c + cc, t) >= candidate;
          check3=FastHessian_getResponse(b,r + rr, c + cc, t) >= candidate;%判断3*3*3领域的值是不是
          check4=(rr ~= 0 || cc ~= 0);%这行代码是为了判断这个点是不是他本身
          an3 = ~(check1 | (check4 & check2) | check3);
          an=an&an3;
    end
end%所得的an变量即为判断某一层中所有响应点是否为特征点的逻辑值列向量，元素为1则说明是特征点

function an=FastHessian_getResponse(a,row, column,b)
scale=fix(a.width/b.width);
% Clamp to boundary 
%限制到边界索引处？？
%有待继续研究
% (The orignal C# code, doesn't contain this boundary clamp because if you 
% process one coordinate at the time you already returned on the boundary check)
index=fix(scale*row) * a.width + fix(scale*column)+1;
index(index<1)=1; index(index>length(a.responses))=length(a.responses);
an=a.responses(index);
