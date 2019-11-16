function [chrom_os_stage,chrom_ma_stage,chrom_wa_stage,pro_time_array,load_machine_cell,load_worker_cell,chrom_decode] = load_balancing_EDD(stage_rank,job_num,chrom_os_stage1,pro_time_array,load_machine_cell,load_worker_cell,chrom_decode,mach_set_stage,worker_set_stage,Basic_infor)
% load balancing rule for machine assignment and worker assignment
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
chrom_os_stage=zeros(1,job_num);
chrom_ma_stage=zeros(1,job_num);
chrom_wa_stage=zeros(1,job_num);
if stage_rank ==1
    for jj=1:job_num
        chrom_os_stage = chrom_os_stage1;
        job_rank=chrom_os_stage(1,jj);
        T_ready=0;
        oper_time_ma=zeros(2,m);
        oper_time_ma(1,:)=mach_set;
        oper_time_ma(2,:)=time_table_ma(1,:);
        [~,row_ma]=min(oper_time_ma(2,:));
        mach_rank=oper_time_ma(1,row_ma);
        chrom_ma_stage(1,job_rank)=mach_rank;
        
        oper_time_wo=zeros(2,w);
        oper_time_wo(1,:)=worker_set;
        oper_time_wo(2,:)=time_table_wo(1,:);
        [~,row_wo]=min(oper_time_wo(2,:));
        worker_rank=oper_time_wo(1,row_wo);
        chrom_wa_stage(1,job_rank)=worker_rank;
        %更新机器、工人加工时间表
        pro_time=pro_time_mat(job_rank,(mach_rank-max_mach_rank-1)*w+1);
        time_table_ma(1,mach_rank-max_mach_rank)=time_table_ma(1,mach_rank-max_mach_rank)+pro_time;
        time_table_wo(1,worker_rank-max_worker_rank)=time_table_wo(1,worker_rank-max_worker_rank)+pro_time;
        
        chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,1)=job_rank;
        chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,2)=stage_rank;
        chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,3)=mach_rank;
        chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,4)=worker_rank;
        chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,5)=pro_time;
        
        if isempty(load_machine_cell{mach_rank,1})
            CT_ma = 0;
            if isempty(load_worker_cell{worker_rank,1})
                CT_wa = 0;
            else
                CT_wa = load_worker_cell{worker_rank,2}(end);
            end
        elseif isempty(load_worker_cell{worker_rank,1})
            CT_wa = 0;
            if isempty(load_machine_cell{mach_rank,1})
                CT_ma = 0;
            else
                CT_ma = load_machine_cell{mach_rank,2}(end);
            end
        else
            CT_ma = load_machine_cell{mach_rank,2}(end);
            CT_wa = load_worker_cell{worker_rank,2}(end);
        end
        ET_oper=max([T_ready,CT_ma,CT_wa]);          %获取工序的最早加工时间
        chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,6)=ET_oper;                                 %存储工序开始加工时间
        pro_time_array(1,(stage_rank-1)*job_num+job_rank)=ET_oper;
        chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,7)=ET_oper+pro_time;                        %存储工序完成加工时间
        pro_time_array(2,(stage_rank-1)*job_num+job_rank)=ET_oper+pro_time;
        pro_time_array(3,(stage_rank-1)*job_num+job_rank)=job_rank;
        
        col_ma=size(load_machine_cell{mach_rank,1},2);
        col_wo=size(load_worker_cell{worker_rank,1},2);
        load_machine_cell{mach_rank,1}(1,col_ma+1)=ET_oper;                    %更新机器、工人加工起始时间
        load_machine_cell{mach_rank,2}(1,col_ma+1)=ET_oper+pro_time;
        load_machine_cell{mach_rank,3}(1,col_ma+1)=job_rank;
        
        load_worker_cell{worker_rank,1}(1,col_wo+1)=ET_oper;
        load_worker_cell{worker_rank,2}(1,col_wo+1)=ET_oper+pro_time;
        load_worker_cell{worker_rank,3}(1,col_wo+1)=job_rank;
    end
else
    pro_time_array1 = pro_time_array(:,(stage_rank-2)*job_num+1:(stage_rank-1)*job_num);
    for jj=1:job_num
        oper_time_ma=zeros(2,m);
        oper_time_ma(1,:)=mach_set;
        oper_time_ma(2,:)=time_table_ma(1,:);
        [~,row_ma]=min(oper_time_ma(2,:));
        mach_rank=oper_time_ma(1,row_ma);
        
        oper_time_wo=zeros(2,w);
        oper_time_wo(1,:)=worker_set;
        oper_time_wo(2,:)=time_table_wo(1,:);
        [~,row_wo]=min(oper_time_wo(2,:));
        worker_rank=oper_time_wo(1,row_wo);
        
        if isempty(load_machine_cell{mach_rank,1})
            CT_ma = 0;
            if isempty(load_worker_cell{worker_rank,1})
                CT_wa = 0;
            else
                CT_wa = load_worker_cell{worker_rank,2}(end);
            end
        elseif isempty(load_worker_cell{worker_rank,1})
            CT_wa = 0;
            if isempty(load_machine_cell{mach_rank,1})
                CT_ma = 0;
            else
                CT_ma = load_machine_cell{mach_rank,2}(end);
            end
        else
            CT_ma = load_machine_cell{mach_rank,2}(end);
            CT_wa = load_worker_cell{worker_rank,2}(end);
        end
        ET_oper=max([CT_ma,CT_wa]);          %获取工序的最早加工时间
        [~, col]=find(pro_time_array1(2,:)<=ET_oper);
        if size(col,2)>1
            select_job = [];
            select_job(1,:) = pro_time_array1(3,col);
            select_job(2,:) = Basic_infor.due_time(col,1)';
            [~,col3] = min(select_job(2,:));
            p = col3;
        elseif size(col,2)==1
            p = col;
        elseif isempty(col)
            ET_oper = pro_time_array1(2,1);
            [~,col1] = find(pro_time_array1(2,:)==ET_oper);
            if size(col1,2)==1
                p = col1;
            else
                select_job = [];
                select_job(1,:) = pro_time_array1(3,col1);
                select_job(2,:) = Basic_infor.due_time(col1,1)';
                [~,col2] = min(select_job(2,:));
                p = col2;
            end
        end
        job_rank = pro_time_array1(3,p);
        pro_time_array1(:,p) = [];
        
        chrom_os_stage(1,jj)=job_rank;
        chrom_ma_stage(1,job_rank)=mach_rank;
        chrom_wa_stage(1,job_rank)=worker_rank;
        
        pro_time=pro_time_mat(job_rank,(mach_rank-max_mach_rank-1)*w+1);
        time_table_ma(1,mach_rank-max_mach_rank)=time_table_ma(1,mach_rank-max_mach_rank)+pro_time;
        time_table_wo(1,worker_rank-max_worker_rank)=time_table_wo(1,worker_rank-max_worker_rank)+pro_time;
        chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,1)=job_rank;
        chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,2)=stage_rank;
        chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,3)=mach_rank;
        chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,4)=worker_rank;
        chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,5)=pro_time;
        
        chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,6)=ET_oper;                                 %存储工序开始加工时间
        pro_time_array(1,(stage_rank-1)*job_num+job_rank)=ET_oper;
        chrom_decode{1,(stage_rank-1)*job_num+job_rank}(1,7)=ET_oper+pro_time;                        %存储工序完成加工时间
        pro_time_array(2,(stage_rank-1)*job_num+job_rank)=ET_oper+pro_time;
        pro_time_array(3,(stage_rank-1)*job_num+job_rank)=job_rank;
        
        col_ma=size(load_machine_cell{mach_rank,1},2);
        col_wo=size(load_worker_cell{worker_rank,1},2);
        load_machine_cell{mach_rank,1}(1,col_ma+1)=ET_oper;                    %更新机器、工人加工起始时间
        load_machine_cell{mach_rank,2}(1,col_ma+1)=ET_oper+pro_time;
        load_machine_cell{mach_rank,3}(1,col_ma+1)=job_rank;
        
        load_worker_cell{worker_rank,1}(1,col_wo+1)=ET_oper;
        load_worker_cell{worker_rank,2}(1,col_wo+1)=ET_oper+pro_time;
        load_worker_cell{worker_rank,3}(1,col_wo+1)=job_rank;
    end
end
[~,index1] = sort(pro_time_array(2,(stage_rank-1)*job_num+1:stage_rank*job_num));%按照结束的先后次序
pro_time_array(1,(stage_rank-1)*job_num+1:stage_rank*job_num) = pro_time_array(1,(stage_rank-1)*job_num+index1);
pro_time_array(2,(stage_rank-1)*job_num+1:stage_rank*job_num) = pro_time_array(2,(stage_rank-1)*job_num+index1);
pro_time_array(3,(stage_rank-1)*job_num+1:stage_rank*job_num) = pro_time_array(3,(stage_rank-1)*job_num+index1);
end