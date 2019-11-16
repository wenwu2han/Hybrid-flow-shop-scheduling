function [chrom_ma_stage,chrom_wa_stage,pro_time_array,load_machine_cell,load_worker_cell,chrom_decode]=heuristic_decode1(stage_rank,job_num,chrom_os_stage1,pro_time_array,load_machine_cell,load_worker_cell,chrom_decode,mach_set_stage,worker_set_stage,Basic_infor)
%设计启发式规则编码并解码
mach_set=mach_set_stage{1,stage_rank};
m=size(mach_set,2);
worker_set=worker_set_stage(stage_rank,:);
w=size(worker_set,2);
if stage_rank==1
    max_mach_rank=0;
    max_worker_rank=0;
else
    max_mach_rank=max(mach_set_stage{1,stage_rank-1});
    max_worker_rank=max(worker_set_stage(stage_rank-1,:));
end
pro_time_mat=Basic_infor.pro_time(:,max_mach_rank*w+1:max_mach_rank*w+m*w);
%建立机器、工人加工时间表
time_table_ma=zeros(1,m);
time_table_wo=zeros(1,w);
chrom_ma_stage=zeros(1,job_num);
chrom_wa_stage=zeros(1,job_num);
for jj=1:job_num
    job_rank=chrom_os_stage1(1,jj);
    if stage_rank==1
        CT_pre=0;
    else
        CT_pre=pro_time_array(2,(stage_rank-2)*job_num+jj);
    end
    oper_time_ma=zeros(2,m);
    oper_time_ma(1,:)=mach_set;
    time_ma=zeros(1,m);
    for ii=1:m
        time_ma(1,ii)=sum(pro_time_mat(job_rank,(ii-1)*w+1:ii*w));
    end
    oper_time_ma(2,:)=time_ma(1,:)+time_table_ma(1,:);
    [~,row_ma]=min(oper_time_ma(2,:));
    mach_rank=oper_time_ma(1,row_ma);
    chrom_ma_stage(1,job_rank)=mach_rank;
    
    oper_time_wo=zeros(2,w);
    oper_time_wo(1,:)=worker_set;
    time_wo=pro_time_mat(job_rank,(mach_rank-max_mach_rank-1)*w+1:(mach_rank-max_mach_rank)*w);
    oper_time_wo(2,:)=time_wo(1,:)+time_table_wo(1,:);
    [~,row_wo]=min(oper_time_wo(2,:));
    worker_rank=oper_time_wo(1,row_wo);
    chrom_wa_stage(1,job_rank)=worker_rank;
    %更新机器、工人加工时间表
    pro_time=time_wo(1,row_wo);
    time_table_ma(1,mach_rank-max_mach_rank)=time_table_ma(1,mach_rank-max_mach_rank)+pro_time;
    time_table_wo(1,worker_rank-max_worker_rank)=time_table_ma(1,worker_rank-max_worker_rank)+pro_time;
    
    chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,1)=job_rank;
    chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,2)=stage_rank;
    chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,3)=mach_rank;
    chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,4)=worker_rank;
    chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,5)=pro_time;
    
    if isempty(load_machine_cell{mach_rank,1})&&isempty(load_machine_cell{worker_rank,1})%读取机器/工人上的空闲时间（start idle time in machine/worker & completed idle time in machine/worker）
        ST_ma=CT_pre;
        CT_ma=inf;
        ST_wo=CT_pre;
        CT_wo=inf;
        chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,6)=ST_ma;                                 %存储工序开始加工时间
        pro_time_array(1,(stage_rank-1)*job_num+job_rank)=ST_ma;
        chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,7)=ST_ma+pro_time;                        %存储工序完成加工时间
        pro_time_array(2,(stage_rank-1)*job_num+job_rank)=ST_ma+pro_time;
        pro_time_array(3,(stage_rank-1)*job_num+job_rank)=job_rank;
        load_machine_cell{mach_rank,1}(1,1)=ST_ma;                             %更新机器、工人加工起始时间
        load_machine_cell{mach_rank,2}(1,1)=ST_ma+pro_time;
        load_machine_cell{mach_rank,3}(1,1)=job_rank;
        load_worker_cell{worker_rank,1}(1,1)=ST_wo;
        load_worker_cell{worker_rank,2}(1,1)=ST_ma+pro_time;
        load_worker_cell{worker_rank,3}(1,1)=job_rank;
    else
        ST_ma=[];
        CT_ma=[];
        ST_wo=[];
        CT_wo=[];
        col_ma=size(load_machine_cell{mach_rank,1},2);
        col_wo=size(load_worker_cell{worker_rank,1},2);
        if col_ma<2&&col_wo<2
            ST_ma(1,1)=0;
            ST_wo(1,1)=0;
            if col_ma==0
                CT_ma(1,1)=inf;
            else
                CT_ma(1,1)=load_machine_cell{mach_rank,1}(1,1);
                ST_ma(1,2)=load_machine_cell{mach_rank,2}(1,1);
                CT_ma(1,2)=inf;
            end
            if col_wo==0
                CT_wo(1,1)=inf;
            else
                CT_wo(1,1)=load_worker_cell{worker_rank,1}(1,1);
                ST_wo(1,2)=load_worker_cell{worker_rank,2}(1,1);
                CT_wo(1,2)=inf;
            end
        elseif col_ma<2&&col_wo>=2
            ST_wo(1,1)=0;
            ST_wo(1,2:col_wo+1)=load_worker_cell{worker_rank,2}(1,1:col_wo);
            CT_wo(1,1:col_wo)=load_worker_cell{worker_rank,1}(1,1:col_wo);
            CT_wo(1,col_wo+1)=inf;
            
            ST_ma(1,1)=0;
            if col_ma==0
                CT_ma(1,1)=inf;
            else
                CT_ma(1,1)=load_machine_cell{mach_rank,1}(1,1);
                ST_ma(1,2)=load_machine_cell{mach_rank,2}(1,1);
                CT_ma(1,2)=inf;
            end
        elseif col_ma>=2&&col_wo<2
            ST_ma(1,1)=0;
            ST_ma(1,2:col_ma+1)=load_machine_cell{mach_rank,2}(1,1:col_ma);
            CT_ma(1,1:col_ma)=load_machine_cell{mach_rank,1}(1,1:col_ma);
            CT_ma(1,col_ma+1)=inf;
            
            ST_wo(1,1)=0;
            if col_wo==0
                CT_wo(1,1)=inf;
            else
                CT_wo(1,1)=load_worker_cell{worker_rank,1}(1,1);
                ST_wo(1,2)=load_worker_cell{worker_rank,2}(1,1);
                CT_wo(1,2)=inf;
            end
        else
            ST_ma(1,1)=0;
            ST_ma(1,2:col_ma+1)=load_machine_cell{mach_rank,2}(1,1:col_ma);
            CT_ma(1,1:col_ma)=load_machine_cell{mach_rank,1}(1,1:col_ma);
            CT_ma(1,col_ma+1)=inf;
            ST_wo(1,1)=0;
            ST_wo(1,2:col_wo+1)=load_worker_cell{worker_rank,2}(1,1:col_wo);
            CT_wo(1,1:col_wo)=load_worker_cell{worker_rank,1}(1,1:col_wo);
            CT_wo(1,col_wo+1)=inf;
        end
        col1=size(ST_ma,2);
        col2=size(ST_wo,2);
        flag=1;
        array_ST=[];
        array_CT=[];
        for k=1:col1
            for kk=1:col2
                ET_oper=max([CT_pre,ST_ma(1,k),ST_wo(1,kk)]);          %获取工序的最早加工时间
                CT=min([CT_ma(1,k),CT_wo(1,kk)]);                      %获取工序的最晚结束时间
                if ET_oper+pro_time<=CT
                    array_ST(1,flag)=ET_oper;
                    array_CT(1,flag)=ET_oper+pro_time;
                    flag=flag+1;
                end
            end
        end
        ET_oper=min(array_ST);
        chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,6)=ET_oper;
        pro_time_array(1,(stage_rank-1)*job_num+job_rank)=ET_oper;
        chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,7)=ET_oper+pro_time;                      %存储工序完成加工时间
        pro_time_array(2,(stage_rank-1)*job_num+job_rank)=ET_oper+pro_time;
        pro_time_array(3,(stage_rank-1)*job_num+job_rank)=job_rank;
        load_machine_cell{mach_rank,1}(1,col_ma+1)=ET_oper;                    %更新机器、工人加工起始时间
        load_machine_cell{mach_rank,2}(1,col_ma+1)=ET_oper+pro_time;
        load_machine_cell{mach_rank,3}(1,col_ma+1)=job_rank;
        [load_machine_cell{mach_rank,1},index]=sort(load_machine_cell{mach_rank,1});
        load_machine_cell{mach_rank,2}=load_machine_cell{mach_rank,2}(index);
        load_machine_cell{mach_rank,3}=load_machine_cell{mach_rank,3}(index);
        
        load_worker_cell{worker_rank,1}(1,col_wo+1)=ET_oper;
        load_worker_cell{worker_rank,2}(1,col_wo+1)=ET_oper+pro_time;
        load_worker_cell{worker_rank,3}(1,col_wo+1)=job_rank;
        [~,index]=sort(load_worker_cell{worker_rank,1});
        load_worker_cell{worker_rank,1}=load_worker_cell{worker_rank,1}(index);
        load_worker_cell{worker_rank,2}=load_worker_cell{worker_rank,2}(index);
        load_worker_cell{worker_rank,3}=load_worker_cell{worker_rank,3}(index);
    end
end
end