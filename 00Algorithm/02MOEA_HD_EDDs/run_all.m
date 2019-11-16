function run_all()
disp1 = {'LB','FIMW','LFMW'};
disp2 = {'EDD'};
%% Step1:Initialize related values
pop_size=150;                                                              %the size of initilized population
crossRate=0.7;                                                             %the rate of crossover
mutationRate=0.3;                                                          %the rate of mutation
maxgen=50;                                                                 %进化最大代数
m=2;                                                                       %目标个数
num = 5;
oldpath=cd;      %获取当前工作目录
folders=dir(oldpath);
folders={folders.name};
folders=setdiff(folders,{'.','..'})';
for j = 1:15
    filenames=folders{j,:};
    load (filenames)
    filenames_name=filenames(5:end-4);
    total_ope_num=job_num*stage_num;
    chrom_length=3*total_ope_num;                                              %the length of chromosome
    for count=1:num                                                              %Run independently 10 times
        tic;
        %% Step2:Initialize te population
        [Population_st]=initialize_population(pop_size,job_num,chrom_length);
        runTime1 = toc;
        for k = 1:size(disp1,2)
            for g = 1:size(disp2,2)
               %% Step3:Algorithm for scheduling
                MA(Population_st,pop_size,job_num,stage_num,maxgen,m,crossRate,mutationRate,filenames,k,g,disp1,disp2,runTime1,count,filenames_name);
            end
        end
    end
    %% Summary all results
    summary_all(num, disp1, disp2, filenames_name, m)
end
end