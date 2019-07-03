import BCI_Module.BrainAmpData


%計測したデータをBCIに入力する前に
%このスクリプトを使ってデータをフォーマッティングします

%使用した計測アンプによって波形データのフォーマットのやり方が
%違ってくるので，抽象クラスExperimentDataの
%静的メソッドformatdataを使って対応するクラスを取り出します．
%（実際に波形のフォーマットを行うのは抽象メソッドExpandData）
ExpData=Experimentdata.formatData(EBioAmp.BrainAmp);


%各実験パラメータをセットしていきます
ExpData.File='20181120_SSVEPMCCCCA_B30_0010.mat';	%計測データの名前です
ExpData.Electrodes = ...			%各電極が国際10-20法のどの位置から取得した
	[												%波形なのかを順番に記述していきます
		EInternational1020.AFz;
		EInternational1020.T7;
		EInternational1020.Cz;
		EInternational1020.T8;
		EInternational1020.P3;
		EInternational1020.Pz;
		EInternational1020.P4;
		EInternational1020.O1;
		EInternational1020.Oz;
		EInternational1020.O2;
	];
ExpData.SamplingFreq=250;				%計測データのサンプリング周波数[Hz]です
ExpData.BandPass=[0.5 100];				%計測データの周波数帯域です
ExpData.Notch=EHAMNoise.None;	%HAMフィルタ
ExpData.MeasureTime=265;				%実験の計測時間です
ExpData.StartOffset=0;							%スタートの開始をスタートから何秒遅らせるか
ExpData.TriggerTable='TrrigerTable2.mat';	%点滅開始のトリガが流れてきた時の
																		%動作を指定するトリガです

%最後にファイル名を決めながらデータを保存していきます
str1=split(string(ExpData.File), ".");
str=join([str1(1),"BCITest"], "_");
save(str, 'ExpData')
