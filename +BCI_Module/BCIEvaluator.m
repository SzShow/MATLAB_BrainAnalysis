classdef BCIEvaluator
    %UNTITLED このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
        Property1
    end
    
    methods (Static=true)
        function CompareCorrectCommand(E,Y,c)
            t=0;
            for n=1:length(E)
                T=E{n}.EpochTimeList;
                figure()
                stem(T, Y(t+(1:length(T))), 'MarkerSize', 15);
                ax=gca;
                ax.FontSize=50;
                hold on
                scatter(T,c(t+(1:length(T))),120,'filled');
                legend({'Correct', 'Result'}, 'Location',...
                    'northwest','FontSize', 60);
                xlabel('Time[s]', 'FontSize', 60)
                ylabel('Frequency[Hz]', 'FontSize', 60)
                t=t+length(T);
            end


        end

        function o=CalclateCorrectRate(y, c)
            n=0;
            for index=1:length(y)
                if (y(index)==c(index))
                    n=n+1;
                end
            end

            o=(n/length(y))*100;

        end

    end
end

