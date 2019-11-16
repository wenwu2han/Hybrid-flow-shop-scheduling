function [Population_ns]=nondominant_sort(Population_decode,pop_size,m)
%基于Pareto支配的排序函数

%inputs
%Population_decode:解码之后的种群
% chrom_length:染色体长度
% m：目标个数

%outputs
%Population_ns:非支配排序之后的种群
%输出的种群第chrom_length+7列为该个体所处的非支配前沿

%支配关系的定义；最小化问题（DFSP）
%任意两个决策向量a、b,对于任意的目标值，若a<=b,且存在a<b，则a支配b;
%若a不支配b,b不支配a,则：a与b无差别
%定义函数： c=dominate(a,b)
Population_ns=Population_decode;
rank=1;
%构造结构，用于存储不同个体的ni（支配个体i的个数）和si（受个体i支配的个体）
person(1:pop_size)=struct('n',0,'s',[]);
%存储不同等级个体信息（.f是为了保证该结构能在matlab中运行,利用matlab可扩展性结构）
F(rank).f=[];
%非支配排序
I=1:pop_size;
for i=1:pop_size
    object_i=Population_decode(i).objectives(1:m);
    I(1:i)=[];
    if ~isempty(I)
        for jj=1:length(I)
            j=I(jj);
            object_j=Population_decode(j).objectives(1:m);
            log_num_i=dominate(object_i,object_j);                               %非支配判断
            log_num_j=dominate(object_j,object_i); 

            if log_num_i
                person(i).s=[person(i).s,j];
                person(j).n=person(j).n+1;
            end
            if log_num_j
                person(j).s=[person(j).s,i];
                person(i).n=person(i).n+1;
            end
        end
    end
    I=1:pop_size;
end
[~,col]=find([person.n]==0);
F(rank).f=col;
%% 后续前沿排序
while ~isempty(F(rank).f)
    Q=[];
    for i=1:length(F(rank).f)
        if ~isempty(person(F(rank).f(i)).s)
            for j=1:length(person(F(rank).f(i)).s)
                person(person(F(rank).f(i)).s(j)).n=person(person(F(rank).f(i)).s(j)).n-1;
                if person(person(F(rank).f(i)).s(j)).n==0
                    Q=[Q,person(F(rank).f(i)).s(j)];
                end
            end
        end
    end
    rank=rank+1;
    F(rank).f=Q;
end
for ii=1:rank
    if ~isempty(F(ii).f)
        [~,col]=size(F(ii).f);
        for jj=1:col
            Population_ns(F(ii).f(jj)).rank=ii;
        end
    end    
end
[~,index]=sort([Population_ns.rank]);
Population_ns=Population_ns(index);
end