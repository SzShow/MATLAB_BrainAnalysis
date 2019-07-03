classdef NNMod < BCI_Module.BCIOutputModule
    %UNTITLED2 ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties
        Classifier
        Layer
        Option
    end
    
    methods
        function obj=train(obj, i)
            X=obj.JointFeature(i);
            Y=obj.epochtrigger(i);
            obj.Option=obj.setoption(Y);
            obj.Classifier=trainNetwork(X,obj.Layer, obj.Option);
        end
        
        function [o,Y]=test(obj, i)
            X=obj.JointFeature(i);
            Y=obj.epochtrigger(i);
            o=classify(obj.Classifier, X);
        end
        
    end



end

