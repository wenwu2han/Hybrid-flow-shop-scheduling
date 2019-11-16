function MA(Population_st,pop_size,job_num,stage_num,maxgen,m,crossRate,mutationRate,filenames,d_flage1,d_flage2,disp1,disp2,runTime1,count,filenames_name)
%Initialize the variables:Declare the variables
%pop_size:population size (integer)
%crossRate:the rate of crossover
%mutationRate:the rate of mutation
%job_num:the number of jobs
%Worker_stage
%worker_set_stage
%stage_num:the number of stages
%mach_set_stage:vector of machine set in each stage (matrix,row:machin set,column:stage)
%total_ope_num:total numbers of operations
%m:the number of objectives
%maxgen:maxium number of generation
dbstop if error

total_ope_num=job_num*stage_num;
chrom_length=3*total_ope_num;                                              %the length of chromosome
Disp1 = disp1{d_flage1};
Disp2 = disp2{d_flage2};
%% Step3:List scheduling + Disptching rule
tic;
[Population_st,Populate_first_mean]=all_disptching_scheduling(Population_st,pop_size,job_num,stage_num,chrom_length,maxgen,m,crossRate,mutationRate,filenames,Disp1,Disp2);
runTime = toc + runTime1         % 记录运行时间
%% Save the result
j=mod(count,10);
i=(count-j)/10;
filename=strcat('result',filenames_name,'_',Disp1,Disp2,'_',char(48+i),char(48+j));
save(filename,'Population_st','runTime','Populate_first_mean');
end