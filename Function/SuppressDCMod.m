classdef SuppressDCMod< PreProcessingModule
    %UNTITLED4 ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties
    end
    
    methods     
        function Output = process(obj,Input, ~)
            %METHOD1 ���̃��\�b�h�̊T�v�������ɋL�q
            %   �ڍא����������ɋL�q
            Output=detrend(Input);
        end
    end
end
