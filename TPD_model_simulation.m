function TPD_model_simulation()
% model simulation for invisibility TPD
% Detailed model descriptions are represented in (Lauffs et al., Cons.&Cog., 2018)
% please refer to https://doi.org/10.1016/j.concog.2018.03.007 

% The model is designed and simulated by Oh-hyeon Choung
% Simulated results are presented in VSS 2018 by Oh-hyeon Choung (poster)

% Main condition: Exp 2a (Figure Results Exp 2a.png)

%% Clear up everything

clc;clear;

%% Simulation 1. discrete input [0(ccw) 1(cw)] and figure out output performance

% Initialize parameters
lenInput = 1000;
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

% performance
response = 1*(rand(lenInput,1)<(pcw.output.*(pcw.output>pcc.output))) + (-1)*(rand(lenInput,1)<(pcc.output.*(pcw.output<pcc.output))); % 1: cw, -1:ccw
response(response==0)=((rand(sum(response==0),1)>0.5)-0.5)*2;

% separate each trial in Congruent and Incongruent case 
% (1)2 congruent, (2)1 congruent, (3)2 incongruent
perform(1).index = find((NRcw.input == R1.input & NRcw.input == R2.input) | (NRcc.input == ~R1.input & NRcc.input == ~R2.input));
perform(2).index = find((NRcw.input == R1.input & NRcw.input ~= R2.input) | (NRcw.input ~= R1.input & NRcw.input == R2.input) | (NRcc.input == ~R1.input & NRcc.input ~= ~R2.input) | (NRcc.input ~= ~R1.input & NRcc.input == ~R2.input));
perform(3).index = find((NRcw.input ~= R1.input & NRcw.input ~= R2.input) | (NRcc.input ~= ~R1.input & NRcc.input ~= ~R2.input));
perform(4).index = find(~(NRcw.input == 0 & NRcc.input == 0)); %(4) all except no-nonRet case

perform(1).pc = (NR.output(perform(1).index)-0.5)*2 == response(perform(1).index); 
perform(1).pcVal = mean(perform(1).pc);
perform(2).pc = (NR.output(perform(2).index)-0.5)*2 == response(perform(2).index);
perform(2).pcVal = mean(perform(2).pc);
perform(3).pc = (NR.output(perform(3).index)-0.5)*2 == response(perform(3).index);
perform(3).pcVal = mean(perform(3).pc);
perform(4).pc = (NR.output(perform(4).index)-0.5)*2 == response(perform(4).index);
perform(4).pcVal = mean(perform(4).pc);

% plot graph
NR.plot_TPD_performance([perform(4).pcVal, perform(1).pcVal, perform(2).pcVal, perform(3).pcVal])

clc;clear;
%% Simulation 2. gradual input and figure out output performance.

% Initialize parameters
lenInput = 1000;
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
% NRcw = neuron('input', zeros(lenInput), 'delay', 1);           % pos:1, 1 from NR input
% NRcc = neuron('input', zeros(lenInput), 'delay', 1);          % pos:2, 0 from NR input
% Retinotopic inputs
R1 = neuron('input',(rand(lenInput,1)-0.5)*2, 'activation', 'linear', 'delay', 0);
R2 = neuron('input', (rand(lenInput,1)-0.5)*2, 'activation', 'linear', 'delay', 0);
% R3 = neuron('input', rand(lenInput,1)>0.5 , 'delay', 0);

% time point 2
Rcw = neuron('input', [R1.output.*(R1.output>0), R2.output.*(R2.output>0), ww(1,3)*NRcw.output], 'delay', 0);     % pos:3
Rcc = neuron('input', [(-1)*R1.output.*(R1.output<0), (-1)*R1.output.*(R1.output<0), ww(2,4)*NRcc.output], 'delay', 0);  % pos:4

% time point 3
pcw = neuron('input', [ww(1,5)*NRcw.output, ww(3,6)*Rcc.output], 'delay', 0);   % pos:5
pcc = neuron('input', [ww(2,6)*NRcc.output, ww(4,5)*Rcw.output], 'delay', 0);   % pos:6

% performance
response = 1*(rand(lenInput,1)<(pcw.output.*(pcw.output>pcc.output))) + (-1)*(rand(lenInput,1)<(pcc.output.*(pcw.output<pcc.output))); % 1: cw, -1:ccw
response(response==0)=((rand(sum(response==0),1)>0.5)-0.5)*2;

% separate each trial in Congruent and Incongruent case 
% (1)2 congruent, (2)1 congruent, (3)2 incongruent
rotNRcw = (NRcw.input>0);
rotNRcc = (NRcc.input>0);
rotRlcw = (R1.input>0);
rotRrcw = (R2.input>0);
rotRlcc = (R1.input<0);
rotRrcc = (R2.input<0);

perform(1).index = find((rotNRcw == rotRlcw & rotNRcw == rotRrcw ) | (rotNRcc == rotRlcc & rotNRcc == rotRrcc));
perform(2).index = find((rotNRcw == rotRlcw & rotNRcw ~= rotRrcw ) | (rotNRcw ~= rotRlcw & rotNRcw == rotRrcw ) | (rotNRcc == rotRlcc & rotNRcc ~= rotRrcc) | (rotNRcc ~= rotRlcc & rotNRcc == rotRrcc));
perform(3).index = find((rotNRcw ~= rotRlcw & rotNRcw ~= rotRrcw ) | (rotNRcc ~= rotRlcc & rotNRcc ~= rotRrcc));
perform(4).index = find(~(rotNRcw == 0 & rotNRcc == 0)); %(4) all except no-nonRet case

perform(1).pc = (rotNRcw(perform(1).index)-0.5)*2 == response(perform(1).index); 
perform(1).pcVal = mean(perform(1).pc);
perform(2).pc = (rotNRcw(perform(2).index)-0.5)*2 == response(perform(2).index);
perform(2).pcVal = mean(perform(2).pc);
perform(3).pc = (rotNRcw(perform(3).index)-0.5)*2 == response(perform(3).index);
perform(3).pcVal = mean(perform(3).pc);
perform(4).pc = (rotNRcw(perform(4).index)-0.5)*2 == response(perform(4).index);
perform(4).pcVal = mean(perform(4).pc);

% plot graph
NR.plot_TPD_performance([perform(4).pcVal, perform(1).pcVal, perform(2).pcVal, perform(3).pcVal])


