classdef AcquiredSignalClass
    %AcquiredSignalClass 時間窓ごとに区切ったデータを管理するためのクラスです．
    %   このクラスには区切ったデータの波形，計測した時の時間，時間窓，点滅周波数
    %   などが入り，それぞれの機能として，前処理と特徴量抽出とパターン分類を自身
    %   で行うことができます．
    
    properties
        Signal   %取得信号
        PreProcessedSignal
        Feature
        Class
        
        t   %計測終了時間
        Ts  %時間窓
        Ff  %点滅周波数
    end
    
    methods
        function []=preprocess(PP)
            
        end
        
        function []=featureextraction(FeatureExtractionClass)
        end
        
        function []=classification(ClassificationClass)
        end
    end
    
end

