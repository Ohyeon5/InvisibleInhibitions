function TPD_model_simulation()
% model simulation for invisibility TPD
% Detailed model descriptions are represented in (Lauffs et al., Cons.&Cog., 2018)
% please refer to https://doi.org/10.1016/j.concog.2018.03.007 

% The model is designed and simulated by Oh-hyeon Choung
% Simulated results are presented in VSS 2018 by Oh-hyeon Choung (poster)

% Main condition: Exp 2a (Figure Results Exp 2a.png)

%% Clear up everything

clc;clear;

%% Baseline condition: wo retinotopic rotations
% Initialize parameters
lenInput = 2000;
ww = zeros(6); % [NRcw NRcc Rcw Rcc Pcw Pcc]
ww = [0 0 -100 0 1 0;
      0 0 0 -100 0 1;
      0 0 0 0 0 -0.25;
      0 0 0 0 -0.25 0;];

% time point 1
% Non-retinotopic inputs
NRbase = neuron('input', (rand(lenInput,1)-0.5)*2, 'activation', 'linear');             % 1 or cw input, 0 as cc input
NRcw = neuron('input', NRbase.output.*(NRbase.output>0), 'delay', 1);           % pos:1, >0 from NR input
NRcc = neuron('input',(-1)*NRbase.output.*(NRbase.output<0), 'delay', 1);       % pos:2, <0 from NR input (change it to be positive)

% time point 3
pcw = neuron('input', [ww(1,5)*NRcw.output], 'delay', 0);   % pos:5
pcc = neuron('input', [ww(2,6)*NRcc.output], 'delay', 0);   % pos:6

baseline = performance(pcw.output,pcc.output, [],[],[],[],[],[]);
[baseline.hits, baseline.pc] = baseline.responseSimul_base(NRcw.output>0);

clearvars -except baseline NRbase
%% Simulation 1. discrete input [0(ccw) 1(cw)] and figure out output performance

% Initialize parameters
lenInput = 2000;
ww = zeros(6); % [NRcw NRcc Rcw Rcc Pcw Pcc]
ww = [0 0 -100 0 1 0;
      0 0 0 -100 0 1;
      0 0 0 0 0 -0.25;
      0 0 0 0 -0.25 0;];

% time point 1
% Non-retinotopic inputs
NR = neuron('input', rand(lenInput,1)>0.5);             % 1 or cw input, 0 as cc input
NRcw = neuron('input', NR.output, 'delay', 1);           % pos:1, 1 from NR input
NRcc = neuron('input', ~NR.output, 'delay', 1);          % pos:2, 0 from NR input
% NRcw = neuron('input', zeros(lenInput), 'delay', 1);           % pos:1, 1 from NR input
% NRcc = neuron('input', zeros(lenInput), 'delay', 1);          % pos:2, 0 from NR input
% Retinotopic inputs
R1 = neuron('input', rand(lenInput,1)>0.5 , 'delay', 0);
R2 = neuron('input', rand(lenInput,1)>0.5 , 'delay', 0);
% R3 = neuron('input', rand(lenInput,1)>0.5 , 'delay', 0);

% time point 2
Rcw = neuron('input', [R1.output, R2.output, ww(1,3)*NRcw.output], 'delay', 0);     % pos:3
Rcc = neuron('input', [~R1.output, ~R2.output, ww(2,4)*NRcc.output], 'delay', 0);  % pos:4

% time point 3
pcw = neuron('input', [ww(1,5)*NRcw.output, ww(3,6)*Rcc.output], 'delay', 0);   % pos:5
pcc = neuron('input', [ww(2,6)*NRcc.output, ww(4,5)*Rcw.output], 'delay', 0);   % pos:6

% Performance analysis
% separate each trial in Congruent and Incongruent case 
% (1)2 congruent, (2)1 congruent, (3)2 incongruent
rotNRcw = (NRcw.input>0);
rotNRcc = (NRcc.input>0);
rotRlcw = (R1.input>0);
rotRrcw = (R2.input>0);
rotRlcc = (~R1.input);
rotRrcc = (~R2.input);
simul1 = performance(pcw.output,pcc.output, rotNRcw,rotNRcc,rotRlcw,rotRrcw,rotRlcc,rotRrcc);

% plot graph
simul1.plot_TPD_performance([simul1.pc(4), simul1.pc(1), simul1.pc(2), simul1.pc(3)])

% simulation 1-2: one retino case
% time point 2
R1cw = neuron('input', [R1.output, ww(1,3)*NRcw.output], 'delay', 0);     % pos:3
R1cc = neuron('input', [~R1.output, ww(2,4)*NRcc.output], 'delay', 0);  % pos:4

% time point 3
p1cw = neuron('input', [ww(1,5)*NRcw.output, ww(3,6)*R1cc.output], 'delay', 0);   % pos:5
p1cc = neuron('input', [ww(2,6)*NRcc.output, ww(4,5)*R1cw.output], 'delay', 0);   % pos:6

% Performance analysis
% separate each trial in Congruent and Incongruent case 
% (1)2 congruent, (2)1 congruent, (3)2 incongruent
rotNRcw = (NRcw.input>0);
rotNRcc = (NRcc.input>0);
rotRlcw = (R1.input>0);
rotRrcw = [];
rotRlcc = (~R1.input);
rotRrcc = [];
simul12 = performance(p1cw.output,p1cc.output, rotNRcw,rotNRcc,rotRlcw,rotRrcw,rotRlcc,rotRrcc);

% plot graph
simul12.plot_TPD_performance([simul12.pc(3), simul12.pc(1), simul12.pc(2)])

clearvars -except simul1 simul12 baseline NRbase
%% Simulation 2. gradual input and figure out output performance.

% Initialize parameters
lenInput = 10000;
ww = zeros(6); % [NRcw NRcc Rcw Rcc Pcw Pcc]
ww = [0 0 -100 0 1 0;
      0 0 0 -100 0 1;
      0 0 0 0 0 -0.25;
      0 0 0 0 -0.25 0;];

% time point 1
% Non-retinotopic inputs
NR = neuron('input', (rand(lenInput,1)-0.5)*2, 'activation', 'linear');             % 1 or cw input, 0 as cc input
NRcw = neuron('input', NR.output.*(NR.output>0), 'delay', 1);           % pos:1, >0 from NR input
NRcc = neuron('input',(-1)*NR.output.*(NR.output<0), 'delay', 1);       % pos:2, <0 from NR input (change it to be positive)
% Retinotopic inputs
R1 = neuron('input',(rand(lenInput,1)-0.5)*2, 'activation', 'linear', 'delay', 0);
R2 = neuron('input', (rand(lenInput,1)-0.5)*2, 'activation', 'linear', 'delay', 0);

% time point 2
Rcw = neuron('input', [R1.output.*(R1.output>0), R2.output.*(R2.output>0), ww(1,3)*NRcw.output], 'delay', 0);     % pos:3
Rcc = neuron('input', [(-1)*R1.output.*(R1.output<0), (-1)*R1.output.*(R1.output<0), ww(2,4)*NRcc.output], 'delay', 0);  % pos:4

% time point 3
pcw = neuron('input', [ww(1,5)*NRcw.output, ww(3,6)*Rcc.output], 'delay', 0);   % pos:5
pcc = neuron('input', [ww(2,6)*NRcc.output, ww(4,5)*Rcw.output], 'delay', 0);   % pos:6

% Performance analysis
% separate each trial in Congruent and Incongruent case 
% (1)2 congruent, (2)1 congruent, (3)2 incongruent
rotNRcw = (NRcw.input>0);
rotNRcc = (NRcc.input>0);
rotRlcw = (R1.input>0);
rotRrcw = (R2.input>0);
rotRlcc = (R1.input<0);
rotRrcc = (R2.input<0);
simul2 = performance(pcw.output,pcc.output, rotNRcw,rotNRcc,rotRlcw,rotRrcw,rotRlcc,rotRrcc);

% plot graph
simul2.plot_TPD_performance([simul2.pc(4), simul2.pc(1), simul2.pc(2), simul2.pc(3)])

% separate simultation2 in strong, midium, and weak NR input cases
ind(1,:) = {find(abs(NR.output)>0.65)};
ind(2,:) = {find(abs(NR.output)<0.65 & abs(NR.output)>0.35)};
ind(3,:) = {find(abs(NR.output)<0.35)};
baseind(1,:) = {find(abs(NRbase.output)>0.65)};
baseind(2,:) = {find(abs(NRbase.output)<0.65 & abs(NRbase.output)>0.35)};
baseind(3,:) = {find(abs(NRbase.output)<0.35)};
for ii=1:size(ind,1)
    pc(ii,:) = [mean(simul2.hits{1,1}(ismember(simul2.index{1,1},ind{ii,1}))), mean(simul2.hits{2,1}(ismember(simul2.index{2,1},ind{ii,1}))),mean(simul2.hits{3,1}(ismember(simul2.index{3,1},ind{ii,1}))),mean(simul2.hits{4,1}(ismember(simul2.index{4,1},ind{ii,1})))];
    base(ii,:) = mean(baseline.hits(baseind{ii,1}));
end
simul2.plot_TPD_performance([simul1.pc(4), simul1.pc(1), simul1.pc(2), simul1.pc(3); pc(:,[4 1 2 3])], [1;base])

% simulation 2-2: one retino case
% time point 2
R1cw = neuron('input', [R1.output.*(R1.output>0), ww(1,3)*NRcw.output], 'delay', 0);     % pos:3
R1cc = neuron('input', [(-1)*R1.output.*(R1.output<0), ww(2,4)*NRcc.output], 'delay', 0);  % pos:4

% time point 3
p1cw = neuron('input', [ww(1,5)*NRcw.output, ww(3,6)*R1cc.output], 'delay', 0);   % pos:5
p1cc = neuron('input', [ww(2,6)*NRcc.output, ww(4,5)*R1cw.output], 'delay', 0);   % pos:6

% Performance analysis
% separate each trial in Congruent and Incongruent case 
% (1)2 congruent, (2)1 congruent, (3)2 incongruent
rotNRcw = (NRcw.input>0);
rotNRcc = (NRcc.input>0);
rotRlcw = (R1.input>0);
rotRrcw = [];
rotRlcc = (R1.input<0);
rotRrcc = [];
simul22 = performance(p1cw.output,p1cc.output, rotNRcw,rotNRcc,rotRlcw,rotRrcw,rotRlcc,rotRrcc);

% plot graph
simul22.plot_TPD_performance([simul22.pc(3), simul22.pc(1), simul22.pc(2)])

% separate simultation2 in strong, midium, and weak NR input cases
ind(1,:) = {find(abs(NR.output)>0.65)};
ind(2,:) = {find(abs(NR.output)<0.65 & abs(NR.output)>0.35)};
ind(3,:) = {find(abs(NR.output)<0.35)};
baseind(1,:) = {find(abs(NRbase.output)>0.65)};
baseind(2,:) = {find(abs(NRbase.output)<0.65 & abs(NRbase.output)>0.35)};
baseind(3,:) = {find(abs(NRbase.output)<0.35)};
for ii=1:size(ind,1)
    pc1(ii,:) = [mean(simul22.hits{1,1}(ismember(simul22.index{1,1},ind{ii,1}))), mean(simul22.hits{2,1}(ismember(simul22.index{2,1},ind{ii,1}))),mean(simul22.hits{3,1}(ismember(simul22.index{3,1},ind{ii,1})))];
    base(ii,:) = mean(baseline.hits(baseind{ii,1}));
end
simul22.plot_TPD_performance([simul12.pc(3), simul12.pc(1), simul12.pc(2); pc1(:,[3 1 2])], [1;base])

resultSimul1 = simul1.saveobj;
resultSimul12 = simul12.saveobj;
resultSimul2 = simul2.saveobj;
resultSimul22 = simul22.saveobj;
resultBaseline = baseline.saveobj;

save 'simulationResults.mat' resultSimul1 resultSimul12 resultSimul2 resultSimul22 resultBaseline
clear;clc; 

%% simulation 3: train with human behavioral data and fit weight matrices for each participant.

