function [OUT] = maketdc(datatype)
%UNTITLED TrainingDataClass��\�ߍ쐬���܂��D
%   BrainAmp��WFDB�f�[�^�x�[�X�ɑΉ����Ă���C���̊֐��ł�
%   �f�[�^�Ƃ��Ċ܂܂�Ȃ����l���֐����p�����[�^�Ƃ��ē��͂��邱�Ƃɂ����
%   SSVEPAnalyzer.m�̕��͂��Ȍ��ɕ\���܂��D

    switch datatype
        case 'BrainAmp'
            TDC.Filename='20171215_ComparingCombination_B29_0002';
            %���莞�̃p�����[�^
            TDC.SamplingFrequency=1000;    %�T���v�����O���g��[Hz]
            TDC.MeasurementTime=300;     %�v������[s]
            TDC.OffsetTime=0;      %�g���K�[���͂���̃I�t�Z�b�g����[s]
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
            TDC.MeasurementTime=180;     %�v������[s]
            TDC.OffsetTime=100;      %�g���K�[���͂���̃I�t�Z�b�g����[s]
        
    end
    
    OUT=TDC.operate;

end

