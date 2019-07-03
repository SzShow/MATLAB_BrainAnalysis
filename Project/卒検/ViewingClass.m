classdef ViewingClass
    %UNTITLED ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties
        %3.NoiseCheck�p�p�����[�^
        ChosenPartition=3;
        
    end
    
    methods
        %%
        function []=snrcheck(obj, E, C, A)
            
            figure;
            plot(1/E.Fs+(E.Ti*obj.ChosenPartition-E.To):1/E.Fs:E.Tw+(E.Ti*obj.ChosenPartition-E.To), A.R(:, obj.ChosenPartition));
            xlabel('Time[s]','FontSize',24)
            ylabel('Voltage[��V]','FontSize',24)
            str=string({C.MethodName, '_', E.Subject});
            title(char(str),'FontSize',28)            
            set(gca,'FontSize',24)            
            
            if A.WhitenFilter==1
            figure;
            plot(E.Tw-E.To:E.Ti:E.Ts-E.To, A.Vw);
            xlabel('Time[s]','FontSize',24)
            ylabel('Variance[��V^2]','FontSize',24)
            str=string({C.MethodName, '_', E.Subject});
            title(char(str),'FontSize',28)            
            set(gca,'FontSize',24)             
            
            MeanVariance=mean(A.Vw);
            end
        end
        
        %%
        function [obj]=operate(obj, E, C, A)
            switch A.Method
                case 3
                    obj.snrcheck(E, C, A);
                    
            end
        end
    end
    
end

