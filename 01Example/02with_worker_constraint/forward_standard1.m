function [Population_indiv_st]=forward_standard1(Population_indiv,total_ope_num)
%正向标准化，按照谁先结束谁在前的原则对染色体OS层重新排序

pro_time_array=Population_indiv.pro_time;
chrome_os_array=Population_indiv.chromesome(1:total_ope_num);
[~,index]=sort(pro_time_array(2,:));
Population_indiv.chromesome(1:total_ope_num)=chrome_os_array(index);
Population_indiv.decode=Population_indiv.decode(index);
Population_indiv.pro_time=Population_indiv.pro_time(:,index);
Population_indiv_st=Population_indiv;
end