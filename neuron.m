classdef neuron % class neuron for the TPD neuron based conceptual model
    properties 
        input
        delay
        output
        activation
    end
    
    methods 
        function obj = neuron(varargin)
            if nargin > 0
                pp = inputParser; % Separate input parameters depending on each parameter indicator
                pp.addParameter('input', [], @ismatrix);  % Input array should be l x n matrix. l: length of the signals, n: number of different inputs
                pp.addParameter('delay', 0, @isscalar);   % Delay is not defined yet (Just for the record in this moment)
                pp.addParameter('activation', 'Relu', @isstr); % default activation function as Relu, other possibilities are 'Linear', ...
                pp.parse(varargin{:})
                
                obj.input = pp.Results.input;
                obj.delay = pp.Results.delay;
                obj.activation = pp.Results.activation;
                obj.output = obj.activateFun(obj.activation, obj.input);
            else
                msg = 'Not enough input parameters';
                error(msg)
            end
        end
        
        function outputSig = activateFun(obj, actFun, inputSig)
            switch actFun  % 'Relu' and 'Linear' could be used as a activation function
                case 'Relu'
                    outputSig = obj.activateRelu(inputSig);
                case 'linear'
                    outputSig = obj.activateLinear(inputSig);
            end
        end
            
        function outputSig = activateRelu(obj,inputSig, varargin)
            if nargin>2
                thre = varargin{1};
            else
                thre = 0;
            end
            % Make sure inputSig to be l x n matrix, which integrates row signals to have outputSig
            outputSig = sum(inputSig,2);
            outputSig = outputSig.*(outputSig>thre+0);
        end
        
        function outputSig = activateLinear(obj,inputSig)
            % Make sure inputSig to be l x n matrix, which integrates row signals to have outputSig
            outputSig = sum(inputSig,2);
        end
        
        function fig = plot_TPD_performance(obj, varargin)
            values = varargin{1};
            % values should be in order of 'All', 'two congruent', 'one congruent', 'two incongruent'
            % ex) obj.plot_TPD_performance([perform(4).pcVal, perform(1).pcVal, perform(2).pcVal, perform(3).pcVal])
            fig = figure('position', [500 500 600 250]);
            hold on
            plot(1:4, values, 'linestyle', 'none', 'marker', 's', 'markeredgecolor', 'k', 'markerfacecolor', [0.5 0.5 0.5], 'markersize', 10)
            if nargin > 2
                stds = varargin{2};
                errorbar(1:4, values, stds, 'k.')
            end
            line([0 5],[0.5 0.5], 'color', [0.2 0.2 0.2])
            xlim([0.5 4.5])
            ylim([0.45 1])
            ylabel('percent correct')
            set(gca, 'Xtick', 1:4)
            set(gca, 'Xticklabel', {'All', 'two congruent', 'one congruent', 'two incongruent'})
        end
    end
end