classdef WFDBTDCMakeClass < TDCMakeClass
    %UNTITLED このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
        WFDBdescription
        WFDBFlashWindow uint32
    end
    
    methods (Access=private)  
        %% wfdbデータの取得
        function [obj]=wfdbsettingparam(obj)
            %変数宣言
            Tm=obj.MeasurementTime;
            
            %WDFBデータの読み込み
            DESC=wfdbdesc(obj.Filename);
            Fs=DESC.SamplingFrequency;
                        
            %アウトプット
            obj.RawData=rdsamp(obj.Filename);
            obj.SamplingFrequency=Fs;
            obj.WFDBdescription=DESC;
            obj.NumberOfSample=Tm*Fs;
            obj.WFDBFlashWindow=rdann(obj.Filename, 'win');
            %代入
        end
        
        %% 電極の操作
        function [obj]=wfdboperateelectrode(obj)
            %[パラメータ設定]
            Dr=obj.RawData;
            DESC=obj.WFDBdescription;
            
            %[電極分別]
            chnum=length(Dr(1, :));
            B=[];
            s={};
            for i=1:chnum
                %タグ名がEEG以外のチャンネルを回収
                if ~strcmp(DESC(1, i).Description, 'EEG')  
                    A=Dr(:, i);
                    B=[B A]; %#ok<AGROW>
                    %回収したチャンネルのタグ名をsに保管
                    s=[s, {DESC(1, i).Description}]; %#ok<AGROW>
                end
            end
            Dco=B';
            
            %[トリガーベクトルの作成]
            win=obj.WFDBFlashWindow; %WFDBから光点滅情報を回収
            w=zeros(1, length(Dco));
            w(win(1))=1;
            Dco=[Dco ;w];
            
            %パラメータ代入
            obj.ElectrodeList=char(s);
            obj.NumberOfElectrode=length(Dco(:, 1))-1;
            obj.CombinedData=Dco;
            obj.WFDBFlashWindow=win;
        end
           
        %% データ長の調整
        function [obj]=wfdbdatacut(obj)
            
            %   [パラメータ略称の設定]
            Ne=obj.NumberOfElectrode;
            Ns=obj.NumberOfSample;
            Fs=obj.SamplingFrequency;
            To=obj.OffsetTime;
            Dco=obj.CombinedData;
            win=obj.WFDBFlashWindow;
            
            %   [最初のトリガー検出時刻の取得]
            for i=1:length(Dco)
                if(Dco(Ne+1,i)==1)
                    TrigerPoint=i;
                    break;
                end
            end
            
            %   [切り取り開始地点の計算]  
            Offset=To*Fs;
            StartPoint=TrigerPoint-Offset;
            
            %   [切り取りの開始]
            Dcu=zeros(Ns,Ne);
            for i=1:Ne
                Dcu(:,i)=Dco(i,StartPoint:(StartPoint+Ns)-1)';
            end
            
            %点滅周波数データの変形
            win=win-StartPoint; %開始点を0点目に置き換える
            win=idivide(win, Fs, 'round');  %サンプル点→秒換算（四捨五入)
            
            obj.CutData=Dcu;
            obj.WFDBFlashWindow=win;
        end
        
        %% 点滅周波数の時系列データの生成
        function [obj]=wfdbtimeseriesgenerate(obj)
            
            %パラメータ代入
            Tm=obj.MeasurementTime;
            If=obj.FlickerIndex;
            Of=obj.FlickerOrder;
            win=obj.WFDBFlashWindow;
            

            
            %点滅周波数の時系列データを生成（変数準備）
            Lf=zeros(Tm,1); %FlickerList
            If=[0 If];
            Df=zeros(length(If), 1);    %各周波数の点滅長さ[秒]
            ReplaceNum=0;   %置き換える数字の保管場所
            n=1;    %点滅の進行状況
            
            %点滅周波数の時系列データを生成（処理実行）
            for t=1:Tm
                if t==win(n)
                    switch mod(n, 2)
                        case 1  %奇数は次の周波数へ
                            ReplaceNum=Of(ceil(n/2));
                            n=n+1;
                        case 0  %偶数は未点滅状態に戻る
                            ReplaceNum=0;
                            n=n+1;
                    end
                end
                %点滅周波数時系列への代入
                Lf(t)=ReplaceNum;
                %点滅の長さの計算
                for i=1:length(If)
                    if ReplaceNum==0
                        Df(1)=Df(1)+1;
                    elseif ReplaceNum==If(i)
                        Df(i)=Df(i)+1;
                    end
                end
            end
            
            %出力
            obj.FlickerList=Lf;
            obj.FlickerDuration=Df;
        end
        
        %% トレーニングデータの分類
        function obj=wfdbclassifydata(obj)
            %変数設定
            Lf=obj.FlickerList;
            Fs=obj.SamplingFrequency;
            If=obj.FlickerIndex;
            Tm=obj.MeasurementTime;
            Dcu=obj.CutData;
            
            %3.トレーニングデータの構造体作成            
%             for n=1:length(If)
%                 ZeroMatrix=zeros(Fs*Df(n), Ne);
%                 s=string({'f', round(If(n))});%次のテーブル名設定
%                 s=join(s,"");%string文字配列の連結
%                 T.(char(s))= ZeroMatrix;
%             end
            
            %4.トレーニングデータの分類開始
            
            for f=1:length(If)
                B=[];
                s=string({'f', round(If(f))});%次のテーブル名設定
                s=join(s,"");%string文字配列の連結
                for t=1:Tm
                    if Lf(t)==If(f)
                        A=Dcu(((t-1)*Fs)+1:t*Fs, :);
                        B=[B; A];
                    end
                end
                Dt.(char(s))= B;
            end
            
            obj.TrainingData=Dt;
            obj.NumberOfFrequency=length(If);
            obj.FlickerFrequency=If;
        end
        
    end
    
    methods (Access=public)
        function obj=operate(obj)
            obj=obj.wfdbsettingparam;
            obj=obj.wfdboperateelectrode;
            obj=obj.wfdbdatacut;
            obj=obj.wfdbtimeseriesgenerate;
            obj=obj.wfdbclassifydata;
        end
        
    end
    
end

