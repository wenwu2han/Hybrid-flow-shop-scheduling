function MA()
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
oldpath=cd;      %获取当前工作目录
folders=dir(oldpath);
folders={folders.name};
folders=setdiff(folders,{'.','..'})';
filenames=folders{1,:};
load (filenames)
filenames_name=filenames(5:end-4);

%% Step1:Initialize their values
pop_size=1;
total_oper=job_num*stage_num;
load resultt0105×2I4_all.mat
Population_st0=struct('chromesome',[],'decode',[],'pro_time',[],'objectives',[],'load_machine',[],'load_inbalance_ma',0,'rank',0,'critical_path',[],'crowded_distance',0);
Population_st0.chromesome=Population_child_all(3).chromesome;
[individul1]=decode(pop_size,job_num,stage_num,mach_set_stage,Basic_infor,Population_st0);

filename=strcat('result',filenames_name,'I5_','all');
save(filename,'individul1');