function [Population_decode]=decode(pop_size,job_num,stage_num,mach_set_stage,Basic_infor,Population_home)
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
%第二列：total tardiness of all jobs

Population_decode=Population_home;
total_ope_num=size(Population_decode(1).chromesome,2)/3;
chrom_decode=cell(pop_size,total_ope_num);
max_mach_rank=max(mach_set_stage{1,stage_num});
%% 读取工序O_ij的加工机器M_m和操作工人W_w以及加工时间
for i=1:pop_size
    
    chromesome=Population_home(i).chromesome;                    %取种群中的一条染色体操作
    chrom_os=chromesome(1,1:total_ope_num);                     %染色体的OS层
    chrom_ma=chromesome(1,total_ope_num+1:2*total_ope_num);     %染色体的MA层
    
    for ii=1:stage_num
        chrom_os_stage=chrom_os((ii-1)*job_num+1:ii*job_num);
        chrom_ma_stage=chrom_ma((ii-1)*job_num+1:ii*job_num);
        for jj=1:job_num
            job_rank=chrom_os_stage(jj);
            chrom_decode{i,(ii-1)*job_num+jj}(1,1)=job_rank;
            chrom_decode{i,(ii-1)*job_num+jj}(1,2)=ii;
            chrom_decode{i,(ii-1)*job_num+jj}(1,3)=chrom_ma_stage(job_rank);
            chrom_decode{i,(ii-1)*job_num+jj}(1,4)=Basic_infor.pro_time(job_rank,chrom_ma_stage(job_rank));
            chrom_decode{i,(ii-1)*job_num+jj}(1,5)=0;                               %用以存储加工开始时间S_ij
            chrom_decode{i,(ii-1)*job_num+jj}(1,6)=0;                               %用以存储加工结束时间C_ij
        end
        
    end
    pro_time_ma=cell(max_mach_rank,4);                                     %用来记录机器、工人的工作时间——开始时间（第一列）和结束时间（第二列）、及对应的工件号（第三列）和工序号（第四列）
    pro_time_oper=zeros(2,total_ope_num);                                  %用于存储每道工序的开始和结束加工时间
   
    
    %% 找到各工序的加工开始时间和加工结束时间
    for j=1:total_ope_num
        job_rank=chrom_decode{i,j}(1,1);                                   %读取工件号（job rank）
        ope_rank=chrom_decode{i,j}(1,2);                                   %读取工序号（operation rank）
        ma_rank=chrom_decode{i,j}(1,3);                                    %读取机器号（machine rank）
        
        pro_time=chrom_decode{i,j}(1,4);                                   %读取工序的加工时间
        if ope_rank==1                                                     %读取上一道工序的结束时间（completed time of prevent process）
            CT_pre=0;
        else
            [~,IP]=find(chrom_os==job_rank,ope_rank-1);
            CT_pre=chrom_decode{i,IP(ope_rank-1)}(1,6);
        end
        if isempty(pro_time_ma{ma_rank,1})%读取机器/工人上的空闲时间（start idle time in machine/worker & completed idle time in machine/worker）
            ST_ma=CT_pre;
            CT_ma=inf;
            chrom_decode{i,j}(1,5)=ST_ma;                                 %存储工序开始加工时间
            pro_time_oper(1,j)=ST_ma;
            chrom_decode{i,j}(1,6)=ST_ma+pro_time;                        %存储工序完成加工时间
            pro_time_oper(2,j)=ST_ma+pro_time;
            pro_time_ma{ma_rank,1}(1,1)=ST_ma;                             %更新机器、工人加工起始时间
            pro_time_ma{ma_rank,2}(1,1)=ST_ma+pro_time;
            pro_time_ma{ma_rank,3}(1,1)=job_rank;
            pro_time_ma{ma_rank,4}(1,1)=ope_rank;
        else
            ST_ma=[];
            CT_ma=[];
            
            col_ma=size(pro_time_ma{ma_rank,1},2);
            if col_ma<2
                ST_ma(1,1)=0;
                if col_ma==0
                    CT_ma(1,1)=inf;
                else
                    CT_ma(1,1)=pro_time_ma{ma_rank,1}(1,1);
                    ST_ma(1,2)=pro_time_ma{ma_rank,2}(1,1);
                    CT_ma(1,2)=inf;
                end
            elseif col_ma>=2
                ST_ma(1,1)=0;
                ST_ma(1,2:col_ma+1)=pro_time_ma{ma_rank,2}(1,1:col_ma);
                CT_ma(1,1:col_ma)=pro_time_ma{ma_rank,1}(1,1:col_ma);
                CT_ma(1,col_ma+1)=inf;
            end
            col1=size(ST_ma,2);
            flag=1;
            array_ST=[];
            array_CT=[];
            for k=1:col1
                
                ET_oper=max([CT_pre,ST_ma(1,k)]);          %获取工序的最早加工时间
                CT=min([CT_ma(1,k)]);                      %获取工序的最晚结束时间
                if ET_oper+pro_time<=CT
                    array_ST(1,flag)=ET_oper;
                    array_CT(1,flag)=ET_oper+pro_time;
                    flag=flag+1;
                end
                
            end
            ET_oper=min(array_ST);
            chrom_decode{i,j}(1,5)=ET_oper;
            pro_time_oper(1,j)=ET_oper;
            chrom_decode{i,j}(1,6)=ET_oper+pro_time;                      %存储工序完成加工时间
            pro_time_oper(2,j)=ET_oper+pro_time;
            pro_time_ma{ma_rank,1}(1,col_ma+1)=ET_oper;                    %更新机器、工人加工起始时间
            pro_time_ma{ma_rank,2}(1,col_ma+1)=ET_oper+pro_time;
            pro_time_ma{ma_rank,3}(1,col_ma+1)=job_rank;
            pro_time_ma{ma_rank,4}(1,col_ma+1)=ope_rank;
            [pro_time_ma{ma_rank,1},index]=sort(pro_time_ma{ma_rank,1});
            pro_time_ma{ma_rank,2}=pro_time_ma{ma_rank,2}(index);
            pro_time_ma{ma_rank,3}=pro_time_ma{ma_rank,3}(index);
            pro_time_ma{ma_rank,4}=pro_time_ma{ma_rank,4}(index);
            
        end
    end
    Population_decode(i).pro_time=pro_time_oper;
    %% 求解两个目标值：makespan，total tardiness of all jobs
    makespan_mat=pro_time_ma(:,2);
    makespan=max(cell2mat(makespan_mat.'));                                %取最大完工时间
    Population_decode(i).objectives(1)=roundn(makespan,-4);                %最大完工时间目标
    
    tardiness_cell=pro_time_ma(mach_set_stage{1,stage_num},2:3);
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
    workload_balance_array=zeros(2,stage_num);
    for ss=1:stage_num
        %机器
        mach_set=mach_set_stage{1,ss};
        num_machine=size(mach_set,2);
        workload_mach=zeros(1,num_machine);
        for mm=1:num_machine
            CT_ma=pro_time_ma{mach_set(1,mm),2};
            ST_ma=pro_time_ma{mach_set(1,mm),1};
            pro_ma=CT_ma-ST_ma;
            workload_mach(1,mm)=sum(pro_ma);
        end
        sumload_ma=sum(workload_mach);
        meanload_ma=sumload_ma/num_machine;
        squload_ma=(workload_mach-meanload_ma).^2;
        workload_balance_array(1,ss)=sum(squload_ma);
        
    end
    workload_balance_ma=sum(workload_balance_array(1,:));
    Population_decode(i).load_inbalance_ma=workload_balance_ma^(1/2);                %机器负荷平衡
    
    %% 解码个体的信息存储
    Population_decode(i).decode=chrom_decode(i,:).';
    %% 机器和工人加工信息的存储
    Population_decode(i).load_machine=pro_time_ma;
    
    Population_decode(i).crossover_mutation=1;
end
end

