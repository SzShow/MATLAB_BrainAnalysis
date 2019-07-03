function [OUT] = maketdc(datatype)
%UNTITLED TrainingDataClassを予め作成します．
%   BrainAmpとWFDBデータベースに対応しており，この関数では
%   データとして含まれない数値を関数内パラメータとして入力することによって
%   SSVEPAnalyzer.mの文章を簡潔に表します．

    switch datatype
        case 'BrainAmp'
            TDC.Filename='20171215_ComparingCombination_B29_0002';
            %測定時のパラメータ
            TDC.SamplingFrequency=1000;    %サンプリング周波数[Hz]
            TDC.MeasurementTime=300;     %計測時間[s]
            TDC.OffsetTime=0;      %トリガー入力からのオフセット時間[s]
            A=load('FlickerList20171115.mat');
            TDC.FlickerList=A.FlickerList;
            TDC.ElectrodeList=TDC.Preset_15;
            TDC.DataSource='BrainAmp';
            
        case 'WFDB'
            TDC=WFDBTDCMakeClass;
            TDC.DataSource='WFDB';
            TDC.Filename='S003a';
            TDC.FlickerIndex=[6.66 7.5 8.57 10 12];
            TDC.FlickerOrder=[7.5 6.66 10 12 6.66 8.57 12 7.5];
            TDC.MeasurementTime=180;     %計測時間[s]
            TDC.OffsetTime=100;      %トリガー入力からのオフセット時間[s]
        
    end
    
    OUT=TDC.operate;

end

