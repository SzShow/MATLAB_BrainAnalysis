%% [Section0. Abstract]
%
%SSVEP����͂��邽�߂̃v���O�����ł��D
%�p�����[�^��@�\�̒ǉ��E���������₷���悤�ɐ݌v���܂����D
%���̃X�N���v�g�����s���邱�Ƃɂ���đS�̂̏������J�n����܂��D
%
%�e�Z�N�V������
%�E�N���X�̃C���X�^���X�\��
%�E�N���X�̃v���p�e�B�L�q
%�E�N���X�̎�@�\�N��
%�̎O��萬�藧���Ă��܂��D
%
%����ŃZ�N�V�����̍\���́C
%[�Z�N�V�����P]�@�P���f�[�^�̎擾
%[�Z�N�V�����Q]�@�P���f�[�^��p�����L�����u���[�V����
%[�Z�N�V�����R]�@�e�X�g�f�[�^�̎擾
%[�Z�N�V�����S]�@�e�X�g�f�[�^�̃v���Z�b�V���O
%[�Z�N�V�����T]�@��͌��ʂ̕\��
%�ƂȂ��Ă���C���ꂼ��̃Z�N�V�����ɑΉ�����N���X�̃��\�b�h���
%���������s����܂��D

%% [Section1. TrainingData Acquiration]
%�P���f�[�^���擾���邽�߂̃v���O�����ł��D
%���̃Z�N�V�����ł�BrainAmp����擾�����f�[�^��.mat�t�@�C���ɕϊ��������̂�
%������邱�Ƃɂ����
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

    %�������@�̐ݒ�
    %MEC: �G�������̍ŏ���
    %MCC: SN��̍ő剻
    %
    PPC.Method='MCC';
    
    %3.bipolar_combination�p�̓d�ɂ̑g�ݍ��킹
    %Ebi�̏c�̒����͂�����ł��ǉ�����OK
%    PPC.Ebi=PPC.BipPreset_15;

    %4.laplacian_combination�p�̓d�ɂ̑g�ݍ��킹
    %�ܗ�̃Z���z�u������Ȃ����ƁI
%    PPC.Ela=PPC.LapPreset_15;
    
    %5.mec�����6.mcc�p�̃p�����[�^
    PPC.MECNh=2;   %f�ɑ΂����Ԗڂ̍����g�܂Œ��ׂ邩�̐�
    %PPC.MECth=10;  %�G�������̉�%�c���悤�Ƀt�B���^�[�̐���ݒ肷�邩
    %PPC.DetectionMode=1; %Ns�𐧌����邩
    
    
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

    %�O�����̐ݒ�

    %�����ʂ̌v�Z
    %1.DFT�ƃ��[���E�E�H�[�J�[�@��p����SN��
    %3.�������֕���(Canonical Correlation Analysis:CCA)�ɂ�鑊�֌W��
    %5.DFT�ɂ��X�y�N�g������
    DPC.WindowTime=2;
    DPC.IntervalTime=0.5;
    DPC.ExtractFeatureModeIs=5;
    DPC.SNR_NumberOfHarmonics=2;
    
    
    %�p�^�[���F���̐ݒ�
    
DPC=DPC.operate;

%�I�v�V�����@�\
[CorrectSSVEPCount,CorrectSSVEPRate]=DPC.checkcorrectssvep;

    
%% [Section5.Viewing Result]
%

VRC=ViewingResultClass(TDC, PPC, EDC, DPC);

    %�g�`�̐}��
    VRC.ActiveViewWave=[1, 1, 1];%[�g���[�j���O�f�[�^, �e�X�g�f�[�^, �O������]
    
    %�����ʂ̐}��
    
    %�p�^�[���F�����ʂ̐}��
    VRC.FlickeModeVisibleIs=1;
    
    %���v�ʂ̌v�Z
    %1.�_�Ŏ��Ɣ�_�Ŏ��̃q�X�g�O�����̕\��
    VRC.StasticalCalclateMode=1;
    VRC.ComparedFrequency=6.66;
    
VRC=VRC.operate;



