classdef AcquiredSignalClass
    %AcquiredSignalClass ���ԑ����Ƃɋ�؂����f�[�^���Ǘ����邽�߂̃N���X�ł��D
    %   ���̃N���X�ɂ͋�؂����f�[�^�̔g�`�C�v���������̎��ԁC���ԑ��C�_�Ŏ��g��
    %   �Ȃǂ�����C���ꂼ��̋@�\�Ƃ��āC�O�����Ɠ����ʒ��o�ƃp�^�[�����ނ����g
    %   �ōs�����Ƃ��ł��܂��D
    
    properties
        Signal   %�擾�M��
        PreProcessedSignal
        Feature
        Class
        
        t   %�v���I������
        Ts  %���ԑ�
        Ff  %�_�Ŏ��g��
    end
    
    methods
        function []=preprocess(PP)
            
        end
        
        function []=featureextraction(FeatureExtractionClass)
        end
        
        function []=classification(ClassificationClass)
        end
    end
    
end

