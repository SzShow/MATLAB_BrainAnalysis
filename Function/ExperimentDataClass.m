classdef ExperimentDataClass
    %ExperimentDataClass
    %   �����f�[�^�A���������Ȃǂ̎����Ɋւ���X�e�[�^�X��f�[�^���܂Ƃ߂�
    %   �ۂɗp����N���X�ł��B
    %   �v�������Ȃǂ̏C���͂��̃N���X���쐬���ꂽ�C���X�^���X�̃p�����[
    %   �^�𒲐����邱�Ƃɂ���Ăł��܂��B
    %   ���̃N���X�͌���ABrainAmp���擾�����t�@�C�����������܂���B
    %   �܂��A�t�@�C�����͕K��'���t�Q�������Q�팱�ҁQ���s��.mat'��
    %   ����悤�ɂ��Ă��������B
    
    properties(Constant)
        %�d�ɂ̃v���Z�b�g
        Preset_15={ 'P5', 'P3', 'P1', 'Pz', 'P2', ...
                    'P4', 'P6', 'PO7', 'PO3', 'POz', ...
                    'PO4', 'PO8', 'O1', 'Oz', 'O2'};
        Preset_5={  
            }
                
    end
    
    properties
        %I:�v������
        DataSource
        Filename        %�ǂݍ��݃t�@�C��
        SamplingFrequency double              %�T���v�����O���g��
        MeasurementTime              %�v������
        ElectrodeList              %�d�Ɉʒu�Ɣԍ��̑Ή��\
        FlickerList              %�_�Ŏ��g�� 
        FlickerIndex
        FlickerOrder
        
        %I:�擾����
        OffsetTime              %�g���K�[����̃I�t�Z�b�g
        
        %O:�v���f�[�^
        TestData               %�f�[�^�s�� 
        NumberOfElectrode              %�d�ɐ�
        NumberOfSample
        
        %O:�t�����
        Date            %������
        Title           %������
        Subject         %�팱�Ҕԍ�
        TrialNumber     %���s�ԍ�
        
        
    end
    properties(Dependent)

    end
    
    methods
        %% [�R���X�g���N�^�[]
        %�C���X�^���X�����Ɠ����Ɏ����p�����[�^����
%         function [obj]=ExperimentDataClass(EDC,PPC)
%            obj.ExperimentProperties=get(TDC, 'default');
%         global edc;
%         global ppc;
%         edc=EDC;
%         ppc=PPC;
%             
%         end
        %%
        %�g�`�̃��[�h�Ǝ��������̃Z�b�e�B���O
        function [obj, eeg]=brainampsetting(obj)
            
            %�p�����[�^���̂̐ݒ�
            Tm=obj.MeasurementTime;
            Fs=obj.SamplingFrequency;
            
            %   [�g�`�̓ǂݍ���]
            %�\�߃v���p�e�BFilename�ɋL�ڂ��ꂽ���O�����t�@�C����
            %�ǂݍ��݂܂�
            load(obj.Filename);
            
            %   [�p�����[�^�̌v�Z]
            obj.NumberOfElectrode=length(eeg(:,1))-1; %#ok<NODEF>
            obj.NumberOfSample=Tm*Fs;
            
            %�t�����̎擾
            C1=strsplit([obj.Filename],'_');    %���t�C�������C�팱�җp
            C2=strsplit(C1{1,4},'.');           %���s�񐔗p
            [obj.Date]=C1{1,1};
            [obj.Title]=C1{1,2};
            [obj.Subject]=C1{1,3};
            [obj.TrialNumber]=C2{1,1};
        end
        
        function [obj, eeg]=wfdbsetting(obj)
            %WDFB�f�[�^�̓ǂݍ���
            eeg=rdsamp(obj.Filename);
            info=wfdbdesc(obj.Filename);
            
            %�p�����[�^���
            Tm=obj.MeasurementTime;
%             Of=obj.FlickerOrder;
            obj.SamplingFrequency=info.SamplingFrequency;
            Fs=cast(obj.SamplingFrequency, 'double');
            obj.NumberOfSample=Tm*Fs;
            
            %�d�ɕ���
            chnum=length(eeg(1, :));
            B=[];
            s={};
            for i=1:chnum
                if ~strcmp(info(1, i).Description, 'EEG')  
                    A=eeg(:, i);
                    B=[B A]; %#ok<AGROW>
                    s=[s, {info(1, i).Description}]; %#ok<AGROW>
                end
            end
            clear eeg
            eeg=B';
            
            %�p�����[�^���
            obj.ElectrodeList=char(s);
            obj.NumberOfElectrode=length(eeg(:, 1));
            
            %�g���K�[�x�N�g���̍쐬
            win=rdann(obj.Filename, 'win');
            w=zeros(1, length(eeg));
            w(win(17))=1;
            eeg=[eeg ;w];
        end
        
        %%
        %�f�[�^�̐؂��蕪������
        function [obj]=signalacquire(obj, eeg)
            %   [�p�����[�^���̂̐ݒ�]
            Ne=obj.NumberOfElectrode;
            Ns=obj.NumberOfSample;
            Fs=obj.SamplingFrequency;
            To=obj.OffsetTime;
            Tm=obj.MeasurementTime;
            
            
            %   [�ŏ��̃g���K�[���o�����̎擾]
            %�؂���̎��̊���߂邽�߂ɁC�ŏ��Ƀg���K�[�����o���ꂽ
            %�������T���v���_i�Ƃ��Đݒ肵�܂��D
            
            for i=1:length(eeg)
                if(eeg(Ne+1,i)==1)
                    TrigerPoint=i;
                    break;
                end
            end
            
            
            %   [�v�����Ԃɍ��킹���v���f�[�^�؂���]
            %�ŏ��ɒ�߂��T���v���_i����ɂ��āC�I�t�Z�b�g����To�i�v���J�n��
            %�ŏ��̃g���K�[���牽�b����Ă��邩�j�⑪�莞��Ts���l�����Ȃ���C
            %�v�����ԊO�̃f�[�^���������܂��D
            %
            
            %1.�؂������f�[�^�̊�ƂȂ�s���p��
            Data=zeros(Ns,Ne);  
            
            %2.�I�t�Z�b�g���Ԃ�b����T���v���_�ɕύX
            OffsetLength=To*Fs;           
            
            %3.�g���K�[�J�n����I�t�Z�b�g�������Đ؂���J�n�̃v���b�g�_��ݒ�
            StartPoint=TrigerPoint-OffsetLength;                   
            
            %4.�f�[�^�̐؂���͈͂�Rc�ɐݒ�
            %CutRange=[StartPoint (StartPoint+Ne)-1];      
            
            %5.�d�ɂ��Ƃ̐؂�����s
            for i=1:Ne                     
                Data(:,i)=eeg(i,StartPoint:(StartPoint+Tm*Fs)-1)';     
            end 
            
            obj.TestData=Data;
        end
        
        function [obj]=wfdbacquire(obj, eeg)
            
            %   [�p�����[�^���̂̐ݒ�]
            Ne=obj.NumberOfElectrode;
            Ns=obj.NumberOfSample;
            Fs=obj.SamplingFrequency;
            To=obj.OffsetTime;
            Tm=obj.MeasurementTime;
%             If=obj.FlickerIndex;
%             Of=obj.FlickerOrder;
            
            
            
            %   [�ŏ��̃g���K�[���o�����̎擾]
            %�؂���̎��̊���߂邽�߂ɁC�ŏ��Ƀg���K�[�����o���ꂽ
            %�������T���v���_i�Ƃ��Đݒ肵�܂��D
            
            for i=1:length(eeg)
                if(eeg(Ne+1,i)==1)
                    TrigerPoint=i;
                    break;
                end
            end
            
            
            %   [�v�����Ԃɍ��킹���v���f�[�^�؂���]
            %�ŏ��ɒ�߂��T���v���_i����ɂ��āC�I�t�Z�b�g����To�i�v���J�n��
            %�ŏ��̃g���K�[���牽�b����Ă��邩�j�⑪�莞��Ts���l�����Ȃ���C
            %�v�����ԊO�̃f�[�^���������܂��D
            %
            
            %1.�؂������f�[�^�̊�ƂȂ�s���p��
            Data=zeros(Ns,Ne);  
            
            %2.�I�t�Z�b�g���Ԃ�b����T���v���_�ɕύX
            OffsetLength=To*cast(Fs, 'double');           
            
            %3.�g���K�[�J�n����I�t�Z�b�g�������Đ؂���J�n�̃v���b�g�_��ݒ�
            StartPoint=TrigerPoint-OffsetLength;                   
            
            %4.�f�[�^�̐؂���͈͂�Rc�ɐݒ�
            %CutRange=[StartPoint (StartPoint+Ne)-1];      
            
            %5.�d�ɂ��Ƃ̐؂�����s
            for i=1:Ne                     
                Data(:,i)=eeg(i,StartPoint:(StartPoint+Tm*Fs)-1)';     
            end
            
            obj.TestData=Data;
                 
        end
        
        %%
        %�������s
        function [obj]=operate(obj)
            switch obj.DataSource
                case 'BrainAmp'
                    [obj, eeg]=obj.brainampsetting;
                    obj=obj.signalacquire(eeg);
                    
                case 'WFDB'
                    [obj, eeg]=obj.wfdbsetting;
                    obj=obj.wfdbacquire(eeg);
            end
            

        end
    end
    
end

