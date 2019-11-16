%绘制解的分布图

load resultt01100×2I_all.mat
[~,col]=find([Population_child_all.rank]==1);
[~,col1]=size(col);
y_f1=zeros(1,col1);
y_f2=zeros(1,col1);
y_f3=zeros(1,col1);
for i=1:col1
    y_f1(1,i)=Population_child_all(col(i)).objectives(1);
    y_f2(1,i)=Population_child_all(col(i)).objectives(2);
end
plot(y_f1,y_f2,'og');
xlabel('makespan');  
ylabel('Total tradiness of all jobs');