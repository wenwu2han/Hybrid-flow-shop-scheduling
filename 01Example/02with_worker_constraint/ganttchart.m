%绘制甘特图
%inputs
%chrom_decode_one：一个通过染色体解码得到的个体
%total_ope_num:总工序个数
%object_record:调度方案目标值的记录
%Population:种群

load resultt0105×2I4_all.mat
load AAA_t0105×2.mat
solution=3;
chrom_decode_one=Population_child_all(solution).decode;
total_ope_num=size(chrom_decode_one,1);
%% 画甘特图 
col=jet(job_num);                                                          %机器颜色的设定                                    
rec=zeros(1,4);
complete_array=zeros(2,job_num);
for i=1:total_ope_num
    job_rank=chrom_decode_one{i,1}(1,1);                                   %取出工件号
    ope_rank=chrom_decode_one{i,1}(1,2);                                   %取出工序号
    ma_rank=chrom_decode_one{i,1}(1,3);                                    %取出机器号
    wo_rank=chrom_decode_one{i,1}(1,4);                                    %取出工人号
    ST_ope=chrom_decode_one{i,1}(1,6);                                    %取出该工序开始加工时间
    CT_ope=chrom_decode_one{i,1}(1,7);                                    %取出该工序结束加工时间
    if i>job_num
        complete_array(1,i-job_num)=CT_ope;
        complete_array(2,i-job_num)=ma_rank;
    end
    rec(1)=ST_ope;                                                         %矩形的横坐标
    rec(2)=ma_rank-0.5;                                                    %矩形的纵坐标
    rec(3)=CT_ope-ST_ope;                                                  %矩形的x轴方向的长度
    rec(4)=0.9;
    rectangle('Position',rec,'LineWidth',1.5,'LineStyle','-','FaceColor',col(job_rank,:)); %draw every rectangle
    text(rec(1)+0.2,ma_rank+rec(4)/4,strcat('O',num2str(job_rank),',',strcat(num2str(ope_rank))),'fontsize',20,'FontName','Times New Roman');
    text(rec(1)+0.2,ma_rank-rec(4)/4,strcat('(','W',num2str(wo_rank),')'),'fontsize',20,'FontName','Times New Roman');
end
makespan=Population_child_all(solution).objectives(1);
chrom_ma=Population_child_all(solution).chromesome(total_ope_num+1:2*total_ope_num);


Machine_number=max(mach_set_stage{1,stage_num});
mach_info=cell(1,Machine_number);                                          %存储字符串变量，机器
for i=1:Machine_number
    num=i;
    str1='M';
    str=sprintf('%s%d',str1,num);
    mach_info{1,i}=str;
end
y=1:Machine_number;
x=0:0.1*makespan:makespan*1.1;
set(gca,'YTick',y);                                                       %设置y坐标轴的范围
set(gca,'XTick',x);  
set(gca,'YTickLabel',mach_info);
                                                                                                                                                    
%% 做出makespan所在线
XTick_array=[];
XTick_array(end+1)=makespan;
hold on
x1=makespan;
y=0:0.1:Machine_number+0.5;
plot(x1,y,'k.-');
hold on
for i=1:job_num
    CT=complete_array(1,i);
    y1=complete_array(2,i):0.05:Machine_number+0.5;
    plot(CT,y1,'b.-');
    due_time=Basic_infor.due_time(i,1);
    XTick_array(end+1)=due_time;
    y2=0:0.05:Machine_number+0.5;
    plot(due_time,y2,'b.-');
end
XTick_array=sort(XTick_array,2);
XTick_array(end-1)=[];
XTick_array=ceil(XTick_array);
set(gca,'XTick',XTick_array);

x2=0:2.5:XTick_array(end);
y=zeros(1,stage_num);
for i=1:stage_num
    num=size(mach_set_stage{1,i},2);
    y(1,i)=mach_set_stage{1,i}(1,num)+0.5;
    plot(x2,y(1,i),'b.-');
end
set(gca,'FontName','Times New Roman','FontSize',18,'LineWidth',1.5);