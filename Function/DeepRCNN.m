classdef DeepRCNN
    %UNTITLED ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties
        Property1
    end
    
    methods
        function obj = DeepRCNN(data)
            %UNTITLED2 ���̃N���X�̃C���X�^���X���쐬
            %   �ڍא����������ɋL�q
            
            %�f�[�^�̃T�C�Y�𕪉�
            [Nt, Nele, Nepo]=size(data);
            
            layers={
                imageInputLayer([Nt Nele 1])
                virtualComposeLayer()
                lstmLayer()
                fullyConnectedCNNLayer()
                
                };
            
            obj.Property1 = data + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 ���̃��\�b�h�̊T�v�������ɋL�q
            %   �ڍא����������ɋL�q
            outputArg = obj.Property1 + inputArg;
        end
    end
end

