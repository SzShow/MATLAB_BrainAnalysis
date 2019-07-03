%% [�T�v]
%���̃X�N���v�g�ł�k-�����������؂Ƃ����@�B�w�K�ł悭�g����
%���ފ퐫�\�]���̃A���S���Y����p���āC�݌v����BCI�̐��\��]�����܂��D
%k-�����������؂ɂ��Ă�(https://mathwords.net/kousakakunin)��
%��r�I������₷���ł��D

%% [�p�b�P�[�W�̃C���|�[�g]
%�ŏ��Ɏ��s���ʂ����₷������ׂ̏�����
%�p�b�P�[�W�i���O��Ԃ̂悤�Ȃ��́j�̃C���|�[�g���s���܂�
clear all	%#ok<CLALL> 
            %MATLAB��IDE�ɗ��܂������[�N�X�y�[�X�̕ϐ���S�ď���
close all	%���ݕ\������Ă���O���t��S�ď���
			%�i���̃X�N���v�g�����N������ƃO���t��10�E�B���h�E����邽�߁j

import BCI_Module.*	%BCI�ɗp����X�N���v�g�������Ă���p�b�P�[�W
import SSVEP_NN.*	%�j���[�����l�b�g���[�N�֘A�̃X�N���v�g��
                    %�����Ă���p�b�P�[�W�i����͎g�p�����j

%% [�������ؗp�f�[�^�̃Z�b�e�B���O]
%�������؂ɗp����f�[�^���Z���z��(�z�������z��)Data��
%����Ă����܂��D�i���Ԃɂ���ĉ�͌��ʂ͕ω��Ȃ��j

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

%% [BCI�\���̐ݒ�]
%���͂��ꂽ�]�g���ǂ̂悤�ɏ�������̂����L�q���Ă����܂��D
%�P�D���͂̐ݒ�
%	BCI�ł́h���b�ԁh�̔]�g�ɑ΂��āu�ǂ̂悤�Ȑ������܂܂�Ă����̂��v��
%	���o�������ꍇ�������̂ŁC�����Ԃ̔g�`�f�[�^�ɂ��Ă��ׂ���
%	��ԁi�ȍ~�C�G�|�b�N�j�ɕ������āC���̂��ꂼ��ɂ���
%	�K�v�ȏ��𒊏o���C����ɉ��������f�������Ă����܂�
%
%�Q�D�O�����E�����ʒ��o�̐ݒ�
%	����͓��v��͂̕���ŗǂ��p�����鐳�����֕��́iCCA�j�ƌĂ΂���@
%	�ɂ���Čv�������]�g����s�v�ȏ�����菜������ŁC
%	�����ʂ𒊏o���Ă����܂��D
%
%�R�D���ފ�̐ݒ�
%	����͐��`���ʕ���(LDA)�Ƃ�����r�I�ȒP�ȕ��ފ�ɂ����
%	SSVEP�ƌĂ΂��]�g�������������Ă��邩�ǂ����𔻕ʂ��܂����D
%

%�G�|�b�N�̐ݒ�i�P�D�j
timeWindow=2;	%�e�G�|�b�N�̎��Ԓ�[s]
overlap=0.5;		%�O�̃G�|�b�N�Ǝ��̃G�|�b�N�̏d�Ȃ藦
					%([0 1]�͈̔͂Őݒ�)

%CCA�̏o�͂̐ݒ�i�Q�D�j
 CCAOutput=...
    [ 
      ECCAOutput.CorrelationEfficient	%���֌W��
      ECCAOutput.SpatialFilter			%��ԃt�B���^�̃p�����[�^
    ];


InputModule=EpochDivider(timeWindow, overlap);	%�i�P�D�j
ProcessingModules=...	%�i�Q�D�j
    {
        CCAModule([7 15], 2, 2, CCAOutput, EWindowList.Hann)
     };
OutputMod=LDAMod(true, ECCAOutput.CorrelationEfficient); 	%�i�R�D�j

%�N���XBCI�̃R���X�g���N�^�ɂ���āC�����ŏ����ݒ肪�n�܂�܂�
bci=BCI(InputModule,...
    ProcessingModules,...
    OutputMod);

%�c���Ă����ƌ��ʂ����Â炭�Ȃ�̂Ń��[�N�X�y�[�X�������
clear InputModule ProcessingModules OutputMod


%% [�g���[�j���O�ƃe�X�g�̎��s]
%k-�������؂ɂ�镽�ϐ��������\����Result���̕ϐ�score�ɕԂ��܂��D
%�܂��Ctic-toc�֐��ɂ���Čv�������v�Z���Ԃ�CalclateTime�C
%�������̐�����Ғl��MeanScore�C���蕪�U�l��Variance�ɕԂ��܂��D

tic
Result.score=bci.crossevaluate(Data);%�O�Z�N�V�����Ő�������BCI�C���X�^���X��
									 %�f�[�^�̃Z���z�����͂��܂�
Result.CalclateTime=toc;
Result.MeanScore=mean(Result.score);
Result.Variance=var(Result.score);
