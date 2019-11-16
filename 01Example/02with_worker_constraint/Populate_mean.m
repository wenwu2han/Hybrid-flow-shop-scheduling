function [objective_mean]=Populate_mean(Population_st,m)
%对于第一前沿的个体的每个目标取平均值

Population_st_rank=[Population_st.rank];
[~,index]=find(Population_st_rank==1);
Population_first=Population_st(index);
count=size(index,2);
Populate_objective=zeros(count,m);
objective_mean=zeros(1,m);
for i=1:count
    Populate_objective(i,:)=Population_first(i).objectives(1:m);
end
objective_mean(1,:)=mean(Populate_objective);
end