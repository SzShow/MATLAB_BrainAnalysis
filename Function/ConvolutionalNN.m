classdef ConvolutionalNN
    %UNTITLED2 このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
        Property1
    end
    
    properties(Constant)

    end
    
    methods
        function obj = ConvolutionalNN(data)
            %UNTITLED2 このクラスのインスタンスを作成
            %   詳細説明をここに記述
            
            %データのサイズを分解
            [Nt, Nele, Nepo]=size(data);
            
            layers={
                imageInputLayer([Nt Nele 1])
                virtualComposeLayer()
                fftLayer()
                fullyConnectedCNNLayer()
                
                };
            
            obj.Property1 = data + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 このメソッドの概要をここに記述
            %   詳細説明をここに記述
            outputArg = obj.Property1 + inputArg;
        end
    end
end

