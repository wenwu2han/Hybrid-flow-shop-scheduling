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
pop_size=150;                                                              %the size of initilized population
crossRate=0.7;                                                             %the rate of crossover
mutationRate=0.3;                                                          %the rate of mutation
maxgen=50;                                                                 %进化最大代数
total_ope_num=job_num*stage_num;
chrom_length=3*total_ope_num;                                              %the length of chromosome
m=2;                                                                       %目标个数
Populate_first_mean=zeros(maxgen,m);

for count=1:5                                                              %Run independently 10 times for I_NSGA_2
    tic;
    %% Step2:Initialize te population
    [Population_st]=initialize_population7(pop_size,job_num,chrom_length);
    decode_size=pop_size;
    for i=1:maxgen
        if decode_size~=0
            Population_st0=Population_st(pop_size-decode_size+1:pop_size);
            [Population_st0]=decode1(decode_size,job_num,stage_num,mach_set_stage,worker_set_stage,Basic_infor,Population_st0);
            Population_st(pop_size-decode_size+1:pop_size)=Population_st0;
        end
        %% Step3 :new population from crossover operators
        [crossPopulation]=crossPopulateN(Population_st,pop_size,job_num,chrom_length,crossRate);
        %% Step4 :new population from mutation operators
        [mutationPopulation]=mutationPopulateN(crossPopulation,pop_size,job_num,chrom_length,mutationRate,filenames);
        %% Step5 :combined population
        [Population_decode0]=decode1(pop_size,job_num,stage_num,mach_set_stage,worker_set_stage,Basic_infor,mutationPopulation);
        pop_size=pop_size*2;
        Population_decode(1:pop_size)=struct('chromesome',[],'decode',[],'pro_time',[],'objectives',[],'load_machine',[],'load_inbalance_ma',0,'load_worker',[],'load_inbalance_wo',0,'rank',0,'critical_path',[],'crowded_distance',0);
        Population_decode(1:pop_size/2)=Population_st;
        Population_decode(pop_size/2+1:pop_size)=Population_decode0;
        %% Step7 :non-dominant sort
        [Population_ns]=nondominant_sort(Population_decode,pop_size,m);
        %% Step8 :neighborhood search structure
%         [Population_ns]=neighborhood_search2(Population_ns,total_ope_num,stage_num,pop_size,NS_rate,m,filenames);
        %% Step9 :crowding distance and selct
        [Population_ch,pop_size,last_rank,Population_first]=selctPopulate(Population_ns,pop_size,m);
        %% Step10 :elimination and new initialized population
        [Population_st,decode_size]=elimi_initial1(Population_ch,pop_size,job_num,chrom_length,last_rank,Population_first,m);
        %% Step11 :the mean of each objectives in the first rank of population
        [objective_mean]=Populate_mean(Population_st,m);
        Populate_first_mean(i,1:m)=objective_mean;
    end
    % Step12 :Count the runtime of program
    runTime=toc         % 记录运行时间
    %% Step14 :Save the result
    j=mod(count,10);
    i=(count-j)/10;
    filename=strcat('result',filenames_name,'I4_',char(48+i),char(48+j));
    save(filename,'Population_st','runTime','Populate_first_mean');
end
%% 将得到的五个结果的第一前沿个体集中在一起，并进行非支配排序
m=2;
count1=5;
num1=0;
runtime_array=zeros(1,5);
Populate_first_mean_cell=cell(1,5);                          %存储每个结果的收敛均值矩阵
for ii=1:count1
    jj=mod(ii,10);
    jjj=(ii-jj)/10;
    filename=strcat('result',filenames_name,'I4_',char(48+jjj),char(48+jj));
    load(filename);
    Populate_first_mean_cell{1,ii}=Populate_first_mean;
    runtime_array(1,ii)=runTime;
    [~,col]=find([Population_st.rank]==1);
    [~,num_first]=size(col);
    Population_all(num1+1:num1+num_first)=Population_st(col);
    num1=num1+num_first;
end
[Population_ns_all]=nondominant_sort(Population_all,num1,m);
[Population_child_all]=elimination(Population_ns_all,num1,m);
filename=strcat('result',filenames_name,'I4_','all');
save(filename,'Population_child_all','runtime_array','Populate_first_mean_cell');