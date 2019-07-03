classdef ZscoreStandardizeMod< PreProcessingModule
    %UNTITLED4 ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties
        Property1
    end
    
    methods     
        function Output = process(obj,Input, ~)
            %METHOD1 ���̃��\�b�h�̊T�v�������ɋL�q
            %   �ڍא����������ɋL�q
            Nch=size(Input, 2);
            Output=zeros(size(Input));
            for n=1:Nch
                X=Input(:, n);
                Xmean=mean(X);
                Xstd=std(X);
                Output(:, n)=(X-Xmean)/Xstd;
            end
            
        end
    end
end

