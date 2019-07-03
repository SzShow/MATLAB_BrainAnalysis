classdef SSVEPClassifier
    %UNTITLED このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
        Method
    end
    
    methods
        function obj = SSVEPClassifier(m,inputArg)
            %UNTITLED このクラスのインスタンスを作成
            %   詳細説明をここに記述
            obj.Method = m;
        end
        
        function outputArg = classify(obj,inputArg)
            %METHOD1 このメソッドの概要をここに記述
            %   詳細説明をここに記述
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

