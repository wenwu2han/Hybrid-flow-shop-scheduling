function c=dominate(a,b)
%支配关系的定义；最小化问题（DFSP）
%任意两个决策向量a、b,对于任意的目标值，若a<=b,且存在a<b，则a支配b;
%若a不支配b,b不支配a,则：a与b无差别
c=all(a<=b)&&any(a<b);
end