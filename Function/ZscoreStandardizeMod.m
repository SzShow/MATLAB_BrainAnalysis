classdef ZscoreStandardizeMod< PreProcessingModule
    %UNTITLED4 このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
        Property1
    end
    
    methods     
        function Output = process(obj,Input, ~)
            %METHOD1 このメソッドの概要をここに記述
            %   詳細説明をここに記述
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

