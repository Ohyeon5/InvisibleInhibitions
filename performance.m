classdef performance % class performance for TPD conceptual model 
    properties
        response
        index
        hits
        pc
    end
    methods
        function obj = performance(cwOutput, ccOutput, rotNRcw,rotNRcc,rotRlcw,rotRrcw,rotRlcc,rotRrcc)
            % Initialize performance with response, index, hits, and pc
            lenInput = length(cwOutput);
            obj.response = 1*(rand(lenInput,1)<(cwOutput.*(cwOutput>ccOutput))) + (-1)*(rand(lenInput,1)<(ccOutput.*(cwOutput<ccOutput))); % 1: cw, -1:ccw
            obj.response(obj.response==0)=((rand(sum(obj.response==0),1)>0.5)-0.5)*2; % allocate missed trials' responses in chance level (50%)
            if ~isempty(rotNRcc)
                obj.index = obj.seperateIndexes(rotNRcw,rotNRcc,rotRlcw,rotRrcw,rotRlcc,rotRrcc);
                [obj.hits, obj.pc] = obj.responseSimul(rotNRcw);
            end
        end
        
        function index = seperateIndexes(obj,rotNRcw,rotNRcc,rotRlcw,rotRrcw,rotRlcc,rotRrcc)
            if any([isempty(rotRlcw),isempty(rotRrcw)]) % one retinopotic case
                rotRcw = [rotRlcw;rotRrcw]; % since one of two is empty
                rotRcc = [rotRlcc;rotRrcc]; % since one of two is empty
                index(1,:) = {find(rotNRcw == rotRcw | rotNRcc == rotRcc)};
                index(2,:) = {find(rotNRcw ~= rotRcw | rotNRcc ~= rotRcc )};
                index(3,:) = {find(~(rotNRcw == 0 & rotNRcc == 0))}; %(4) all except no-nonRet case
            else
                index(1,:) = {find((rotNRcw == rotRlcw & rotNRcw == rotRrcw ) | (rotNRcc == rotRlcc & rotNRcc == rotRrcc))};
                index(2,:) = {find((rotNRcw == rotRlcw & rotNRcw ~= rotRrcw ) | (rotNRcw ~= rotRlcw & rotNRcw == rotRrcw ) | (rotNRcc == rotRlcc & rotNRcc ~= rotRrcc) | (rotNRcc ~= rotRlcc & rotNRcc == rotRrcc))};
                index(3,:) = {find((rotNRcw ~= rotRlcw & rotNRcw ~= rotRrcw ) | (rotNRcc ~= rotRlcc & rotNRcc ~= rotRrcc))};
                index(4,:) = {find(~(rotNRcw == 0 & rotNRcc == 0))}; %(4) all except no-nonRet case
            end
        end
        
        function [hits, pc] = responseSimul_base(obj, rotNRcw)
            hits = (rotNRcw-0.5)*2 == obj.response; 
            pc = mean(hits);
        end
        
        function [hits, pc] = responseSimul(obj, rotNRcw)
            for ii = 1:size(obj.index,1)
                hits(ii,:) = {(rotNRcw(obj.index{ii,1})-0.5)*2 == obj.response(obj.index{ii,1})}; 
                pc(ii) = mean(hits{ii,1});
            end
%             hits(2,:) = {(rotNRcw(obj.index{2,1})-0.5)*2 == obj.response(obj.index{2,1})};
%             pc(2) = mean(hits{2,1});
%             hits(3,:) = {(rotNRcw(obj.index{3,1})-0.5)*2 == obj.response(obj.index{3,1})};
%             pc(3) = mean(hits{3,1});
%             hits(4,:) = {(rotNRcw(obj.index{4,1})-0.5)*2 == obj.response(obj.index{4,1})};
%             pc(4) = mean(hits{4,1});
        end
        
        function fig = plot_TPD_performance(obj, varargin)
            values = varargin{1};
            valSz = size(values);
            % values should be in order of 'All', 'two congruent', 'one congruent', 'two incongruent'
            % ex) obj.plot_TPD_performance([perform(4).pcVal, perform(1).pcVal, perform(2).pcVal, perform(3).pcVal])
            colormap = [0 0 0; 1 0 0; 0 1 0; 0 0 1];
            fig = figure('position', [500 500 600 250]);
            hold on
            for ii=1:valSz(1)
                plot(1:valSz(2), values(ii,:), 'color',colormap(ii,:), 'marker', 's', 'markeredgecolor', colormap(ii,:), 'markerfacecolor', min(colormap(ii,:)+[0.5 0.5 0.5],1), 'markersize', 10)
            end
            if nargin == 3
                baseline = varargin{2};
                hh=line([0 5],repmat(baseline,1,2));
                set(hh,{'color'},mat2cell(colormap(1:valSz(1),:),ones(1,valSz(1)),3))
            elseif nargin == 4
                stds = varargin{3};
                errorbar(1:valSz(2), values, stds, 'k.')
            end
            line([0 5],[0.5 0.5], 'color', [0.2 0.2 0.2])
            xlim([0.5 4.5])
            ylim([0.45 1])
            ylabel('percent correct')
            set(gca, 'Xtick', 1:4)
            set(gca, 'Xticklabel', {'All', 'two congruent', 'one congruent', 'two incongruent'})
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