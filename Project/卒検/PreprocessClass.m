classdef PreprocessClass
    %UNTITLED3 このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties(Constant)
        
        
        %Bipolar用プリセット
        BipPreset_15={   'P5',   'PO7';
                         'P3',   'PO3';
                         'PO3',  'O1' ;
                         'P3',   'O1';
                         'P3',   'P1' ;
                         'P1',   'Pz' ;
                         'Pz',   'POz' ;
                         'Pz',   'Oz' ;
                         'POz',   'Oz' ;
                         'Pz',   'P2' ;
                         'P2',   'P4' ;
                         'P4',   'PO4' ;
                         'P4',   'O2' ;
                         'PO4',   'O2' ;
                         'P6',   'PO8' ;};
        
        %Laplacian用プリセット
        LapPreset_15={  'PO3',   'P3',   'POz',   'O1',   'PO7';
                        'POz',   'Pz',   'PO4',   'Oz',   'PO3';
                        'PO4',   'P4',   'PO8',   'O2',   'POz';};
    end
    
    properties
        Method  %前処理法
        SpatialFilter       %空間フィルタ
        EigenValue          %固有値
        DoLater
        
        %MEC, MCC用パラメータ
        
        MECNh  %高調波の数
    end
    
    methods
        %% [コンストラクター]
        %インスタンス生成と同時に実験パラメータを代入
        function [obj]=PreprocessClass(TDC)
%            obj.ExperimentProperties=get(TDC, 'default');
        global tdc;
        tdc=TDC;
            
        end
        
        %% [MECフィルターの設計]
        function [obj]=calibrate(obj)
            global tdc;
            Dt=tdc.TrainingData;
            Ff=tdc.FlickerFrequency;
            Fs=tdc.SamplingFrequency;
            Ne=tdc.NumberOfElectrode;
            
            for f=1:tdc.NumberOfFrequency
                if Ff(f)==0
                    continue;
                end
                
                s=string({'f', round(Ff(f))});%次のテーブル名設定
                s=join(s,"");%string文字配列の連結
                
                switch obj.Method
                    case 'MEC'
                        [~, W, e]=mec(Dt.(char(s)), Ff(f), obj.MECNh, Fs);
                    case 'MCC'
                        [~, W, e]=mcc(Dt.(char(s)), Ff(f), obj.MECNh, Fs);
                    otherwise
                        W=eye(Ne);
                        e=ones(Ne);
                end
                
                

                Mf.(char(s))=W;
                Ve.(char(s))=e;
                
            end
            
            obj.SpatialFilter=Mf;
            obj.EigenValue=Ve;
            
        end
        

        
    end
    
end

