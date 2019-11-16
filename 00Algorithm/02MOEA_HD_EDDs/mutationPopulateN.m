function [mutationPopulation]=mutationPopulateN(Population_st,pop_size,job_num,stage_num,chrom_length,mutationRate)
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
    chrom1=mutationPopulation(i).chromesome;
    %% OS变异
    [child1,flag]=mutationN(chrom1,job_num,stage_num,chrom_length,mutationRate);
    mutationPopulation(i).chromesome=child1;
    mutationPopulation(i).cross_f = flag;
end
end