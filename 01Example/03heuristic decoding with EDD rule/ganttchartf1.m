function ganttchartf1(individul)
%绘制甘特图
load AAA_t0105×3.mat
chrom_decode_one=individul.decode;
total_ope_num=size(chrom_decode_one,1);
%% 画甘特图
col=jet(job_num);                                                          %机器颜色的设定
rec=zeros(1,4);
for i=1:total_ope_num
    job_rank=chrom_decode_one{i,1}(1,1);                                   %取出工件号
    ope_rank=chrom_decode_one{i,1}(1,2);                                   %取出工序号
    ma_rank=chrom_decode_one{i,1}(1,3);                                    %取出机器号
    wo_rank=chrom_decode_one{i,1}(1,4);                                    %取出工人号
    ST_ope=chrom_decode_one{i,1}(1,6);                                    %取出该工序开始加工时间
    CT_ope=chrom_decode_one{i,1}(1,7);                                    %取出该工序结束加工时间
    rec(1)=ST_ope;                                                         %矩形的横坐标
    rec(2)=ma_rank-0.5;                                                    %矩形的纵坐标
    rec(3)=CT_ope-ST_ope;                                                  %矩形的x轴方向的长度
    rec(4)=0.9;
    rectangle('Position',rec,'LineWidth',1.5,'LineStyle','-','FaceColor',col(job_rank,:)); %draw every rectangle
    text(rec(1)+rec(3)*0.5-2,ma_rank+rec(4)/8,strcat('J',num2str(job_rank)),'fontsize',18,'FontName','Times New Roman');
    text(rec(1)+rec(3)*0.5-3,ma_rank-rec(4)/8,strcat('W',num2str(wo_rank)),'fontsize',18,'FontName','Times New Roman');
end
makespan=individul.objectives(1);
chrom_ma=individul.chromesome(total_ope_num+1:2*total_ope_num);
Machine_number=max(mach_set_stage{1,stage_num});
mach_info=cell(1,Machine_number);                                          %存储字符串变量，机器
for i=1:Machine_number
    num=i;
    str1='M';
    str=sprintf('%s%d',str1,num);
    mach_info{1,i}=str;
end
y=1:Machine_number;
x=0:0.1*makespan:makespan*1.001;
set(gca,'YTick',y);                                                       %设置y坐标轴的范围
set(gca,'XTick',x);
set(gca,'YTickLabel',mach_info);
set(gca,'FontName','Times New Roman','FontSize',18);
%% 做出makespan所在线
hold on
x1=makespan;
y=0:0.1:Machine_number;
plot(x1,y,'k.-');
hold on
x2=0:3:makespan;
y=zeros(1,stage_num);
for i=1:stage_num
    num=size(mach_set_stage{1,i},2);
    y(1,i)=mach_set_stage{1,i}(1,num)+0.5;
    plot(x2,y(1,i),'b.-');
end
end