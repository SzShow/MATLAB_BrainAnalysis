classdef CleanedEpoch
    %UNTITLED ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties
        TargetFreq
        Method
        Data
    end
    
    methods
        function obj = CleanedEpoch(f, m)
            %UNTITLED ���̃N���X�̃C���X�^���X���쐬
            %   �ڍא����������ɋL�q
            obj.TargetFreq = f;
            obj.Method = m;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 ���̃��\�b�h�̊T�v�������ɋL�q
            %   �ڍא����������ɋL�q
            outputArg = obj.Property1 + inputArg;
        end
    end
end

