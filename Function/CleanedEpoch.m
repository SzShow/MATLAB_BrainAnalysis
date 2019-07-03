classdef CleanedEpoch
    %UNTITLED このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
        TargetFreq
        Method
        Data
    end
    
    methods
        function obj = CleanedEpoch(f, m)
            %UNTITLED このクラスのインスタンスを作成
            %   詳細説明をここに記述
            obj.TargetFreq = f;
            obj.Method = m;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 このメソッドの概要をここに記述
            %   詳細説明をここに記述
            outputArg = obj.Property1 + inputArg;
        end
    end
end

