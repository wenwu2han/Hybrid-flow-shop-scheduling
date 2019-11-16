function [Population_decode]=heuristic_decode(Population_decode,filenames,Disp1,Disp2)
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
load (filenames)

pop_size=size([Population_decode.rank],2);
total_ope_num=job_num*stage_num;


max_mach_rank=max(mach_set_stage{1,stage_num});
max_worker_rank=max(worker_set_stage(stage_num,:));
%% 读取工序O_ij的加工机器M_m和操作工人W_w以及加工时间
for i=1:pop_size
    chromosome=Population_decode(i).chromesome;
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
            if strcmp(Disp1,'LB')&&strcmp(Disp2,'EDD')
                [chrom_os_stage,chrom_ma_stage,chrom_wa_stage,pro_time_array,load_machine_cell,load_worker_cell,chrom_decode]=load_balancing_EDD(j,job_num,chrom_os_stage1,pro_time_array,load_machine_cell,load_worker_cell,chrom_decode,mach_set_stage,worker_set_stage,Basic_infor);
            elseif strcmp(Disp1,'FIMW')&&strcmp(Disp2,'EDD')
                [chrom_os_stage,chrom_ma_stage,chrom_wa_stage,pro_time_array,load_machine_cell,load_worker_cell,chrom_decode]=first_idle_mw_EDD(j,job_num,chrom_os_stage1,pro_time_array,load_machine_cell,load_worker_cell,chrom_decode,mach_set_stage,worker_set_stage,Basic_infor);
            elseif strcmp(Disp1,'LFMW')&&strcmp(Disp2,'EDD')
                [chrom_os_stage,chrom_ma_stage,chrom_wa_stage,pro_time_array,load_machine_cell,load_worker_cell,chrom_decode] = lastest_free_mw_EDD(j,job_num,chrom_os_stage1,pro_time_array,load_machine_cell,load_worker_cell,chrom_decode,mach_set_stage,worker_set_stage,Basic_infor);
            end
            if j ~= 1
                chrom_os((j-1)*job_num+1:j*job_num)=chrom_os_stage;
            end
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
        %% 解码个体的信息存储
        Population_decode(i).decode=chrom_decode.';
        %% 机器和工人加工信息的存储
        Population_decode(i).load_machine=load_machine_cell;
        Population_decode(i).load_worker=load_worker_cell;
    elseif Population_decode(i).cross_f
        chrom_os=chromosome(1,1:total_ope_num);                     %染色体的OS层
        chrom_ma=chromosome(1,total_ope_num+1:2*total_ope_num);     %染色体的MA层
        chrom_wa=chromosome(1,2*total_ope_num+1:3*total_ope_num);   %染色体的WA层
        load_machine_cell=cell(max_mach_rank,3);
        load_worker_cell=cell(max_worker_rank,3);
        chrom_decode=cell(1,total_ope_num);
        pro_time_array=zeros(3,total_ope_num);
        for j=1:stage_num
            chrom_os_stage=chrom_os((j-1)*job_num+1:j*job_num);
            chrom_ma_stage=chrom_ma((j-1)*job_num+1:j*job_num);
            chrom_wa_stage=chrom_wa((j-1)*job_num+1:j*job_num);
            [pro_time_array,load_machine_cell,load_worker_cell,chrom_decode]=decodef(j,job_num,chrom_os_stage,pro_time_array,load_machine_cell,load_worker_cell,chrom_decode,mach_set_stage,worker_set_stage,chrom_ma_stage,chrom_wa_stage,Basic_infor);
        end
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
        %% 解码个体的信息存储
        Population_decode(i).decode=chrom_decode.';
        %% 机器和工人加工信息的存储
        Population_decode(i).load_machine=load_machine_cell;
        Population_decode(i).load_worker=load_worker_cell;
        
        Population_decode(i).cross_f=false;
    end
end
end