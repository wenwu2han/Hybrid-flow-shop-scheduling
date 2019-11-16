function [Population_child]=elimination(Population_ch,pop_size,m)
%种群去重
Population_child(1:pop_size)=struct('chromesome',[],'decode',[],'pro_time',[],'objectives',[],'load_machine',[],'load_worker',[],'rank',0,'crowded_distance',0,'cross_f',false); 

rank_count=max([Population_ch.rank]);
num=0;
for i=1:rank_count
    [~,index]=find([Population_ch.rank]==i);
    Population_array=Population_ch(index);
    Population_array1=Population_array;
    Population_array2=Population_array;
    [~,col]=size(index);
    count=0;
    delete_index=[];
    for j=1:col
        objectives1=Population_array(j).objectives(1:m);
%         chromesome1=Population_array(j).chromesome;
        if j<col
            Population_array1(1)=[];
            [~,col1]=size([Population_array1.rank]);
            for jj=1:col1
                flag=0;
                objectives2=Population_array1(jj).objectives(1:m);
%                 chromesome2=Population_array1(jj).chromesome;
                if objectives1==objectives2
%                     [H]=hamming_dis(chromesome1,chromesome2);
%                     if H==0
                        delete_index=[delete_index,j];
                        flag=flag+1;
                        count=count+1;
%                     end
                end
                if flag==1
                    break
                end
            end
        end
    end
    Population_array2(delete_index)=[];
    Population_child(num+1:num+col-count)=Population_array2;
    num=num+col-count;
end
end
