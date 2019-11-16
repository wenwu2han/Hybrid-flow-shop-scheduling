function [interval]=inter_interval(interval1,interval2)
%两个区间求交 interaction of two intervals
down_interval=max([interval1(1,1),interval2(1,1)]);
up_interval=min([interval1(1,2),interval2(1,2)]);
if down_interval>=up_interval
    interval=[];
else
    interval=[down_interval,up_interval];
end
end
    