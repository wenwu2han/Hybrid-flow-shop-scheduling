function [Population_decode]=decode1(pop_size,job_num,stage_num,mach_set_stage,worker_set_stage,Basic_infor,Population_home)
%染色体解码
%inputs
% pop_size:种群个体数
%stage_num：加工阶段数
%Worker_stage：每阶段工人数
% total_ope_num：每个个体的工序总数
%chrom_length：染色体长度
% Basic_infor:基本信息，包括：加工时间属性
%Population_home：种群

%outputs
%chrom_decode：调度方案(cell)
%每行有total_ope_num个元胞，每个元胞每列如下
%%第一列：记录工件号
%%第二列：记录加工阶段
%%第三列：记录机器选择
%%第四列：记录工人选择
%%第五列：记录加工时间
%%第六列：用以存储加工开始时间S_ij
%%第七列：用以存储加工开始时间E_ij

%Population_decode.objectives:调度方案目标值的记录在以下6列中
%第一列：makespan
%第二列：机器负荷平衡
%第三列：工人负荷平衡

Population_decode=Population_home;
total_ope_num=size(Population_decode(1).chromesome,2)/3;

max_mach_rank=max(mach_set_stage{1,stage_num});
max_worker_rank=max(worker_set_stage(stage_num,:));
%% 读取工序O_ij的加工机器M_m和操作工人W_w以及加工时间
for i=1:pop_size
    chromosome=Population_home(i).chromesome;
    if chromosome(job_num+1)==0
        chrom_os=chromosome(1:total_ope_num);
        chrom_ma=chromosome(total_ope_num+1:2*total_ope_num);
        chrom_wa=chromosome(2*total_ope_num+1:3*total_ope_num);
        load_machine_cell=cell(max_mach_rank,3);
        load_worker_cell=cell(max_worker_rank,3);
        chrom_decode=cell(1,total_ope_num);
        pro_time_array=zeros(3,total_ope_num);
        for j=1:stage_num
            if j==1
                chrom_os_stage1=chrom_os(1:j*job_num);
            end
            [chrom_ma_stage,chrom_wa_stage,pro_time_array,load_machine_cell,load_worker_cell,chrom_decode]=heuristic_decode1(j,job_num,chrom_os_stage1,pro_time_array,load_machine_cell,load_worker_cell,chrom_decode,mach_set_stage,worker_set_stage,Basic_infor);  %启发式规则为了确定机器和工人选择
            [~,index1]=sort(pro_time_array(2,(j-1)*job_num+1:j*job_num));%按照结束的先后次序
            %相当于正向标准化，同时为后续阶段的解码做准备
            pro_time_array(1,(j-1)*job_num+1:j*job_num)=pro_time_array(1,(j-1)*job_num+index1);
            pro_time_array(2,(j-1)*job_num+1:j*job_num)=pro_time_array(2,(j-1)*job_num+index1);
            pro_time_array(3,(j-1)*job_num+1:j*job_num)=pro_time_array(3,(j-1)*job_num+index1);
            chrom_os_stage1=pro_time_array(3,(j-1)*job_num+1:j*job_num);
            chrom_os((j-1)*job_num+1:j*job_num)=chrom_os_stage1;
            chrom_ma((j-1)*job_num+1:j*job_num)=chrom_ma_stage;
            chrom_wa((j-1)*job_num+1:j*job_num)=chrom_wa_stage;
        end
        
        Population_decode(i).chromesome(1:total_ope_num)=chrom_os;
        Population_decode(i).chromesome(total_ope_num+1:2*total_ope_num)=chrom_ma;
        Population_decode(i).chromesome(2*total_ope_num+1:3*total_ope_num)=chrom_wa;
        Population_decode(i).pro_time=pro_time_array;
       %% 求解两个目标值：makespan，total tardiness of all jobs
        makespan_mat=load_machine_cell(:,2);
        makespan=max(cell2mat(makespan_mat.'));                                %取最大完工时间
        Population_decode(i).objectives(1)=roundn(makespan,-4);                %最大完工时间目标
        
        tardiness_cell=load_machine_cell(mach_set_stage{1,stage_num},2:3);
        A=cellfun(@(x) x.',tardiness_cell, 'UniformOutput', false);
        tardiness_mat=cell2mat(A);
        tardiness_mat1=zeros(job_num,4);
        tardiness_mat1(:,1:2)=tardiness_mat;
        tardiness_mat1(:,3)=Basic_infor.due_time(tardiness_mat(:,2),1);
        tardiness_mat1(:,4)=tardiness_mat1(:,1)-tardiness_mat1(:,3);
        [IP,~,~]=find(tardiness_mat1(:,4)<0);
        tardiness_mat1(IP,4)=0;
        total_tardiness=sum(tardiness_mat1(:,4));
        Population_decode(i).objectives(2)=roundn(total_tardiness,-4);                %总延期时间
        
        
        
        %% 机器负荷平衡、工人负荷平衡
        %workload_balance_array
        %第一行：机器负荷
        %第二行：工人负荷
        workload_balance_array=zeros(2,stage_num);
        for ss=1:stage_num
            %机器
            mach_set=mach_set_stage{1,ss};
            num_machine=size(mach_set,2);
            workload_mach=zeros(1,num_machine);
            for mm=1:num_machine
                CT_ma=load_machine_cell{mach_set(1,mm),2};
                ST_ma=load_machine_cell{mach_set(1,mm),1};
                pro_ma=CT_ma-ST_ma;
                workload_mach(1,mm)=sum(pro_ma);
            end
            sumload_ma=sum(workload_mach);
            meanload_ma=sumload_ma/num_machine;
            squload_ma=(workload_mach-meanload_ma).^2;
            workload_balance_array(1,ss)=sum(squload_ma);
            %工人
            worker_set=worker_set_stage(ss,:);
            num_worker=size(worker_set,2);
            workload_wo=zeros(1,num_worker);
            for ww=1:num_worker
                CT_wo=load_worker_cell{worker_set(1,ww),2};
                ST_wo=load_worker_cell{worker_set(1,ww),1};
                pro_wo=CT_wo-ST_wo;
                workload_wo(1,ww)=sum(pro_wo);
            end
            sumload_wo=sum(workload_wo);
            meanload_wo=sumload_wo/num_worker;
            squload_wo=(workload_wo-meanload_wo).^2;
            workload_balance_array(2,ss)=sum(squload_wo);
            
        end
        workload_balance_ma=sum(workload_balance_array(1,:));
        Population_decode(i).load_inbalance_ma=workload_balance_ma^(1/2);                %机器负荷平衡
        workload_balance_wo=sum(workload_balance_array(2,:));
        Population_decode(i).load_inbalance_wo=workload_balance_wo^(1/2);                %工人负荷平衡
        
        %% 解码个体的信息存储
        Population_decode(i).decode=chrom_decode.';
        %% 机器和工人加工信息的存储
        Population_decode(i).load_machine=load_machine_cell;
        Population_decode(i).load_worker=load_worker_cell;
    end
end
end