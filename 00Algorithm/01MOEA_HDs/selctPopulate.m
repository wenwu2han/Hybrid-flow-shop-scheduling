function [Population_ch,pop_size,last_rank,Population_first]=selctPopulate(Population_ns,pop_size,m)
%选择一定数目的个体

%inputs
%Population_home:经过局部搜索的种群
% pop_size:种群规模

%outpuuts
%Population_st:父代个体
% pop_size:种群规模

pop_size=pop_size/2;
Population_rank=[Population_ns.rank];
child_rank=Population_rank(1:pop_size);
last_rank=child_rank(pop_size);
[~,col]=find(Population_rank==1);
Population_first=Population_ns(col);
Population_ch=Population_ns(col);
if last_rank==1
    [~,col]=find(Population_rank==last_rank);
    Population_first=Population_ns(col);
else
    [value1,~]=find(Population_rank==last_rank);
    [value2,~]=find(child_rank==last_rank);
    [~,last_rank_size1]=size(value1);
    [~,last_rank_size2]=size(value2);
    [Population_cd]=crowding_distance(Population_ns,m,last_rank);
    Population_ch(1:pop_size)=struct('chromesome',[],'decode',[],'pro_time',[],'objectives',[],'load_machine',[],'load_worker',[],'rank',0,'crowded_distance',0,'cross_f',false); 
    num=pop_size-last_rank_size2;                                               %除所选择的最后一个前沿的个体数
    if last_rank_size2==0
        Population_ch(1:pop_size)=Population_cd(1:pop_size);
    else
        Population_ch(1:num)=Population_cd(1:num);
        Population_array=Population_cd(num+1:num+last_rank_size1);
        array=[Population_array.crowded_distance];
        [~,array_sort_col]=sort(array,'descend');
        index=array_sort_col(1:last_rank_size2);
        Population_ch(num+1:pop_size)=Population_array(index);
    end
end
end