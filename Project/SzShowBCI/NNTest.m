%% [パッケージのインポート]
clear all
close all
import BCI_Module.*
import SSVEP_NN.*

%% [トレーニング用実験データ生成]
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

%% [BCIモジュールの生成]
timeWindow=2;
overlap=0.5;

 CCAOutput=...
    [ 
%       ECCAOutput.CorrelationEfficient
%       ECCAOutput.SpatialFilter
        ECCAOutput.FilterOutput
    ];

%imageInputLayerの仕様により，全エポックのデータは同じでなければならない
Layer=[
    imageInputLayer
    ];

Options=['sgdm'];


InputModule=EpochDivider(timeWindow, overlap);
ProcessingModules=...
    {
        CCAModule([7 15], 2, 2, CCAOutput)
        FFTModule([5 20], EWindowList.Hann)
     };
OutputMod=LDAMod; 

bci=BCI(InputModule,...
    ProcessingModules,...
    OutputMod);

clear InputModule ProcessingModules OutputMod

%% [トレーニングとテストの実行]
tic
Result.score=bci.crossevaluate(Data);
Result.CalclateTime=toc;
Result.MeanScore=mean(Result.score);
Result.Variance=var(Result.score);
