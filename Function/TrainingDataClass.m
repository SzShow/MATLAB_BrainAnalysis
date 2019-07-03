classdef TrainingDataClass
    %UNTITLED このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    
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
        SamplingFrequency double              %サンプリング周波数：Fs
        MeasurementTime              %計測時間：Tm
        ElectrodeList              %電極位置と番号の対応表：Le
        FlickerList              %点滅周波数と時間の対応表：Lf
        DataSource
        FlickerOrder
        
        %I:取得条件
        OffsetTime              %トリガーからのオフセット：To
        
        %O:計測データ
        TrainingData               %データ行列：Dt
        NumberOfElectrode              %電極数：Ne
        NumberOfSample      %サンプル点の総数：Ns
        NumberOfFrequency   %点滅周波数の数:Nf
        FlickerFrequency
        FlickerIndex
        
        %O:付加情報
        Date            %実験日
        Title           %実験名
        Subject         %被験者番号
        TrialNumber     %試行番号
        
        
    end
    
    properties(Dependent)

    end
    
    
    methods       
    %% [プロパティへのアクセス]
        %このクラスのゲットメソッド

    %% [Internal: 波形のロードと実験条件のセッティング]
    %   
    %この関数でBrainAmpから取得した脳波の読み取りと，パラメータの
    %セッティングを行います．
        
        function [obj, eeg]=brainampsetting(obj)
            
            %パラメータ略称の設定
            Tm=obj.MeasurementTime;
            Fs=obj.SamplingFrequency;
            
            %   [波形の読み込み]
            %予めプロパティFilenameに記載された名前を持つファイルを
            %読み込みます
            load(obj.Filename); %#ok<EMLOAD>
            
            %   [パラメータの計算]
            obj.NumberOfElectrode=length(eeg(:,1))-1; %#ok<EMNODEF>
            obj.NumberOfSample=Tm*Fs;
            
            %付加情報の取得
            C1=strsplit([obj.Filename],'_');    %日付，実験名，被験者用
            C2=strsplit(C1{1,4},'.');           %試行回数用
            [obj.Date]=C1{1,1};
            [obj.Title]=C1{1,2};
            [obj.Subject]=C1{1,3};
            [obj.TrialNumber]=C2{1,1};
            
        end
        
        %wfdbデータの取得
        function [obj, eeg]=wfdbsetting(obj)
            %WDFBデータの読み込み
            eeg=rdsamp(obj.Filename);
            info=wfdbdesc(obj.Filename);
            
            %パラメータ代入
            Tm=obj.MeasurementTime;
            Of=obj.FlickerOrder;
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
            w(win(1))=1;
            eeg=[eeg ;w];
        end
        
        
    %% [Internal: データの切り取り分割処理]
 
        %この関数では取得したデータについて，測定時間の長さ分に切り取った後，
        %その後に行うフィルタのキャリブレーションがし易いように各周波数に
        %計測脳波を分類します
        function [obj]=signalacquire(obj, eeg)
            
            %   [パラメータ略称の設定]
            Ne=obj.NumberOfElectrode;
            Ns=obj.NumberOfSample;
            Fs=obj.SamplingFrequency;
            To=obj.OffsetTime;
            Tm=obj.MeasurementTime;
            Lf=obj.FlickerList;
            If=obj.FlickerIndex;
            
            
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
            
            
            %   [点滅周波数の種類数の計算と点滅周波数による波形分類]
            %まず最初に分類した波形を入れるための構造体Tを準備します．
            %そのためには適切なフィールドを作成するために，
            %   １．計測時に点滅させた周波数の種類数
            %   ２．点滅させた周波数それぞれの長さ
            %を把握しなければなりません．
            %更に構造体の長さを可変長とするために，今回は必要なフィールド分の
            %大きさを持つテーブルを作成してからそれを構造体に変換し，
            %各フィールド内にある行列の大きさを点滅させた周波数それぞれの長さ
            %に対応させるようにしました．
            
            %1.点滅周波数の分布をヒストグラムより作成
            edges=0:20;
            h=histogram(obj.FlickerList, edges);
            
            %2.使用された点滅周波数のピックアップ
            Ff=[];%点滅周波数のリストを入れる配列
            FlickerEdges=[];%点滅周波数の合計点滅時間を入れる配列
            for i=1:length(edges)-1
                if h.BinCounts(i)>0
                    Ff=[Ff i-1];%周波数の値
                    FlickerEdges=[FlickerEdges h.BinCounts(i)];%点滅の長さ
                end
            end
            Nf=length(Ff);
            
            %3.トレーニングデータの構造体作成
            Dt=obj.trainingdatastruct(Nf, ...
                Ff, FlickerEdges);%構造体の定義
            
            %4.トレーニングデータの分類開始
            
            for f=1:Nf
                B=[];
                s=string({'f', Ff(f)});%次のテーブル名設定
                s=join(s,"");%string文字配列の連結
                for t=1:Tm
                    if Lf(t)==Ff(f)
                        A=Data(((t-1)*Fs)+1:t*Fs, :);
                        B=[B; A];
                    end
                end
                Dt.(char(s))= B;
            end
            
            obj.TrainingData=Dt;
            obj.NumberOfFrequency=length(Ff);
            obj.FlickerFrequency=Ff;
                 
        end
        
        function [obj]=wfdbacquire(obj, eeg)
            
            %   [パラメータ略称の設定]
            Ne=obj.NumberOfElectrode;
            Ns=obj.NumberOfSample;
            Fs=obj.SamplingFrequency;
            To=obj.OffsetTime;
            Tm=obj.MeasurementTime;
            If=obj.FlickerIndex;
            Of=obj.FlickerOrder;
            
            
            
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
            
            
            %   [点滅周波数の種類数の計算と点滅周波数による波形分類]
            %まず最初に分類した波形を入れるための構造体Tを準備します．
            %そのためには適切なフィールドを作成するために，
            %   １．計測時に点滅させた周波数の種類数
            %   ２．点滅させた周波数それぞれの長さ
            %を把握しなければなりません．
            %更に構造体の長さを可変長とするために，今回は必要なフィールド分の
            %大きさを持つテーブルを作成してからそれを構造体に変換し，
            %各フィールド内にある行列の大きさを点滅させた周波数それぞれの長さ
            %に対応させるようにしました．
            
            %点滅周波数データの取得
            win=rdann(obj.Filename, 'win');
            win=cast(win, 'uint32')-StartPoint;
            win=idivide(win, Fs, 'round');
            Lf=zeros(Tm,1);
            Fe=zeros(length(If)+1, 1);
            If=[0 If];
            ReplaceNum=0;
            n=1;
            for t=1:Tm
                if t==win(n)
                    switch mod(n, 2)
                        case 1
                            ReplaceNum=Of(ceil(n/2));
                            n=n+1;
                        case 0
                            ReplaceNum=0;
                            n=n+1;
                    end
                end
                Lf(t)=ReplaceNum;
                for i=1:length(If)
                    if ReplaceNum==0
                        Fe(1)=Fe(1)+1;
                    elseif ReplaceNum==If(i)
                        Fe(i)=Fe(i)+1;
                    end
                end
            end
            
            
            %3.トレーニングデータの構造体作成
            Nf=length(If);
            Dt=obj.trainingdatastruct(Nf, ...
                If, Fe);%構造体の定義
            
            %4.トレーニングデータの分類開始
            
            for f=1:Nf
                B=[];
                s=string({'f', round(If(f))});%次のテーブル名設定
                s=join(s,"");%string文字配列の連結
                for t=1:Tm
                    if Lf(t)==If(f)
                        A=Data(((t-1)*Fs)+1:t*Fs, :);
                        B=[B; A];
                    end
                end
                Dt.(char(s))= B;
            end
            
            obj.TrainingData=Dt;
            obj.NumberOfFrequency=length(If);
            obj.FlickerFrequency=If;
                 
        end

        
        %   [トレーニングデータ構造体の定義]
        function [T]=trainingdatastruct(obj, NumberOfFrequency, ...
                    FlickerFrequency, FlickerEdges)   %#codegen
                
            %   [パラメータ略称の設定]
            Ne=obj.NumberOfElectrode;
            Ns=obj.NumberOfSample;
            Fs=obj.SamplingFrequency;
            To=obj.OffsetTime;
            
            for n=1:NumberOfFrequency
                ZeroMatrix=zeros(Fs*FlickerEdges(n), Ne);
                s=string({'f', round(FlickerFrequency(n))});%次のテーブル名設定
                s=join(s,"");%string文字配列の連結
                T.(char(s))= ZeroMatrix;
            end
        end

    %% [Public: トレーニングデータの取得実行]
        %処理実行
        function [obj]=operate(obj)
            %実験条件の取得
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
