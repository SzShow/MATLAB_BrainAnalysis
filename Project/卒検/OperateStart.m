%%
%1.SettingExperimentData
clear E C A


 E=ExperimentDataClass_plot;

    %BrainAmpで取ったデータのファイル名
    E.Filename='20171215_ComparingCombination_B29_0002.mat';
    
    %測定時のパラメータ
    E.Fs=1000;    %サンプリング周波数[Hz]
    E.Ny=15;      %電極数（トリガーは除く）
    E.Ts=300;     %計測時間[s]
    E.To=0;      %トリガー入力からのオフセット時間[s]
    
    %解析時のパラメータ
    E.Tw=1;         %分析時間
    E.Ti=0.5;       %分析間隔
    
    %電極位置と電極番号の対応
    E.El=E.Preset_15;
    
    %点滅周波数
    E.Stimulus=zeros(300, 1);
    E.Stimulus(61:70)=7;
    E.Stimulus(81:90)=7;
    E.Stimulus(101:110)=7;
    E.Stimulus(121:130)=10;
    E.Stimulus(141:150)=10;
    E.Stimulus(161:170)=10;
    E.Stimulus(181:190)=13;
    E.Stimulus(201:210)=13;
    E.Stimulus(221:230)=13;
    E.Stimulus(241:250)=15;
    E.Stimulus(261:270)=15;
    E.Stimulus(281:290)=15;
    
    E.Ff=[7 10 13 15];

E=E.operate;
    


%%
%2.CombinateElectrodes
clear C A

C=CombinationClass;

    %処理方法の設定
    %1.AverageCombination
    %2.NativeCombination
    %3.BipolarCombination
    %4.LaplacainCombination
    %5.MinimumEnergyCombination
    %6.MaximumEnergyCombination
    C.Method=6;
    
    %3.bipolar_combination用の電極の組み合わせ
    %Ebiの縦の長さはいくらでも追加してOK
    C.Ebi=C.BipPreset_15;

    %4.laplacian_combination用の電極の組み合わせ
    %五列のセル配置を崩さないこと！
    C.Ela=C.LapPreset_15;
    
    %5.mecおよび6.mcc用のパラメータ
    C.f=13;   %調べたい周波数[Hz]
    C.Nh=2;   %fに対し何番目の高調波まで調べるかの数
    C.DetectionMode=1; %Nsを制限するか
    
%C=C.operate(E);


%%

%3.ViewingClass

V=ViewingClass;

%%

%3.AnalysisMultiChannelData
clear A

A=AnalysisClass;

        %解析方法の設定
        %1.TASK-REST FFT
        %2.SSVEP_SNR
        %3.SN_Perge
        %4.Time-Frequency SNR
        %5.SSVEPDetection
        A.Method=5;

        A.ZeroP=1;

        %1.TASK-REST FFT用の設定
        A.TRSpan=10;  %単位は[s]
        A.TRRepeat=3; %繰り返し回数

        %2.SSVEP_SNR用
        A.StasticMode=1;
        A.SNRFrequency=13;
        A.SNRNh=2;
        
        %3.NoiseCheck用
        A.NoiseNh=2;
        A.WhitenFilter=1;
        
        %4.T-F_SNR用
        A.FrequencySpan=(2:1:20);
        
        %5.SSVEPDetection用
        %5-1.SNRClassification
        %5-2.SNRClassification+Threshould
        %5-3.SNRClassification+Thr+P300
        %5-4.CCAClassification
        A.DetectionMode=1;
        A.thr=1.1;
        A.Combination=2;
        
    
    A=A.operate(E, C, V);

