function summary_all(num, disp1, disp2, filenames_name, m)

count1=num;
for k = 1: size(disp1,2)
    for g = 1: size(disp2,2)
        clear Population_st;
        clear Population_all;
        clear Population_ns_all;
        clear Population_child_all;
        Disp1 = disp1{k};
        Disp2 = disp2{g};
        num1=0;
        runtime_array=zeros(1,num);
        Populate_first_mean_cell=cell(1,num);                          %存储每个结果的收敛均值矩阵
        for ii=1:count1
            jj=mod(ii,10);
            jjj=(ii-jj)/10;
            filename=strcat('result',filenames_name,'_',Disp1,Disp2,'_',char(48+jjj),char(48+jj));
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
        filename=strcat('result',filenames_name,'_',Disp1,Disp2,'_','all');
        save(filename,'Population_child_all','runtime_array','Populate_first_mean_cell');
    end
end
end