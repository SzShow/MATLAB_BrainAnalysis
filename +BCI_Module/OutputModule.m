classdef (Abstract)OutputModule
    %OutputModule �o�̓��W���[���̊��N���X
    %   
    
    properties
        
    end
	
	%���ފ�̊w�K�ƃe�X�g�𒊏ۃ��\�b�h�Ƃ��Ē�`
    methods (Abstract)
        obj=training(obj, varargin)
        cmd=test(obj, varargin)
    end
end

