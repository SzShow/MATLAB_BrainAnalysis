%%
%1.SettingExperimentData
clear E C A


 E=ExperimentDataClass_plot;

    %BrainAmp�Ŏ�����f�[�^�̃t�@�C����
    E.Filename='20171215_ComparingCombination_B29_0002.mat';
    
    %���莞�̃p�����[�^
    E.Fs=1000;    %�T���v�����O���g��[Hz]
    E.Ny=15;      %�d�ɐ��i�g���K�[�͏����j
    E.Ts=300;     %�v������[s]
    E.To=0;      %�g���K�[���͂���̃I�t�Z�b�g����[s]
    
    %��͎��̃p�����[�^
    E.Tw=1;         %���͎���
    E.Ti=0.5;       %���͊Ԋu
    
    %�d�Ɉʒu�Ɠd�ɔԍ��̑Ή�
    E.El=E.Preset_15;
    
    %�_�Ŏ��g��
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

    %�������@�̐ݒ�
    %1.AverageCombination
    %2.NativeCombination
    %3.BipolarCombination
    %4.LaplacainCombination
    %5.MinimumEnergyCombination
    %6.MaximumEnergyCombination
    C.Method=6;
    
    %3.bipolar_combination�p�̓d�ɂ̑g�ݍ��킹
    %Ebi�̏c�̒����͂�����ł��ǉ�����OK
    C.Ebi=C.BipPreset_15;

    %4.laplacian_combination�p�̓d�ɂ̑g�ݍ��킹
    %�ܗ�̃Z���z�u������Ȃ����ƁI
    C.Ela=C.LapPreset_15;
    
    %5.mec�����6.mcc�p�̃p�����[�^
    C.f=13;   %���ׂ������g��[Hz]
    C.Nh=2;   %f�ɑ΂����Ԗڂ̍����g�܂Œ��ׂ邩�̐�
    C.DetectionMode=1; %Ns�𐧌����邩
    
%C=C.operate(E);


%%

%3.ViewingClass

V=ViewingClass;

%%

%3.AnalysisMultiChannelData
clear A

A=AnalysisClass;

        %��͕��@�̐ݒ�
        %1.TASK-REST FFT
        %2.SSVEP_SNR
        %3.SN_Perge
        %4.Time-Frequency SNR
        %5.SSVEPDetection
        A.Method=5;

        A.ZeroP=1;

        %1.TASK-REST FFT�p�̐ݒ�
        A.TRSpan=10;  %�P�ʂ�[s]
        A.TRRepeat=3; %�J��Ԃ���

        %2.SSVEP_SNR�p
        A.StasticMode=1;
        A.SNRFrequency=13;
        A.SNRNh=2;
        
        %3.NoiseCheck�p
        A.NoiseNh=2;
        A.WhitenFilter=1;
        
        %4.T-F_SNR�p
        A.FrequencySpan=(2:1:20);
        
        %5.SSVEPDetection�p
        %5-1.SNRClassification
        %5-2.SNRClassification+Threshould
        %5-3.SNRClassification+Thr+P300
        %5-4.CCAClassification
        A.DetectionMode=1;
        A.thr=1.1;
        A.Combination=2;
        
    
    A=A.operate(E, C, V);

