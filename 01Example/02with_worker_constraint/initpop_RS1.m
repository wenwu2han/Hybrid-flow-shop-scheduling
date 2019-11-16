function [Population_RS]=initpop_RS1(Population_OS,job_num,chrom_length,mach_set_stage,worker_set_stage)
% 以random selection (RS) 的方式产生RS_Rate*pop_size 的个体——机器分配、工人分配


Population_RS=zeros(1,chrom_length);
Population_RS(1,1:chrom_length/3)=Population_OS;
chrom_ma_vector=zeros(1,chrom_length/3);
chrom_wa_vector=zeros(1,chrom_length/3);

w=size(worker_set_stage,2);
m=size(mach_set_stage{1,1},2);
chrom_ma_vector(1,1:job_num)=mach_set_stage{1,1}(1,(ceil(rand(1,job_num)*m)));   %random vector for chromosome of MA
chrom_wa_vector(1,1:job_num)=worker_set_stage(1,(ceil(rand(1,job_num)*w))); %random vector for chromosome of WA

chrom_ma=chrom_ma_vector;
chrom_wa=chrom_wa_vector;
Population_RS(1,chrom_length/3+1:2*chrom_length/3)=chrom_ma;
Population_RS(1,2*chrom_length/3+1:chrom_length)=chrom_wa;
end