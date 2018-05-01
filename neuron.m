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
        
        function sobj = saveobj(obj)
            prop = properties(obj);
            for pp = 1:size(prop,1)
                sobj.(prop{pp}) = obj.(prop{pp});
            end
        end
        
        function obj = loadobj(sobj)
            if isstruct(sobj)
                newobj = ClassConstructor;
                prop = properties(sobj);
                for pp = 1:size(prop,1)
                    newobj.(prop{pp}) = sobj.(prop{pp});
                end
                obj = newobj;
            else
                obj = sobj;
            end
        end
    end
end
