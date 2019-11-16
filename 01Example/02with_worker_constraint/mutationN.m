function [child_os,child_ma,child_wa]=mutationN(chrom_os,chrom_ma,chrom_wa,job_num,chrom_length,mutationRate,filenames)
%OS层变异

%inputs
% chrom_os: 父代OS层染色体
% chrom_length：染色体长度
% mutationRate：变异概率

%outputs
% child_os：子代OS层染色体
load (filenames)
child_os=zeros(1,chrom_length/3);
child_ma=zeros(1,chrom_length/3);
child_wa=zeros(1,chrom_length/3);
child_os(1:job_num)=chrom_os(1:job_num);
child_ma(1:job_num)=chrom_ma(1:job_num);
child_wa(1:job_num)=chrom_wa(1:job_num);
if rand<mutationRate
    %% OS层变异
    number1=unidrnd(job_num);
    number2=unidrnd(job_num);
    while number1==number2
        number2=unidrnd(job_num);
    end
    integer1=chrom_os(1,number1);
    integer2=chrom_os(1,number2);
    child_os(1,number2)=integer1;
    child_os(1,number1)=integer2;
    %% MA与WA层变异
    %第一行：染色体位置
    %第二行：机器选择
    %第三行：工人选择
    %第四行：加工时间
    load_job=zeros(4,job_num);
    for j=1:job_num
        position=j;
        load_job(1,j)=position;
        ma_rank=chrom_ma(1,j);
        load_job(2,j)=ma_rank;
        wa_rank=chrom_wa(1,j);
        load_job(3,j)=wa_rank;
        if mod(wa_rank,Worker_stage)==0
            rank=Worker_stage;
        else
            rank=mod(wa_rank,Worker_stage);
        end
        pro_time=Basic_infor.pro_time(j,(ma_rank-1)*Worker_stage+rank);
        load_job(4,j)=pro_time;
    end
    %按照机器和工人负荷进行机器和工人的重新分配
    mach_num=size(mach_set_stage{1,1},2);
    load_mach=zeros(2,mach_num);
    for k=1:mach_num
        load_mach(1,k)=mach_set_stage{1,1}(1,k);
        [~,index_ma]=find(load_job(2,:)==load_mach(1,k));
        load_mach(2,k)=sum(load_job(4,index_ma));
    end
    [~,index1]=sort(load_mach(2,:),2);
    load_mach_array=load_mach(:,index1);
    m_mach_rank=load_mach_array(1,mach_num);
    l_mach_rank=load_mach_array(1,1);
    [~,index_ma]=find(load_job(2,:)==m_mach_rank);
    position_ma=load_job(1,index_ma(randperm(size(index_ma,2),1)));
    child_ma(1,position_ma)=l_mach_rank;
    
    worker_num=size(worker_set_stage(1,:),2);
    load_worker=zeros(1,worker_num);
    for g=1:worker_num
        load_worker(1,g)=worker_set_stage(1,g);
        [~,index_wa]=find(load_job(3,:)==load_worker(1,g));
        load_worker(2,g)=sum(load_job(4,index_wa));
    end
    [~,index2]=sort(load_worker(2,:),2);
    load_worker_array=load_worker(:,index2);
    m_worker_rank=load_worker_array(1,worker_num);
    l_worker_rank=load_worker_array(1,1);
    [~,index_wa]=find(load_job(3,:)==m_worker_rank);
    position_wa=load_job(1,index_wa(randperm(size(index_wa,2),1)));
    child_wa(1,position_wa)=l_worker_rank;
else
    child_os=chrom_os;
    child_ma=chrom_ma;
    child_wa=chrom_wa;
end