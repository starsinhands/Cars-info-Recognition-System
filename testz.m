clc;
clear;
close all;
%%读取图像
img = imread('imgTest/测试6.jpg');%读取图像，也是读取不同图片的时候需要修改的地方
%figure();
imshow(img);
title('原始图像');
%% 选择点，确定量程----转速表
fprintf('请选择转速表量程起始点\n');
[x1,y1] = ginput;
hold on;
plot(x1,y1,'r+')%将点在其中标记出来
fprintf('请选择转速表仪表盘中心点\n');
[x2,y2] = ginput;
y0 = y2+60;
x0 = x2+1;
plot(x2,y2,'y+')%将点在其中标记出来
fprintf('请选择转速表量程终止点\n');
[x3,y3] = ginput;
plot(x3,y3,'r+')%将点在其中标记出来
hold off;
% %计算左侧量程初始点与Y轴角度
slope_AB = (y2 - y1) / (x2 - x1);% 计算AB线段的斜率
slope_BC = (y0 - y2) / (x0 - x2);% 计算BC线段的斜率
slope_difference = atan((slope_BC - slope_AB) / (1 + slope_BC * slope_AB));% 计算斜率差值
angle1 = abs(rad2deg(slope_difference));% 将弧度转换为角度
%计算右侧量程结束点与Y轴角度
slope_AB = (y2 - y3) / (x2 - x3);% 计算AB线段的斜率
slope_BC = (y0 - y2) / (x0 - x2);% 计算BC线段的斜率
slope_difference = atan((slope_BC - slope_AB) / (1 + slope_BC * slope_AB));% 计算斜率差值
angle2 = abs(rad2deg(slope_difference));% 将弧度转换为角度

%% 选择点，确定量程----时速表
fprintf('请选择时速表量程起始点\n');
[x1,y1] = ginput;
hold on;
plot(x1,y1,'r+')%将点在其中标记出来
fprintf('请选择时速表仪表盘中心点\n');
[x2,y2] = ginput;
y0 = y2+60;
x0 = x2+1;
plot(x2,y2,'y+')%将点在其中标记出来
fprintf('请选择时速表量程终止点\n');
[x3,y3] = ginput;
plot(x3,y3,'r+')%将点在其中标记出来
hold off;
% %计算左侧量程初始点与Y轴角度
slope_AB = (y2 - y1) / (x2 - x1);% 计算AB线段的斜率
slope_BC = (y0 - y2) / (x0 - x2);% 计算BC线段的斜率
slope_difference = atan((slope_BC - slope_AB) / (1 + slope_BC * slope_AB));% 计算斜率差值
angle3 = abs(rad2deg(slope_difference));% 将弧度转换为角度
%计算右侧量程结束点与Y轴角度
slope_AB = (y2 - y3) / (x2 - x3);% 计算AB线段的斜率
slope_BC = (y0 - y2) / (x0 - x2);% 计算BC线段的斜率
slope_difference = atan((slope_BC - slope_AB) / (1 + slope_BC * slope_AB));% 计算斜率差值
angle4 = abs(rad2deg(slope_difference));% 将弧度转换为角度
%% 分割指针判断读数
redimage = img(:,:,1);%图像灰度化
figure();
imshow(redimage);
title('R分量图像');
redimage=medfilt2(redimage,[7,7]);%中值滤波去噪
figure();
imshow(redimage);
title('中值滤波图像去噪');
BW = im2bw(redimage);%图像二值化
figure();
imshow(BW);
title('指针二值化结果');
% se = strel('disk',3);
% BW = imopen(BW,se);
BW = bwareaopen(BW,100);%去除小面积区域
figure();
imshow(BW);
title('形态学结果');
ginf = bwmorph(BW, 'skeleton', Inf);%指针骨架提取
ginf=bwmorph(ginf,'spur',3);%去除骨架毛刺
figure();
imshow(ginf);
title('指针骨架提取');
[m,n] = size(ginf);
figure();
%分左右两部分分别识别
for p=1:2
    if p ==1
        ginf1= ginf(1:m,1:round(n/2)-1);
    else
        ginf1= ginf(1:m,round(n/2)-1:n);
    end

    [H,T,R]= hough(ginf1,'ThetaRes',0.1,'RhoRes',1);%hough变换，ThetaRes轴变换间隔为1
    P=houghpeaks(H,8,'threshold',ceil(0.25*max(H(:))));%检测投票结果，制定8个特征，阈值为0.25*最大值
    hold on
    lines=houghlines(ginf1,T,R,P,'FillGap',9,'MinLength',45);%检测直线，小于15，两直线合并，检测直线最短长度102
    subplot(1,2,p),imshow(ginf1,[]),title('Hough变换检测结果'),
    hold on;
    distance = 0;%最长距离
    index = 1;
    %判断指针是哪条线，可能检测出来很多线，取最长的线为指针
    for k=1:length(lines)
        xy=[lines(k).point1;lines(k).point2];
        dis = norm([xy(1,1),xy(1,2)]-[xy(2,1),xy(2,2)]);%线段距离
        if dis>distance
            distance = dis;
            index = k;
        end
        %         plot(xy(:,1),xy(:,2),'LineWidth',4,'Color',[.6 .7 .8]);
    end
    %标记最长线段
    xy=[lines(index).point1;lines(index).point2];
    plot(xy(:,1),xy(:,2),'LineWidth',3,'Color','y');
    a=[lines(index).theta];%取出struct中theta
    if p ==1%转速表
        if a<0
            result = (90+a+(90-angle1))/(360-angle1-angle2)*8;
        else
            result = (a-angle1)/(360-angle1-angle2)*8;
        end
        disp(['汽车转速为：' num2str(result) 'x1000 r/min']);
    else
        if a<0
            result = (90+a+(90-angle3))/(360-angle3-angle4)*240;
        else
            result = (a-angle3)/(360-angle3-angle4)*240;
        end
        if result<0
            result = 0;  
        end
         disp(['汽车速度为：' num2str(result) 'km/h']);
    end
end