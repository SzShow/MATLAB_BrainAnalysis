classdef SuppressDCMod< PreProcessingModule
    %UNTITLED4 このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
    end
    
    methods     
        function Output = process(obj,Input, ~)
            %METHOD1 このメソッドの概要をここに記述
            %   詳細説明をここに記述
            Output=detrend(Input);
        end
    end
end
