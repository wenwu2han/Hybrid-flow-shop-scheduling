%ªÊ÷∆ ’¡≤Õº
rank=5;
maxgen = 50;
filename=strcat('resultt01100°¡2I_',char(48+0),char(48+rank));
load(filename);
x=1:maxgen;
y_f1=Populate_first_mean(:,1).';
y_f2=Populate_first_mean(:,2).';
subplot(2,1,1),plot(x,y_f1,':g');
legend('makespan');
xlabel('generation count');
ylabel('fitness');
hold on
subplot(2,1,2),plot(x,y_f2,':r');
legend('Total tradiness of all jobs');
xlabel('generation count');
ylabel('fitness');
hold on