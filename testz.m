clc;
clear;
close all;
%%��ȡͼ��
img = imread('imgTest/����6.jpg');%��ȡͼ��Ҳ�Ƕ�ȡ��ͬͼƬ��ʱ����Ҫ�޸ĵĵط�
%figure();
imshow(img);
title('ԭʼͼ��');
%% ѡ��㣬ȷ������----ת�ٱ�
fprintf('��ѡ��ת�ٱ�������ʼ��\n');
[x1,y1] = ginput;
hold on;
plot(x1,y1,'r+')%���������б�ǳ���
fprintf('��ѡ��ת�ٱ��Ǳ������ĵ�\n');
[x2,y2] = ginput;
y0 = y2+60;
x0 = x2+1;
plot(x2,y2,'y+')%���������б�ǳ���
fprintf('��ѡ��ת�ٱ�������ֹ��\n');
[x3,y3] = ginput;
plot(x3,y3,'r+')%���������б�ǳ���
hold off;
% %����������̳�ʼ����Y��Ƕ�
slope_AB = (y2 - y1) / (x2 - x1);% ����AB�߶ε�б��
slope_BC = (y0 - y2) / (x0 - x2);% ����BC�߶ε�б��
slope_difference = atan((slope_BC - slope_AB) / (1 + slope_BC * slope_AB));% ����б�ʲ�ֵ
angle1 = abs(rad2deg(slope_difference));% ������ת��Ϊ�Ƕ�
%�����Ҳ����̽�������Y��Ƕ�
slope_AB = (y2 - y3) / (x2 - x3);% ����AB�߶ε�б��
slope_BC = (y0 - y2) / (x0 - x2);% ����BC�߶ε�б��
slope_difference = atan((slope_BC - slope_AB) / (1 + slope_BC * slope_AB));% ����б�ʲ�ֵ
angle2 = abs(rad2deg(slope_difference));% ������ת��Ϊ�Ƕ�

%% ѡ��㣬ȷ������----ʱ�ٱ�
fprintf('��ѡ��ʱ�ٱ�������ʼ��\n');
[x1,y1] = ginput;
hold on;
plot(x1,y1,'r+')%���������б�ǳ���
fprintf('��ѡ��ʱ�ٱ��Ǳ������ĵ�\n');
[x2,y2] = ginput;
y0 = y2+60;
x0 = x2+1;
plot(x2,y2,'y+')%���������б�ǳ���
fprintf('��ѡ��ʱ�ٱ�������ֹ��\n');
[x3,y3] = ginput;
plot(x3,y3,'r+')%���������б�ǳ���
hold off;
% %����������̳�ʼ����Y��Ƕ�
slope_AB = (y2 - y1) / (x2 - x1);% ����AB�߶ε�б��
slope_BC = (y0 - y2) / (x0 - x2);% ����BC�߶ε�б��
slope_difference = atan((slope_BC - slope_AB) / (1 + slope_BC * slope_AB));% ����б�ʲ�ֵ
angle3 = abs(rad2deg(slope_difference));% ������ת��Ϊ�Ƕ�
%�����Ҳ����̽�������Y��Ƕ�
slope_AB = (y2 - y3) / (x2 - x3);% ����AB�߶ε�б��
slope_BC = (y0 - y2) / (x0 - x2);% ����BC�߶ε�б��
slope_difference = atan((slope_BC - slope_AB) / (1 + slope_BC * slope_AB));% ����б�ʲ�ֵ
angle4 = abs(rad2deg(slope_difference));% ������ת��Ϊ�Ƕ�
%% �ָ�ָ���ж϶���
redimage = img(:,:,1);%ͼ��ҶȻ�
figure();
imshow(redimage);
title('R����ͼ��');
redimage=medfilt2(redimage,[7,7]);%��ֵ�˲�ȥ��
figure();
imshow(redimage);
title('��ֵ�˲�ͼ��ȥ��');
BW = im2bw(redimage);%ͼ���ֵ��
figure();
imshow(BW);
title('ָ���ֵ�����');
% se = strel('disk',3);
% BW = imopen(BW,se);
BW = bwareaopen(BW,100);%ȥ��С�������
figure();
imshow(BW);
title('��̬ѧ���');
ginf = bwmorph(BW, 'skeleton', Inf);%ָ��Ǽ���ȡ
ginf=bwmorph(ginf,'spur',3);%ȥ���Ǽ�ë��
figure();
imshow(ginf);
title('ָ��Ǽ���ȡ');
[m,n] = size(ginf);
figure();
%�����������ֱַ�ʶ��
for p=1:2
    if p ==1
        ginf1= ginf(1:m,1:round(n/2)-1);
    else
        ginf1= ginf(1:m,round(n/2)-1:n);
    end

    [H,T,R]= hough(ginf1,'ThetaRes',0.1,'RhoRes',1);%hough�任��ThetaRes��任���Ϊ1
    P=houghpeaks(H,8,'threshold',ceil(0.25*max(H(:))));%���ͶƱ������ƶ�8����������ֵΪ0.25*���ֵ
    hold on
    lines=houghlines(ginf1,T,R,P,'FillGap',9,'MinLength',45);%���ֱ�ߣ�С��15����ֱ�ߺϲ������ֱ����̳���102
    subplot(1,2,p),imshow(ginf1,[]),title('Hough�任�����'),
    hold on;
    distance = 0;%�����
    index = 1;
    %�ж�ָ���������ߣ����ܼ������ܶ��ߣ�ȡ�����Ϊָ��
    for k=1:length(lines)
        xy=[lines(k).point1;lines(k).point2];
        dis = norm([xy(1,1),xy(1,2)]-[xy(2,1),xy(2,2)]);%�߶ξ���
        if dis>distance
            distance = dis;
            index = k;
        end
        %         plot(xy(:,1),xy(:,2),'LineWidth',4,'Color',[.6 .7 .8]);
    end
    %�����߶�
    xy=[lines(index).point1;lines(index).point2];
    plot(xy(:,1),xy(:,2),'LineWidth',3,'Color','y');
    a=[lines(index).theta];%ȡ��struct��theta
    if p ==1%ת�ٱ�
        if a<0
            result = (90+a+(90-angle1))/(360-angle1-angle2)*8;
        else
            result = (a-angle1)/(360-angle1-angle2)*8;
        end
        disp(['����ת��Ϊ��' num2str(result) 'x1000 r/min']);
    else
        if a<0
            result = (90+a+(90-angle3))/(360-angle3-angle4)*240;
        else
            result = (a-angle3)/(360-angle3-angle4)*240;
        end
        if result<0
            result = 0;  
        end
         disp(['�����ٶ�Ϊ��' num2str(result) 'km/h']);
    end
end