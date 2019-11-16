/*********************************************
 * OPL 12.9.0.0 Model
 * Author: Administrator
 * Creation Date: 2019年9月12日 at 下午2:32:08
 *********************************************/
using CPLEX;

//Inputs
int nbJobs = ...;
int nbStages = ...;

range Jobs = 1..nbJobs;
range Stgs = 1..nbStages;
range Stgs1 = 0..nbStages;

int allMach[i in Stgs1] = ...;
int nbMach[i in Stgs1] = ...;
int nbWork[i in Stgs1] = ...;

int B = ...;

// Total number of machines
int nMachs = max(i in Stgs) nbMach[i];
range rMachs = 1..nMachs;
int tMachs = sum(i in Stgs) nbMach[i];
range rMachs1 = 1..tMachs;
int nWorks = max(i in Stgs) nbWork[i];
range rWorks = 1..nWorks;


int OpDurations[Jobs, rMachs1] = ...;
int OpDue[Jobs] = ...;

dvar boolean pre_m[Jobs][Jobs][Stgs][rMachs];
dvar boolean pre_mf[Jobs][Stgs][rMachs];
dvar boolean pre_ml[Jobs][Stgs][rMachs];
dvar boolean pre_w[Jobs][Jobs][Stgs][rWorks];
dvar boolean pre_wf[Jobs][Stgs][rWorks];
dvar boolean pre_wl[Jobs][Stgs][rWorks];
dvar boolean ispro[Jobs][Stgs][rMachs][rWorks];
dvar int+ t_c[Jobs][Stgs];
dvar int+ Z;

//execute {
//  		cp.param.FailLimit = 1000000;
//}

minimize Z;

subject to {
cons1:// the operation precedence constraint
forall (i in Jobs, j in Stgs: j>1)
  t_c[i][j] - t_c[i][j-1] >= (sum (s in 1..nbWork[j]) (sum (k in 1..nbMach[j]) (ispro[i][j][k][s]*OpDurations[i][allMach[j-1]+k])));
forall (i in Jobs)
  t_c[i][1] - 0 >= (sum (s in 1..nbWork[1]) (sum (k in 1..nbMach[1]) (ispro[i][1][k][s]*OpDurations[i][k])));
  
cons2:// prevent the overlapping of any two jobs on the same machine and define the sequence of the jobs
forall (i in Jobs, b in Jobs, j in Stgs)
  t_c[b][j] - sum (s in 1..nbWork[j]) (sum (k in 1..nbMach[j]) (ispro[b][j][k][s]*OpDurations[b][allMach[j-1]+k])) + (1-(sum(k in 1..nbMach[j]) pre_m[i][b][j][k]))*B  >= t_c[i][j];

forall (b in Jobs, j in Stgs)
  t_c[b][j] - sum (s in 1..nbWork[j]) (sum (k in 1..nbMach[j]) (ispro[b][j][k][s]*OpDurations[b][allMach[j-1]+k])) + (1-(sum(k in 1..nbMach[j]) pre_mf[b][j][k]))*B >= 0;

cons3:// prevent the overlapping of any two jobs by the same worker and define the sequence of the jobs
forall (i in Jobs, b in Jobs, j in Stgs)
  t_c[b][j] - sum (s in 1..nbWork[j]) (sum (k in 1..nbMach[j]) (ispro[b][j][k][s]*OpDurations[b][allMach[j-1]+k])) + (1-(sum(s in 1..nbWork[j]) pre_w[i][b][j][s]))*B  >= t_c[i][j];

forall (b in Jobs, j in Stgs)
  t_c[b][j] - sum (s in 1..nbWork[j]) (sum (k in 1..nbMach[j]) (ispro[b][j][k][s]*OpDurations[b][allMach[j-1]+k])) + (1-(sum(s in 1..nbWork[j]) pre_wf[b][j][s]))*B >= 0;

cons4: //ensure that, in each stage and each machine within a stage, each job has a single predecessor
forall (h in Jobs, j in Stgs)
  forall (k in 1..nbMach[j])
    (sum (i in Jobs: i != h) pre_m[i][h][j][k]) + pre_mf[h][j][k] - ((sum (b in Jobs: b != h) pre_m[h][b][j][k]) + pre_ml[h][j][k]) == 0;
    
cons5: //ensure that, in each stage and each worker within a stage, each job has a single predecessor
forall (h in Jobs, j in Stgs)
  forall (s in 1..nbWork[j])
    (sum (i in Jobs: i != h) pre_w[i][h][j][s]) + pre_wf[h][j][s] - ((sum (b in Jobs: b != h) pre_w[h][b][j][s]) + pre_wl[h][j][s]) == 0;


cons6://ensure that, each operation can only be processed on one machine anytime
forall (b in Jobs, j in Stgs)
  sum(k in 1..nbMach[j]) ((sum(i in Jobs: i != b) pre_m[i][b][j][k]) + pre_mf[b][j][k]) == 1;

cons7:// Each machine in any stage can only process at most one job anytime
forall (b in Jobs, j in Stgs)
  forall (k in 1..nbMach[j])
    (sum(i in Jobs: i != b) pre_m[i][b][j][k]) + pre_mf[b][j][k] == sum(s in 1..nbWork[j]) ispro[b][j][k][s];

forall (j in Stgs)
  forall (k in 1..nbMach[j])
    (sum(i in Jobs) pre_ml[i][j][k]) <= 1;

cons8:// ensure that, each operation can only be processed by one worker anytime
forall (b in Jobs, j in Stgs)
  sum(s in 1..nbWork[j]) ((sum(i in Jobs: i != b) pre_w[i][b][j][s]) + pre_wf[b][j][s]) == 1;
  
cons9:// Each worker in any stage can only process at most one job anytime
forall (b in Jobs, j in Stgs)
  forall (s in 1..nbWork[j])
    (sum(i in Jobs: i != b) pre_w[i][b][j][s]) + pre_wf[b][j][s] == sum(k in 1..nbMach[j]) ispro[b][j][k][s];

forall (j in Stgs)
  forall (s in 1..nbWork[j])
    (sum(i in Jobs) pre_wl[i][j][s]) <= 1;


cons10:// Each operation can only be processed on one machine by one worker anytime
forall (i in Jobs, j in Stgs)
  sum(k in 1..nbMach[j], s in 1..nbWork[j]) ispro[i][j][k][s] == 1;

cons11:// The makespan value
forall (i in Jobs, j in Stgs)
  t_c[i][j] <= Z;
}

// Total tardiness of all jobs
int obj_tradness = 0;

execute {
  for (var h in Jobs) {
    trad = t_c[h][nbStages] - OpDue[h]
    if (trad < 0) {
        trad = 0
    }
    obj_tradness = obj_tradness + trad
  }    
}
