classdef EDCMakeClass < ExperimentDataClass
    %UNTITLED2 ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties
        tdcObject TrainingDataClass
        RawData
        CombinedData
        FlickerDuration
    end
    
    methods
        function obj = untitled2(inputArg1,inputArg2)
            %UNTITLED2 ���̃N���X�̃C���X�^���X���쐬
            %   �ڍא����������ɋL�q
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 ���̃��\�b�h�̊T�v�������ɋL�q
            %   �ڍא����������ɋL�q
            outputArg = obj.Property1 + inputArg;
        end
    end
end

