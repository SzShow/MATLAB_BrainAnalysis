classdef TDCMakeClass < TrainingDataClass
    %UNTITLED2 このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
        tdcObject TrainingDataClass
        RawData
        CombinedData
        CutData
        FlickerDuration
    end
    
    methods (Access=private)
    %% [BrainAmp用]
    %   
    %この関数でBrainAmpから取得した脳波の読み取りと，パラメータの
    %セッティングを行います．
        
%         function [obj, eeg]=brainampsetting(obj)
%             
%             %パラメータ略称の設定
%             Tm=obj.MeasurementTime;
%             Fs=obj.SamplingFrequency;
%             
%             %   [波形の読み込み]
%             %予めプロパティFilenameに記載された名前を持つファイルを
%             %読み込みます
%             load(obj.Filename); %#ok<EMLOAD>
%             
%             %   [パラメータの計算]
%             obj.NumberOfElectrode=length(eeg(:,1))-1; %#ok<EMNODEF>
%             obj.NumberOfSample=Tm*Fs;
%             
%             %付加情報の取得
%             C1=strsplit([obj.Filename],'_');    %日付，実験名，被験者用
%             C2=strsplit(C1{1,4},'.');           %試行回数用
%             [obj.Date]=C1{1,1};
%             [obj.Title]=C1{1,2};
%             [obj.Subject]=C1{1,3};
%             [obj.TrialNumber]=C2{1,1};
%             
%         end
%         
%         function [obj]=setsignalstart(obj, eeg)
%             
%             %   [パラメータ略称の設定]
%             Ne=obj.NumberOfElectrode;
%             Ns=obj.NumberOfSample;
%             Fs=obj.SamplingFrequency;
%             To=obj.OffsetTime;
%             Tm=obj.MeasurementTime;
%             Lf=obj.FlickerList;
%             If=obj.FlickerIndex;
%             
%             
%             %   [最初のトリガー検出時刻の取得]
%             %切り取りの時の基準を定めるために，最初にトリガーが検出された
%             %時刻をサンプル点iとして設定します．
%             
%             for i=1:length(eeg)
%                 if(eeg(Ne+1,i)==1)
%                     TrigerPoint=i;
%                     break;
%                 end
%             end
%             
%             
% 
%             Data=zeros(Ns,Ne);  
%             OffsetLength=To*Fs;           
%             StartPoint=TrigerPoint-OffsetLength;                   
%             for i=1:Ne                     
%                 Data(:,i)=eeg(i,StartPoint:(StartPoint+Tm*Fs)-1)';     
%             end
%             
%             
%             %   [点滅周波数の種類数の計算と点滅周波数による波形分類]
%             %まず最初に分類した波形を入れるための構造体Tを準備します．
%             %そのためには適切なフィールドを作成するために，
%             %   １．計測時に点滅させた周波数の種類数
%             %   ２．点滅させた周波数それぞれの長さ
%             %を把握しなければなりません．
%             %更に構造体の長さを可変長とするために，今回は必要なフィールド分の
%             %大きさを持つテーブルを作成してからそれを構造体に変換し，
%             %各フィールド内にある行列の大きさを点滅させた周波数それぞれの長さ
%             %に対応させるようにしました．
%             
%             %1.点滅周波数の分布をヒストグラムより作成
%             edges=0:20;
%             h=histogram(obj.FlickerList, edges);
%             
%             %2.使用された点滅周波数のピックアップ
%             Ff=[];%点滅周波数のリストを入れる配列
%             FlickerEdges=[];%点滅周波数の合計点滅時間を入れる配列
%             for i=1:length(edges)-1
%                 if h.BinCounts(i)>0
%                     Ff=[Ff i-1];%周波数の値
%                     FlickerEdges=[FlickerEdges h.BinCounts(i)];%点滅の長さ
%                 end
%             end
%             Nf=length(Ff);
%             
%             %3.トレーニングデータの構造体作成
%             Dt=obj.trainingdatastruct(Nf, ...
%                 Ff, FlickerEdges);%構造体の定義
%             
%             %4.トレーニングデータの分類開始
%             
%             for f=1:Nf
%                 B=[];
%                 s=string({'f', Ff(f)});%次のテーブル名設定
%                 s=join(s,"");%string文字配列の連結
%                 for t=1:Tm
%                     if Lf(t)==Ff(f)
%                         A=Data(((t-1)*Fs)+1:t*Fs, :);
%                         B=[B; A];
%                     end
%                 end
%                 Dt.(char(s))= B;
%             end
%             
%             obj.TrainingData=Dt;
%             obj.NumberOfFrequency=length(Ff);
%             obj.FlickerFrequency=Ff;
%                  
%         end
        

    end
    
    %% [Public: トレーニングデータの取得実行]
%     methods (Access=public)
%     
%         %処理実行
%         function [obj]=TDCMakeClass(obj, TDC)
%             %実験条件の取得
%             obj.tdcObject=TDC;
%             
%             switch obj.DataSource
%                 case 'BrainAmp'
%                     [obj, eeg]=obj.brainampsetting;
%                     obj=obj.signalacquire(eeg);
%                     
%                 case 'WFDB'
%                     [obj, eeg]=obj.wfdbsettingparam;
%                     obj=obj.wfdbacquire(eeg);
%             end
%            
%             
% 
%         end
%     end
end

