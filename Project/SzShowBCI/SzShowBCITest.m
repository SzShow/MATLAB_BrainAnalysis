%% [パッケージのインポート]
clear all
close all
import BCI_Module.*
import SSVEP_NN.*
addpath('ExpData')

%% [トレーニング用実験データ生成]
Training={};

load('20181120_SSVEPMCCCCA_B30_0001_BCITest.mat');
Training=[Training, {ExpData}];
load('20181120_SSVEPMCCCCA_B30_0002_BCITest.mat');
Training=[Training, {ExpData}];
load('20181120_SSVEPMCCCCA_B30_0003_BCITest.mat');
Training=[Training, {ExpData}];
load('20181120_SSVEPMCCCCA_B30_0004_BCITest.mat');
Training=[Training, {ExpData}];
load('20181120_SSVEPMCCCCA_B30_0005_BCITest.mat');
Training=[Training, {ExpData}];

 
%% [テスト用実験データ生成]
Test={};

load('20181120_SSVEPMCCCCA_B30_0006_BCITest.mat');
Test=[Test {ExpData}];
load('20181120_SSVEPMCCCCA_B30_0007_BCITest.mat');
Test=[Test {ExpData}];
load('20181120_SSVEPMCCCCA_B30_0008_BCITest.mat');
Test=[Test {ExpData}];
load('20181120_SSVEPMCCCCA_B30_0009_BCITest.mat');
Test=[Test {ExpData}];
load('20181120_SSVEPMCCCCA_B30_0010_BCITest.mat');
Test=[Test {ExpData}];

%% [BCIモジュールの生成]
timeWindow=2;
overlap=0.5;

CCAOutput=...
[   ECCAOutput.CorrelationEfficient
    ECCAOutput.SpatialFilter];

InputModule=EpochDivider(timeWindow, overlap);
ProcessingModules=...
    {CCAModule([7 15], 2, CCAOutput)};
OutputMod=LDAMod; 

bci=BCI(InputModule,...
    ProcessingModules,...
    OutputMod);

clear InputModule ProcessingModules OutputMod

%% [トレーニングとテストの実行]
bci=bci.train(Training);

[c, E, Y]=bci.test(Test);

%% [結果の評価]

BCIEvaluator.CompareCorrectCommand(E, Y, c);
CorrectRate=BCIEvaluator.CalclateCorrectRate(Y,c);