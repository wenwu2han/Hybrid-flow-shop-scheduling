function [Population_cd]=crowding_distance(Population_ns,m,last_rank)
%求个体的拥挤距离

% inputs
% Pop_ns：非支配排序之后的种群
% chrom_length:染色体长度
% m：目标数

% outputs
% Pop_nscd:某一前沿计算过拥挤距离的种群
Population_cd=Population_ns;
rank=last_rank;              %计算拥挤距离的前沿
array=[Population_ns.rank];
[~,vol]=find(array==rank);
Pop_array1=Population_ns(vol);
s=size(vol,2);
obj_array=zeros(s,m);
Pop_struct(1:s)=struct('chromesome',[],'decode',[],'pro_time',[],'objectives',[],'load_machine',[],'load_worker',[],'rank',0,'crowded_distance',0,'cross_f',false); 
for j=1:s
    obj_array(j,:)=Pop_array1(j).objectives;                               %取出对应个体的目标值
end
for i=1:m                                                                  % 分别以m个目标值计算拥挤距离，并将其加在一起
%% 对选定的非支配前沿的个体进行排序
    [~,index]=sort(obj_array(:,i));                                        
    obj_array=obj_array(index,:);
    for jj=1:s
        Pop_struct(jj)=Pop_array1(index(jj));
    end
%% 求解拥挤距离
    Pop_struct(1).crowded_distance=Pop_struct(1).crowded_distance+inf;
    Pop_struct(s).crowded_distance=Pop_struct(s).crowded_distance+inf;
    for ii=2:s-1
        max_obj=max(obj_array(:,i));
        min_obj=min(obj_array(:,i));
        if max_obj~=min_obj
            distance=(obj_array(ii+1,i)-obj_array(ii-1,i))/(max_obj-min_obj);
            Pop_struct(ii).crowded_distance=Pop_struct(ii).crowded_distance+distance;
        else
            distance=1;
            Pop_struct(ii).crowded_distance=Pop_struct(ii).crowded_distance+distance;
        end
    end
    Pop_array1=Pop_struct;
end
Population_cd(vol)=Pop_struct;
end