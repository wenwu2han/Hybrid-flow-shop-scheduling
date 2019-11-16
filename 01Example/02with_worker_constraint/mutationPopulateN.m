function [mutationPopulation]=mutationPopulateN(Population_st,pop_size,job_num,chrom_length,mutationRate,filenames)
% 变异产生的新个体

%inputs
% Population_st;c初始化的种群
% pop_size：种群规模
% job_num;工件数
% chrom_length;染色体长度
% stage_num;加工阶段数
% mutationRate;变异概率

%outputs
% mutationPopulation:变异获得种群

mutationPopulation=Population_st;
for i=1:pop_size                             %保证变异的个体都进行如下操作
    chromesome=mutationPopulation(i).chromesome;
    child=zeros(1,chrom_length);
    %% OS、MA和WA层变异
    chrom_os=chromesome(1,1:chrom_length/3);
    chrom_ma=chromesome(1,chrom_length/3+1:2*chrom_length/3);
    chrom_wa=chromesome(1,2*chrom_length/3+1:chrom_length);
    [child_os,child_ma,child_wa]=mutationN(chrom_os,chrom_ma,chrom_wa,job_num,chrom_length,mutationRate,filenames);
    child(1,1:chrom_length/3)=child_os;
    child(1,chrom_length/3+1:2*chrom_length/3)=child_ma;
    child(1,2*chrom_length/3+1:chrom_length)=child_wa;
    mutationPopulation(i).chromesome=child;
end
end