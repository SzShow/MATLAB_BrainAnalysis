%% [Section0. Abstract]
%
%SSVEPを解析するためのプログラムです．
%パラメータや機能の追加・調整がしやすいように設計しました．
%このスクリプトを実行することによって全体の処理が開始されます．
%
%各セクションは
%・クラスのインスタンス構成
%・クラスのプロパティ記述
%・クラスの主機能起動
%の三つより成り立っています．
%
%一方でセクションの構成は，
%[セクション１]　訓練データの取得
%[セクション２]　訓練データを用いたキャリブレーション
%[セクション３]　テストデータの取得
%[セクション４]　テストデータのプロセッシング
%[セクション５]　解析結果の表示
%となっており，それぞれのセクションに対応するクラスのメソッドより
%処理が実行されます．

%% [Section1. TrainingData Acquiration]
%訓練データを取得するためのプログラムです．
%このセクションではBrainAmpから取得したデータを.matファイルに変換したものを
%代入することによって
%

TDC=TrainingDataClass;
        
    MakeMode=true;
    
    if MakeMode
        TDC=maketdc('WFDB'); %#ok<UNRCH>
    else
        A=load('TDC_20171215_ComparingCombination_B29_0002.mat');
        TDC=A.TDC;
        clear A
    end
    
    

%% [Section2. Pre-Processing Set-Up]

PPC=PreprocessClass(TDC);

    %処理方法の設定
    %MEC: 雑音成分の最小化
    %MCC: SN比の最大化
    %
    PPC.Method='MCC';
    
    %3.bipolar_combination用の電極の組み合わせ
    %Ebiの縦の長さはいくらでも追加してOK
%    PPC.Ebi=PPC.BipPreset_15;

    %4.laplacian_combination用の電極の組み合わせ
    %五列のセル配置を崩さないこと！
%    PPC.Ela=PPC.LapPreset_15;
    
    %5.mecおよび6.mcc用のパラメータ
    PPC.MECNh=2;   %fに対し何番目の高調波まで調べるかの数
    %PPC.MECth=10;  %雑音成分の何%残すようにフィルターの数を設定するか
    %PPC.DetectionMode=1; %Nsを制限するか
    
    
%Calibration

    

PPC=PPC.calibrate;

%% [Section3.TestData Acquiration]
%

EDC=ExperimentDataClass;


    MakeMode=true;
    
    if MakeMode
        EDC=makeedc('WFDB'); %#ok<UNRCH>
    else
        A=load('EDC_20171215_ComparingCombination_B29_0002.mat');
        EDC=A.EDC;
    end
    
EDC=EDC.operate;

%% [Section4.Data Processing]
%

DPC=DataProcessingClass(TDC, PPC, EDC);

    %前処理の設定

    %特徴量の計算
    %1.DFTとユール・ウォーカー法を用いたSN比
    %3.正準相関分析(Canonical Correlation Analysis:CCA)による相関係数
    %5.DFTによるスペクトル推定
    DPC.WindowTime=2;
    DPC.IntervalTime=0.5;
    DPC.ExtractFeatureModeIs=5;
    DPC.SNR_NumberOfHarmonics=2;
    
    
    %パターン認識の設定
    
DPC=DPC.operate;

%オプション機能
[CorrectSSVEPCount,CorrectSSVEPRate]=DPC.checkcorrectssvep;

    
%% [Section5.Viewing Result]
%

VRC=ViewingResultClass(TDC, PPC, EDC, DPC);

    %波形の図示
    VRC.ActiveViewWave=[1, 1, 1];%[トレーニングデータ, テストデータ, 前処理済]
    
    %特徴量の図示
    
    %パターン認識結果の図示
    VRC.FlickeModeVisibleIs=1;
    
    %統計量の計算
    %1.点滅時と非点滅時のヒストグラムの表示
    VRC.StasticalCalclateMode=1;
    VRC.ComparedFrequency=6.66;
    
VRC=VRC.operate;



