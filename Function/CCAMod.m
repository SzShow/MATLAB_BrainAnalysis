classdef CCAMod<SpatialFilterModule
    %UNTITLED3 ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties
        
    end
    
    methods
        function obj = CCAMod(varargin)
            %UNTITLED3 ���̃N���X�̃C���X�^���X���쐬
            %   �ڍא����������ɋL�q
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = process(obj,Input, f, Nh, Fs)
            %METHOD1 ���̃��\�b�h�̊T�v�������ɋL�q
            %   �ڍא����������ɋL�q
            outputArg = obj.Property1 + inputArg;
        end
    end
end