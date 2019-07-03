classdef EDataSpecification < uint32
    %UNTITLED このクラスの概要をここに記述
    %   詳細説明をここに記述
    methods (Static=true)
        %入力データの並べ替え
        function o=DataPermute(i, rule)
            
            %ローカル変数生成
            o=i;
            order=[0 0 0];
            S=i.Specification;
            
            %n次元目の配列の移転先を決定
            for n=1:3
                %i番目の列挙体との比較
                for i=1:3
                    if uint(S{n})==i
                        order(n)=i;
                    end
                end

            end
            
            %permute実行
            o.Signal=permute(i.Signal, order);
            
        end
    end
    
    enumeration
        Data (1)
        Chanel (2)
        
        Epoch (3)
        Branch (4)
    end
end

