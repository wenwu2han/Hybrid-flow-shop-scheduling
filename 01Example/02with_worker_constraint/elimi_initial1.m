function [Population_st,child_size]=elimi_initial1(Population_ch,pop_size,job_num,chrom_length,last_rank,Population_first,m)
%去除种群内重复的个体，并初始化产生部分新个体

%inputs
% Population_st:选择得到的个体

%outputs
% Population_st：去重和初始化的个体
if last_rank==1
    [Population_child]=elimination(Population_first,pop_size,m);
else
    [Population_child]=elimination(Population_ch,pop_size,m);
end
[~,index1]=find([Population_child.rank]==0);
[~,col1]=size(index1);
child_size=col1;

if child_size~=0
    %% 初始化种群补充去重的个体
    [Population_child1]=initialize_population7(child_size,job_num,chrom_length);
    
    Population_child(pop_size-col1+1:pop_size)=Population_child1;
    Population_st=Population_child;
    [Population_st(1:pop_size).crowded_distance]=deal(0);
else
    Population_st=Population_child(1:pop_size);
end
end