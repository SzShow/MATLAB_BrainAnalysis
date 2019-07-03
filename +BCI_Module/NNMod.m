classdef NNMod < BCI_Module.BCIOutputModule
    %UNTITLED2 このクラスの概要をここに記述
    %   詳細説明をここに記述
    
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

