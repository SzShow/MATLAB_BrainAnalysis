classdef PreProcessingModule
    %UNTITLED3 ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties
        Property1
    end
    
    methods
        function obj = untitled3(inputArg1,inputArg2)
            %UNTITLED3 ���̃N���X�̃C���X�^���X���쐬
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

