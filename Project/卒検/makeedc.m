function [OUT] = makeedc(datatype)
%UNTITLED TrainingDataClassを予め作成します．
%   BrainAmpとWFDBデータベースに対応しており，この関数では
%   データとして含まれない数値を関数内パラメータとして入力することによって
%   SSVEPAnalyzer.mの文章を簡潔に表します．

    switch datatype
        case 'BrainAmp'
            EDC=ExperimentDataClass;
            EDC.Filename='20171215_ComparingCombination_B29_0002';
            %測定時のパラメータ
            EDC.SamplingFrequency=1000;    %サンプリング周波数[Hz]
            EDC.MeasurementTime=300;     %計測時間[s]
            EDC.OffsetTime=0;      %トリガー入力からのオフセット時間[s]
            A=load('FlickerList20171115.mat');
            EDC.FlickerIndex=[7 10 13 15];
            EDC.FlickerList=A.FlickerList;
            EDC.ElectrodeList=EDC.Preset_15;
            EDC.DataSource='BrainAmp';
            
        case 'WFDB'
            EDC=WFDBEDC;
            EDC.DataSource='WFDB';
            EDC.Filename='S003a';
            EDC.FlickerIndex=[6.66 7.5 8.57 10 12];
            EDC.FlickerList=[6.66 7.5 8.57 10 12];
            EDC.FlickerOrder=[6.66 6.66 6.66 7.5 7.5 7.5 ...
                                8.57 8.57 8.57 10 10 10 12 12 12];
            EDC.MeasurementTime=300;     %計測時間[s]
            EDC.OffsetTime=30;      %トリガー入力からのオフセット時間[s]
        
    end
    
    OUT=EDC.operate;

end

