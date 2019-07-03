%% [概要]
%このスクリプトではk-分割交差検証という機械学習でよく使われる
%分類器性能評価のアルゴリズムを用いて，設計したBCIの性能を評価します．
%k-分割交差検証については(https://mathwords.net/kousakakunin)が
%比較的分かりやすいです．

%% [パッケージのインポート]
%最初に実行結果を見やすくする為の処理と
%パッケージ（名前空間のようなもの）のインポートを行います
clear all	%#ok<CLALL> 
            %MATLABのIDEに溜まったワークスペースの変数を全て消去
close all	%現在表示されているグラフを全て除去
			%（このスクリプトを一回起動するとグラフが10ウィンドウ現れるため）

import BCI_Module.*	%BCIに用いるスクリプトが入っているパッケージ
import SSVEP_NN.*	%ニューラルネットワーク関連のスクリプトが
                    %入っているパッケージ（今回は使用せず）

%% [交差検証用データのセッティング]
%交差検証に用いるデータをセル配列(配列を入れる配列)Dataに
%入れておきます．（順番によって解析結果は変化なし）

Data={};

load('20181120_SSVEPMCCCCA_B30_0010_BCITest.mat');
Data=[Data, {ExpData}];
load('20181120_SSVEPMCCCCA_B30_0009_BCITest.mat');
Data=[Data, {ExpData}];
load('20181120_SSVEPMCCCCA_B30_0008_BCITest.mat');
Data=[Data, {ExpData}];
load('20181120_SSVEPMCCCCA_B30_0007_BCITest.mat');
Data=[Data, {ExpData}];
load('20181120_SSVEPMCCCCA_B30_0006_BCITest.mat');
Data=[Data, {ExpData}];
load('20181120_SSVEPMCCCCA_B30_0005_BCITest.mat');
Data=[Data {ExpData}];
load('20181120_SSVEPMCCCCA_B30_0004_BCITest.mat');
Data=[Data {ExpData}];
load('20181120_SSVEPMCCCCA_B30_0003_BCITest.mat');
Data=[Data {ExpData}];
load('20181120_SSVEPMCCCCA_B30_0002_BCITest.mat');
Data=[Data {ExpData}];
load('20181120_SSVEPMCCCCA_B30_0001_BCITest.mat');
Data=[Data {ExpData}];

%% [BCI構成の設定]
%入力された脳波をどのように処理するのかを記述していきます．
%１．入力の設定
%	BCIでは”数秒間”の脳波に対して「どのような成分が含まれていくのか」を
%	検出したい場合が多いので，長時間の波形データについても細かい
%	区間（以降，エポック）に分割して，そのそれぞれについて
%	必要な情報を抽出し，それに応じた判断を下していきます
%
%２．前処理・特徴量抽出の設定
%	今回は統計解析の分野で良く用いられる正準相関分析（CCA）と呼ばれる手法
%	によって計測した脳波から不要な情報を取り除いた上で，
%	特徴量を抽出していきます．
%
%３．分類器の設定
%	今回は線形判別分析(LDA)という比較的簡単な分類器によって
%	SSVEPと呼ばれる脳波成分が発生しているかどうかを判別しました．
%

%エポックの設定（１．）
timeWindow=2;	%各エポックの時間長[s]
overlap=0.5;		%前のエポックと次のエポックの重なり率
					%([0 1]の範囲で設定)

%CCAの出力の設定（２．）
 CCAOutput=...
    [ 
      ECCAOutput.CorrelationEfficient	%相関係数
      ECCAOutput.SpatialFilter			%空間フィルタのパラメータ
    ];


InputModule=EpochDivider(timeWindow, overlap);	%（１．）
ProcessingModules=...	%（２．）
    {
        CCAModule([7 15], 2, 2, CCAOutput, EWindowList.Hann)
     };
OutputMod=LDAMod(true, ECCAOutput.CorrelationEfficient); 	%（３．）

%クラスBCIのコンストラクタによって，内部で初期設定が始まります
bci=BCI(InputModule,...
    ProcessingModules,...
    OutputMod);

%残しておくと結果が見づらくなるのでワークスペースから消去
clear InputModule ProcessingModules OutputMod


%% [トレーニングとテストの実行]
%k-交差検証による平均正答率を構造体Result内の変数scoreに返します．
%また，tic-toc関数によって計測した計算時間をCalclateTime，
%正答率の推定期待値をMeanScore，推定分散値をVarianceに返します．

tic
Result.score=bci.crossevaluate(Data);%前セクションで生成したBCIインスタンスに
									 %データのセル配列を入力します
Result.CalclateTime=toc;
Result.MeanScore=mean(Result.score);
Result.Variance=var(Result.score);
