function [chrom_os_stage1, pro_time_array] = FCFS(pro_time_array, j, job_num)
% First come first serve rule for job sequencing

[~,index1] = sort(pro_time_array(2,(j-1)*job_num+1:j*job_num));%按照结束的先后次序
pro_time_array(1,(j-1)*job_num+1:j*job_num) = pro_time_array(1,(j-1)*job_num+index1);
pro_time_array(2,(j-1)*job_num+1:j*job_num) = pro_time_array(2,(j-1)*job_num+index1);
pro_time_array(3,(j-1)*job_num+1:j*job_num) = pro_time_array(3,(j-1)*job_num+index1);
chrom_os_stage1 = pro_time_array(3,(j-1)*job_num+1:j*job_num);
end