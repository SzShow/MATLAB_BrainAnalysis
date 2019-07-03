classdef VRCCompareHistogram
    %UNTITLED ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties
        ExpectedValue1
        Variance1
        ExpectedValue2
        Variance2
    end
    
    methods
        function obj = VRCCompareHistogram(dpc, edc, f)
            %�ϐ����
            Lf=edc.FlickerList;
            If=edc.FlickerIndex;
            Df=edc.FlickerDuration;
            Fs=edc.SamplingFrequency;
            
            s=string({'f', round(f)});
            s=join(s, "");
            s=char(s);
            Y=dpc.ExtractedFeature.(s);
            
            %�ړI���g���̔z��̒�����ݒ�
            Duration=Df(1+find(~(If-f)));
            Data1=zeros(Duration, 1);
            Data2=zeros(length(Lf)-Duration, 1);
            
            %���ʊJ�n
            n=1;
            m=1;
            for t=1:length(Lf)
                if Lf(t)==f
                    Data1(n)=Y(t);
                    n=n+1;
                else
                    Data2(m)=Y(t);
                    m=m+1;
                end
            end
            
            %�}��
            figure();
            subplot (1, 2, 1);
            histogram(Data1);
            subplot (1, 2, 2);
            histogram(Data2);
            
            %���v�l�v�Z
            obj.ExpectedValue1=mean(Data1);
            obj.ExpectedValue2=mean(Data2);
            obj.Variance1=var(Data1);
            obj.Variance2=var(Data2);
            
            
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 ���̃��\�b�h�̊T�v�������ɋL�q
            %   �ڍא����������ɋL�q
            outputArg = obj.Property1 + inputArg;
        end
    end
end

