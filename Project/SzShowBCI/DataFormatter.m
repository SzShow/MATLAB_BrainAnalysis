import BCI_Module.BrainAmpData


%�v�������f�[�^��BCI�ɓ��͂���O��
%���̃X�N���v�g���g���ăf�[�^���t�H�[�}�b�e�B���O���܂�

%�g�p�����v���A���v�ɂ���Ĕg�`�f�[�^�̃t�H�[�}�b�g�̂�����
%����Ă���̂ŁC���ۃN���XExperimentData��
%�ÓI���\�b�hformatdata���g���đΉ�����N���X�����o���܂��D
%�i���ۂɔg�`�̃t�H�[�}�b�g���s���̂͒��ۃ��\�b�hExpandData�j
ExpData=Experimentdata.formatData(EBioAmp.BrainAmp);


%�e�����p�����[�^���Z�b�g���Ă����܂�
ExpData.File='20181120_SSVEPMCCCCA_B30_0010.mat';	%�v���f�[�^�̖��O�ł�
ExpData.Electrodes = ...			%�e�d�ɂ�����10-20�@�̂ǂ̈ʒu����擾����
	[												%�g�`�Ȃ̂������ԂɋL�q���Ă����܂�
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
ExpData.SamplingFreq=250;				%�v���f�[�^�̃T���v�����O���g��[Hz]�ł�
ExpData.BandPass=[0.5 100];				%�v���f�[�^�̎��g���ш�ł�
ExpData.Notch=EHAMNoise.None;	%HAM�t�B���^
ExpData.MeasureTime=265;				%�����̌v�����Ԃł�
ExpData.StartOffset=0;							%�X�^�[�g�̊J�n���X�^�[�g���牽�b�x�点�邩
ExpData.TriggerTable='TrrigerTable2.mat';	%�_�ŊJ�n�̃g���K������Ă�������
																		%������w�肷��g���K�ł�

%�Ō�Ƀt�@�C���������߂Ȃ���f�[�^��ۑ����Ă����܂�
str1=split(string(ExpData.File), ".");
str=join([str1(1),"BCITest"], "_");
save(str, 'ExpData')
