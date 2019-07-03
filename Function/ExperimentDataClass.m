classdef ExperimentDataClass
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
        DataSource
        Filename        %読み込みファイル
        SamplingFrequency double              %サンプリング周波数
        MeasurementTime              %計測時間
        ElectrodeList              %電極位置と番号の対応表
        FlickerList              %点滅周波数 
        FlickerIndex
        FlickerOrder
        
        %I:取得条件
        OffsetTime              %トリガーからのオフセット
        
        %O:計測データ
        TestData               %データ行列 
        NumberOfElectrode              %電極数
        NumberOfSample
        
        %O:付加情報
        Date            %実験日
        Title           %実験名
        Subject         %被験者番号
        TrialNumber     %試行番号
        
        
    end
    properties(Dependent)

    end
    
    methods
        %% [コンストラクター]
        %インスタンス生成と同時に実験パラメータを代入
%         function [obj]=ExperimentDataClass(EDC,PPC)
%            obj.ExperimentProperties=get(TDC, 'default');
%         global edc;
%         global ppc;
%         edc=EDC;
%         ppc=PPC;
%             
%         end
        %%
        %波形のロードと実験条件のセッティング
        function [obj, eeg]=brainampsetting(obj)
            
            %パラメータ略称の設定
            Tm=obj.MeasurementTime;
            Fs=obj.SamplingFrequency;
            
            %   [波形の読み込み]
            %予めプロパティFilenameに記載された名前を持つファイルを
            %読み込みます
            load(obj.Filename);
            
            %   [パラメータの計算]
            obj.NumberOfElectrode=length(eeg(:,1))-1; %#ok<NODEF>
            obj.NumberOfSample=Tm*Fs;
            
            %付加情報の取得
            C1=strsplit([obj.Filename],'_');    %日付，実験名，被験者用
            C2=strsplit(C1{1,4},'.');           %試行回数用
            [obj.Date]=C1{1,1};
            [obj.Title]=C1{1,2};
            [obj.Subject]=C1{1,3};
            [obj.TrialNumber]=C2{1,1};
        end
        
        function [obj, eeg]=wfdbsetting(obj)
            %WDFBデータの読み込み
            eeg=rdsamp(obj.Filename);
            info=wfdbdesc(obj.Filename);
            
            %パラメータ代入
            Tm=obj.MeasurementTime;
%             Of=obj.FlickerOrder;
            obj.SamplingFrequency=info.SamplingFrequency;
            Fs=cast(obj.SamplingFrequency, 'double');
            obj.NumberOfSample=Tm*Fs;
            
            %電極分別
            chnum=length(eeg(1, :));
            B=[];
            s={};
            for i=1:chnum
                if ~strcmp(info(1, i).Description, 'EEG')  
                    A=eeg(:, i);
                    B=[B A]; %#ok<AGROW>
                    s=[s, {info(1, i).Description}]; %#ok<AGROW>
                end
            end
            clear eeg
            eeg=B';
            
            %パラメータ代入
            obj.ElectrodeList=char(s);
            obj.NumberOfElectrode=length(eeg(:, 1));
            
            %トリガーベクトルの作成
            win=rdann(obj.Filename, 'win');
            w=zeros(1, length(eeg));
            w(win(17))=1;
            eeg=[eeg ;w];
        end
        
        %%
        %データの切り取り分割処理
        function [obj]=signalacquire(obj, eeg)
            %   [パラメータ略称の設定]
            Ne=obj.NumberOfElectrode;
            Ns=obj.NumberOfSample;
            Fs=obj.SamplingFrequency;
            To=obj.OffsetTime;
            Tm=obj.MeasurementTime;
            
            
            %   [最初のトリガー検出時刻の取得]
            %切り取りの時の基準を定めるために，最初にトリガーが検出された
            %時刻をサンプル点iとして設定します．
            
            for i=1:length(eeg)
                if(eeg(Ne+1,i)==1)
                    TrigerPoint=i;
                    break;
                end
            end
            
            
            %   [計測時間に合わせた計測データ切り取り]
            %最初に定めたサンプル点iを基準にして，オフセット時間To（計測開始が
            %最初のトリガーから何秒離れているか）や測定時間Tsを考慮しながら，
            %計測時間外のデータを除去します．
            %
            
            %1.切り取ったデータの器となる行列を用意
            Data=zeros(Ns,Ne);  
            
            %2.オフセット時間を秒からサンプル点に変更
            OffsetLength=To*Fs;           
            
            %3.トリガー開始からオフセットを引いて切り取り開始のプロット点を設定
            StartPoint=TrigerPoint-OffsetLength;                   
            
            %4.データの切り取り範囲をRcに設定
            %CutRange=[StartPoint (StartPoint+Ne)-1];      
            
            %5.電極ごとの切り取り実行
            for i=1:Ne                     
                Data(:,i)=eeg(i,StartPoint:(StartPoint+Tm*Fs)-1)';     
            end 
            
            obj.TestData=Data;
        end
        
        function [obj]=wfdbacquire(obj, eeg)
            
            %   [パラメータ略称の設定]
            Ne=obj.NumberOfElectrode;
            Ns=obj.NumberOfSample;
            Fs=obj.SamplingFrequency;
            To=obj.OffsetTime;
            Tm=obj.MeasurementTime;
%             If=obj.FlickerIndex;
%             Of=obj.FlickerOrder;
            
            
            
            %   [最初のトリガー検出時刻の取得]
            %切り取りの時の基準を定めるために，最初にトリガーが検出された
            %時刻をサンプル点iとして設定します．
            
            for i=1:length(eeg)
                if(eeg(Ne+1,i)==1)
                    TrigerPoint=i;
                    break;
                end
            end
            
            
            %   [計測時間に合わせた計測データ切り取り]
            %最初に定めたサンプル点iを基準にして，オフセット時間To（計測開始が
            %最初のトリガーから何秒離れているか）や測定時間Tsを考慮しながら，
            %計測時間外のデータを除去します．
            %
            
            %1.切り取ったデータの器となる行列を用意
            Data=zeros(Ns,Ne);  
            
            %2.オフセット時間を秒からサンプル点に変更
            OffsetLength=To*cast(Fs, 'double');           
            
            %3.トリガー開始からオフセットを引いて切り取り開始のプロット点を設定
            StartPoint=TrigerPoint-OffsetLength;                   
            
            %4.データの切り取り範囲をRcに設定
            %CutRange=[StartPoint (StartPoint+Ne)-1];      
            
            %5.電極ごとの切り取り実行
            for i=1:Ne                     
                Data(:,i)=eeg(i,StartPoint:(StartPoint+Tm*Fs)-1)';     
            end
            
            obj.TestData=Data;
                 
        end
        
        %%
        %処理実行
        function [obj]=operate(obj)
            switch obj.DataSource
                case 'BrainAmp'
                    [obj, eeg]=obj.brainampsetting;
                    obj=obj.signalacquire(eeg);
                    
                case 'WFDB'
                    [obj, eeg]=obj.wfdbsetting;
                    obj=obj.wfdbacquire(eeg);
            end
            

        end
    end
    
end

