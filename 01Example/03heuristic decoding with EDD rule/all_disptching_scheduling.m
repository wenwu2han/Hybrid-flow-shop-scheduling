function [Population_st,Populate_first_mean]=all_disptching_scheduling(Population_st,pop_size,job_num,stage_num,chrom_length,maxgen,m,crossRate,mutationRate,filenames,Disp1,Disp2)

Populate_first_mean=zeros(maxgen,m);
decode_size=pop_size;
for i=1:maxgen
    %% Step1: decoding the population
    if decode_size~=0
        Population_st0=Population_st(pop_size-decode_size+1:pop_size);
        [Population_st00]=heuristic_decode(Population_st0,filenames,Disp1,Disp2);
        indiv_size=size([Population_st00.rank],2);
        Population_st(pop_size-decode_size+1:pop_size-decode_size+indiv_size)=Population_st00;
    end
    %% Step2 :new population from crossover operators
    [crossPopulation]=crossPopulateN(Population_st,pop_size,job_num,stage_num,chrom_length,crossRate);
    %% Step3 :new population from mutation operators
    [mutationPopulation]=mutationPopulateN(crossPopulation,pop_size,job_num,stage_num,chrom_length,mutationRate);
    %% Step4 :decoding and combined population
    [Population_st01]=heuristic_decode(mutationPopulation,filenames,Disp1,Disp2);
    indiv_size=size([Population_st01.rank],2);
    Population_decode0(1:indiv_size)=Population_st01;
    pop_size=pop_size*2;
    Population_decode(1:pop_size)=struct('chromesome',[],'decode',[],'pro_time',[],'objectives',[],'load_machine',[],'load_worker',[],'rank',0,'crowded_distance',0,'cross_f',false);
    Population_decode(1:pop_size/2)=Population_st;
    Population_decode(pop_size/2+1:pop_size)=Population_decode0;
    %% Step5 :non-dominant sort
    [Population_ns]=nondominant_sort(Population_decode,pop_size,m);
    %% Step6 :crowding distance and selct
    [Population_ch,pop_size,last_rank,Population_first]=selctPopulate(Population_ns,pop_size,m);
    %% Step7 :elimination and new initialized population
    [Population_st,decode_size]=elimi_initial(Population_ch,pop_size,job_num,chrom_length,last_rank,Population_first,m);
    %% Step8 :the mean of each objectives in the first rank of population
    [objective_mean]=Populate_mean(Population_st,m);
    Populate_first_mean(i,1:m)=objective_mean;
end
end