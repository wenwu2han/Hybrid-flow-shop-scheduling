function [chrom_ma_stage,chrom_wa_stage,pro_time_array,load_machine_cell,load_worker_cell,chrom_decode] = first_idle_mw(stage_rank,job_num,chrom_os_stage1,pro_time_array,load_machine_cell,load_worker_cell,chrom_decode,mach_set_stage,worker_set_stage,Basic_infor)
% first idle machine or worker for the machine assignment or the worker assignment
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
chrom_ma_stage=zeros(1,job_num);
chrom_wa_stage=zeros(1,job_num);

idle_time_m = zeros(2,m);
idle_time_w = zeros(2,w);
pro_time_mat=Basic_infor.pro_time(:,max_mach_rank*w+1:max_mach_rank*w+m*w);

for jj=1:job_num
    job_rank=chrom_os_stage1(1,jj);
    if stage_rank==1
        CT_pre=0;
    else
        CT_pre=pro_time_array(2,(stage_rank-2)*job_num+jj);
    end
    for k = 1:m
        idle_time_m(1,k) = max_mach_rank+k;
        if isempty(load_machine_cell{max_mach_rank+k,2})
            CT_ma1 = 0;
        else
            CT_ma1 = load_machine_cell{max_mach_rank+k,2}(end);
        end
        idle_time_m(2,k) = CT_ma1;
    end
    [~,col_ma] = min(idle_time_m(2,:));
    mach_rank = idle_time_m(1,col_ma);
    CT_ma = idle_time_m(2,col_ma);
    chrom_ma_stage(1,job_rank)=mach_rank;
    
    for s = 1:w
        idle_time_w(1,s) = max_worker_rank + s;
        if isempty(load_worker_cell{max_worker_rank + s,2})
            CT_wa1 = 0;
        else
            CT_wa1 = load_worker_cell{max_worker_rank + s,2}(end);
        end
        idle_time_w(2,s) = CT_wa1;
    end
    [~,col_wa] = min(idle_time_w(2,:));
    worker_rank = idle_time_w(1,col_wa);
    CT_wa = idle_time_w(2,col_wa);
    chrom_wa_stage(1,job_rank)=worker_rank;
    
    pro_time = pro_time_mat(job_rank,(mach_rank-max_mach_rank-1)*w+worker_rank-max_worker_rank);
    ET_oper=max([CT_pre,CT_ma,CT_wa]);          %获取工序的最早加工时间
    
    chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,1)=job_rank;
    chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,2)=stage_rank;
    chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,3)=mach_rank;
    chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,4)=worker_rank;
    chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,5)=pro_time;
    chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,6)=ET_oper;                                 %存储工序开始加工时间
    chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,7)=ET_oper+pro_time;                        %存储工序完成加工时间
    
    pro_time_array(1,(stage_rank-1)*job_num+job_rank)=ET_oper;
    pro_time_array(2,(stage_rank-1)*job_num+job_rank)=ET_oper+pro_time;
    pro_time_array(3,(stage_rank-1)*job_num+job_rank)=job_rank;
    
    num_ma=size(load_machine_cell{mach_rank,1},2);
    num_wo=size(load_worker_cell{worker_rank,1},2);
    load_machine_cell{mach_rank,1}(1,num_ma+1)=ET_oper;                    %更新机器、工人加工起始时间
    load_machine_cell{mach_rank,2}(1,num_ma+1)=ET_oper+pro_time;
    load_machine_cell{mach_rank,3}(1,num_ma+1)=job_rank;
    
    load_worker_cell{worker_rank,1}(1,num_wo+1)=ET_oper;
    load_worker_cell{worker_rank,2}(1,num_wo+1)=ET_oper+pro_time;
    load_worker_cell{worker_rank,3}(1,num_wo+1)=job_rank;
end
end