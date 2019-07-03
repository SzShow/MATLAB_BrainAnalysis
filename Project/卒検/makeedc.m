function [OUT] = makeedc(datatype)
%UNTITLED TrainingDataClass��\�ߍ쐬���܂��D
%   BrainAmp��WFDB�f�[�^�x�[�X�ɑΉ����Ă���C���̊֐��ł�
%   �f�[�^�Ƃ��Ċ܂܂�Ȃ����l���֐����p�����[�^�Ƃ��ē��͂��邱�Ƃɂ����
%   SSVEPAnalyzer.m�̕��͂��Ȍ��ɕ\���܂��D

    switch datatype
        case 'BrainAmp'
            EDC=ExperimentDataClass;
            EDC.Filename='20171215_ComparingCombination_B29_0002';
            %���莞�̃p�����[�^
            EDC.SamplingFrequency=1000;    %�T���v�����O���g��[Hz]
            EDC.MeasurementTime=300;     %�v������[s]
            EDC.OffsetTime=0;      %�g���K�[���͂���̃I�t�Z�b�g����[s]
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
            EDC.MeasurementTime=300;     %�v������[s]
            EDC.OffsetTime=30;      %�g���K�[���͂���̃I�t�Z�b�g����[s]
        
    end
    
    OUT=EDC.operate;

end

