classdef ExperimentDataClass_plot
    %ExperimentDataClass
    %   実験データ、実験条件などの実験に関するステータスやデータをまとめる
    %   際に用いるクラスです。
    %   計測条件などの修正はこのクラスより作成されたインスタンスのパラメー
    %   タを調整することによってできます。
    %   このクラスは現状、BrainAmpより取得したファイルしか扱えません。
    %   また、ファイル名は必ず'日付＿実験名＿被験者＿試行回数.mat'と
    %   するようにしてください。
    
    properties(Constant)
        %電極のプリセット
        Preset_15={ 'P5', 'P3', 'P1', 'Pz', 'P2', ...
                    'P4', 'P6', 'PO7', 'PO3', 'POz', ...
                    'PO4', 'PO8', 'O1', 'Oz', 'O2'};
        Preset_5={  
            }
                
    end
    
    properties
        %I:計測条件
        Filename        %読み込みファイル
        Fs              %サンプリング周波数
        Ts              %計測時間
        El              %電極位置と番号の対応表
        Ff              %点滅周波数
        Stimulus        %現在の点滅周波数  
        
        %I:取得条件
        To              %トリガーからのオフセット
        Tw              %時間窓の長さ
        Ti              %解析間隔
        W               %窓関数
        
        %O:計測データ
        Y               %データ行列 
        Ny              %電極数
        Nt              %データ長
        Np              %データの総分割数
        Nw              %分割済みデータのサンプル数
        Fp              %各データ取得時の点滅周波数
        Ta
        T              %時間情報ベクトル
        
        %O:付加情報
        Date            %実験日
        Title           %実験名
        Subject         %被験者番号
        TrialNumber     %試行番号
        
        
    end
    properties(Dependent)

    end
    
    methods
        %%
        %データの切り取り分割処理
        function [obj]=dividedata(obj, eeg)
            %最初のトリガー検出時刻の取得
            Start=0;
            for i=1:length(eeg)
                if(eeg([obj.Ny]+1,i)==1)
                    Start=i;
                    break;
                end
            end
            
            %実験データの切り取り
            Data=zeros([obj.Nt],[obj.Ny]);
            Offset=[obj.To]*[obj.Fs];
            Ps=Start-Offset;
            for i=1:obj.Ny                      
                Data(:,i)=eeg(i,Ps:(Ps+obj.Nt)-1)';
            end
            
            %実験データの分割
            obj.Np=length(obj.Tw:obj.Ti:obj.Ts);
            Data2=zeros([obj.Tw]*[obj.Fs], [obj.Ny], obj.Np);
            try
                for i=1:obj.Np
                    Data2(:,:,i)=Data((i-1)*[obj.Fs]*[obj.Ti]+1:(i-1)*[obj.Fs]*[obj.Ti]+([obj.Tw]*[obj.Fs]), :);
                end
            catch
            end
            obj.T=-obj.To+obj.Tw:obj.Ti:-obj.To+obj.Ts;
            obj.Nw=obj.Tw*obj.Fs;
            [obj.Y]=Data2;            
        end
        
        %%
        %処理実行
        function [obj]=operate(obj)
            %実験条件の取得
            load([obj.Filename]);
            [obj.Nt]=[obj.Ts]*[obj.Fs];
            obj.Ta=1/obj.Fs-obj.To:1/obj.Fs:obj.Ts-obj.To;
            
            %付加情報の取得
            C1=strsplit([obj.Filename],'_');
            C2=strsplit(C1{1,4},'.');
            [obj.Date]=C1{1,1};
            [obj.Title]=C1{1,2};
            [obj.Subject]=C1{1,3};
            [obj.TrialNumber]=C2{1,1};
            
            %計測データの分割
            obj=obj.dividedata(eeg);
            
            %点滅情報の取得
            obj.Fp=zeros(obj.Np, 1);
            for p=1:obj.Np
                t=ceil(obj.Ti*p-obj.To);
                obj.Fp(p)=obj.Stimulus(t);
            end
        end
    end
    
end

