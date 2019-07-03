classdef ViewingClass
    %UNTITLED このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
        %3.NoiseCheck用パラメータ
        ChosenPartition=3;
        
    end
    
    methods
        %%
        function []=snrcheck(obj, E, C, A)
            
            figure;
            plot(1/E.Fs+(E.Ti*obj.ChosenPartition-E.To):1/E.Fs:E.Tw+(E.Ti*obj.ChosenPartition-E.To), A.R(:, obj.ChosenPartition));
            xlabel('Time[s]','FontSize',24)
            ylabel('Voltage[μV]','FontSize',24)
            str=string({C.MethodName, '_', E.Subject});
            title(char(str),'FontSize',28)            
            set(gca,'FontSize',24)            
            
            if A.WhitenFilter==1
            figure;
            plot(E.Tw-E.To:E.Ti:E.Ts-E.To, A.Vw);
            xlabel('Time[s]','FontSize',24)
            ylabel('Variance[μV^2]','FontSize',24)
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

