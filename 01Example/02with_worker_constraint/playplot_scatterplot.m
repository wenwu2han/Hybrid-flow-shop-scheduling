%绘制解的分布图

load result5tai0120×5I_all.mat
[~,col]=find([Population_child_all.rank]==1);
[~,col1]=size(col);
y_f1=zeros(1,col1);
y_f2=zeros(1,col1);
y_f3=zeros(1,col1);
for i=1:col1
    y_f1(1,i)=Population_child_all(col(i)).objectives(1);
    y_f2(1,i)=Population_child_all(col(i)).objectives(2);
    y_f3(1,i)=Population_child_all(col(i)).objectives(3);
end
scatter3(y_f1,y_f2,y_f3,10,'g');

hold on
load result51tai0120×5I_all.mat
[~,col]=find([Population_child_all.rank]==1);
[~,col1]=size(col);
y_f1=zeros(1,col1);
y_f2=zeros(1,col1);
y_f3=zeros(1,col1);
for i=1:col1
    y_f1(1,i)=Population_child_all(col(i)).objectives(1);
    y_f2(1,i)=Population_child_all(col(i)).objectives(2);
    y_f3(1,i)=Population_child_all(col(i)).objectives(3);
end
scatter3(y_f1,y_f2,y_f3,10,'b');
xlabel('makespan');  
ylabel('workload balance of machine');
zlabel('workload balance of worker');
hold on