classdef SSVEPClassifier
    %UNTITLED ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties
        Method
    end
    
    methods
        function obj = SSVEPClassifier(m,inputArg)
            %UNTITLED ���̃N���X�̃C���X�^���X���쐬
            %   �ڍא����������ɋL�q
            obj.Method = m;
        end
        
        function outputArg = classify(obj,inputArg)
            %METHOD1 ���̃��\�b�h�̊T�v�������ɋL�q
            %   �ڍא����������ɋL�q
            outputArg = obj.Property1 + inputArg;
        end
        
        function training(obj, Data, inputArg)
            [Nt, Nele, Nepo]=size(Data);
            Ncon=5;
            layers=[
                imageInputLayer(Nt, Nele)
                convolution2dLayer([Nt Nele], Ncon, 'Stride', [0 0])];
        end
    end
end

