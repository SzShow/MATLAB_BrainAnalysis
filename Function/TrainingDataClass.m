classdef TrainingDataClass
    %UNTITLED ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    
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
        Filename        %�ǂݍ��݃t�@�C��
        SamplingFrequency double              %�T���v�����O���g���FFs
        MeasurementTime              %�v�����ԁFTm
        ElectrodeList              %�d�Ɉʒu�Ɣԍ��̑Ή��\�FLe
        FlickerList              %�_�Ŏ��g���Ǝ��Ԃ̑Ή��\�FLf
        DataSource
        FlickerOrder
        
        %I:�擾����
        OffsetTime              %�g���K�[����̃I�t�Z�b�g�FTo
        
        %O:�v���f�[�^
        TrainingData               %�f�[�^�s��FDt
        NumberOfElectrode              %�d�ɐ��FNe
        NumberOfSample      %�T���v���_�̑����FNs
        NumberOfFrequency   %�_�Ŏ��g���̐�:Nf
        FlickerFrequency
        FlickerIndex
        
        %O:�t�����
        Date            %������
        Title           %������
        Subject         %�팱�Ҕԍ�
        TrialNumber     %���s�ԍ�
        
        
    end
    
    properties(Dependent)

    end
    
    
    methods       
    %% [�v���p�e�B�ւ̃A�N�Z�X]
        %���̃N���X�̃Q�b�g���\�b�h

    %% [Internal: �g�`�̃��[�h�Ǝ��������̃Z�b�e�B���O]
    %   
    %���̊֐���BrainAmp����擾�����]�g�̓ǂݎ��ƁC�p�����[�^��
    %�Z�b�e�B���O���s���܂��D
        
        function [obj, eeg]=brainampsetting(obj)
            
            %�p�����[�^���̂̐ݒ�
            Tm=obj.MeasurementTime;
            Fs=obj.SamplingFrequency;
            
            %   [�g�`�̓ǂݍ���]
            %�\�߃v���p�e�BFilename�ɋL�ڂ��ꂽ���O�����t�@�C����
            %�ǂݍ��݂܂�
            load(obj.Filename); %#ok<EMLOAD>
            
            %   [�p�����[�^�̌v�Z]
            obj.NumberOfElectrode=length(eeg(:,1))-1; %#ok<EMNODEF>
            obj.NumberOfSample=Tm*Fs;
            
            %�t�����̎擾
            C1=strsplit([obj.Filename],'_');    %���t�C�������C�팱�җp
            C2=strsplit(C1{1,4},'.');           %���s�񐔗p
            [obj.Date]=C1{1,1};
            [obj.Title]=C1{1,2};
            [obj.Subject]=C1{1,3};
            [obj.TrialNumber]=C2{1,1};
            
        end
        
        %wfdb�f�[�^�̎擾
        function [obj, eeg]=wfdbsetting(obj)
            %WDFB�f�[�^�̓ǂݍ���
            eeg=rdsamp(obj.Filename);
            info=wfdbdesc(obj.Filename);
            
            %�p�����[�^���
            Tm=obj.MeasurementTime;
            Of=obj.FlickerOrder;
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
            w(win(1))=1;
            eeg=[eeg ;w];
        end
        
        
    %% [Internal: �f�[�^�̐؂��蕪������]
 
        %���̊֐��ł͎擾�����f�[�^�ɂ��āC���莞�Ԃ̒������ɐ؂�������C
        %���̌�ɍs���t�B���^�̃L�����u���[�V���������Ղ��悤�Ɋe���g����
        %�v���]�g�𕪗ނ��܂�
        function [obj]=signalacquire(obj, eeg)
            
            %   [�p�����[�^���̂̐ݒ�]
            Ne=obj.NumberOfElectrode;
            Ns=obj.NumberOfSample;
            Fs=obj.SamplingFrequency;
            To=obj.OffsetTime;
            Tm=obj.MeasurementTime;
            Lf=obj.FlickerList;
            If=obj.FlickerIndex;
            
            
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
            
            
            %   [�_�Ŏ��g���̎�ސ��̌v�Z�Ɠ_�Ŏ��g���ɂ��g�`����]
            %�܂��ŏ��ɕ��ނ����g�`�����邽�߂̍\����T���������܂��D
            %���̂��߂ɂ͓K�؂ȃt�B�[���h���쐬���邽�߂ɁC
            %   �P�D�v�����ɓ_�ł��������g���̎�ސ�
            %   �Q�D�_�ł��������g�����ꂼ��̒���
            %��c�����Ȃ���΂Ȃ�܂���D
            %�X�ɍ\���̂̒������ϒ��Ƃ��邽�߂ɁC����͕K�v�ȃt�B�[���h����
            %�傫�������e�[�u�����쐬���Ă��炻����\���̂ɕϊ����C
            %�e�t�B�[���h���ɂ���s��̑傫����_�ł��������g�����ꂼ��̒���
            %�ɑΉ�������悤�ɂ��܂����D
            
            %1.�_�Ŏ��g���̕��z���q�X�g�O�������쐬
            edges=0:20;
            h=histogram(obj.FlickerList, edges);
            
            %2.�g�p���ꂽ�_�Ŏ��g���̃s�b�N�A�b�v
            Ff=[];%�_�Ŏ��g���̃��X�g������z��
            FlickerEdges=[];%�_�Ŏ��g���̍��v�_�Ŏ��Ԃ�����z��
            for i=1:length(edges)-1
                if h.BinCounts(i)>0
                    Ff=[Ff i-1];%���g���̒l
                    FlickerEdges=[FlickerEdges h.BinCounts(i)];%�_�ł̒���
                end
            end
            Nf=length(Ff);
            
            %3.�g���[�j���O�f�[�^�̍\���̍쐬
            Dt=obj.trainingdatastruct(Nf, ...
                Ff, FlickerEdges);%�\���̂̒�`
            
            %4.�g���[�j���O�f�[�^�̕��ފJ�n
            
            for f=1:Nf
                B=[];
                s=string({'f', Ff(f)});%���̃e�[�u�����ݒ�
                s=join(s,"");%string�����z��̘A��
                for t=1:Tm
                    if Lf(t)==Ff(f)
                        A=Data(((t-1)*Fs)+1:t*Fs, :);
                        B=[B; A];
                    end
                end
                Dt.(char(s))= B;
            end
            
            obj.TrainingData=Dt;
            obj.NumberOfFrequency=length(Ff);
            obj.FlickerFrequency=Ff;
                 
        end
        
        function [obj]=wfdbacquire(obj, eeg)
            
            %   [�p�����[�^���̂̐ݒ�]
            Ne=obj.NumberOfElectrode;
            Ns=obj.NumberOfSample;
            Fs=obj.SamplingFrequency;
            To=obj.OffsetTime;
            Tm=obj.MeasurementTime;
            If=obj.FlickerIndex;
            Of=obj.FlickerOrder;
            
            
            
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
            
            
            %   [�_�Ŏ��g���̎�ސ��̌v�Z�Ɠ_�Ŏ��g���ɂ��g�`����]
            %�܂��ŏ��ɕ��ނ����g�`�����邽�߂̍\����T���������܂��D
            %���̂��߂ɂ͓K�؂ȃt�B�[���h���쐬���邽�߂ɁC
            %   �P�D�v�����ɓ_�ł��������g���̎�ސ�
            %   �Q�D�_�ł��������g�����ꂼ��̒���
            %��c�����Ȃ���΂Ȃ�܂���D
            %�X�ɍ\���̂̒������ϒ��Ƃ��邽�߂ɁC����͕K�v�ȃt�B�[���h����
            %�傫�������e�[�u�����쐬���Ă��炻����\���̂ɕϊ����C
            %�e�t�B�[���h���ɂ���s��̑傫����_�ł��������g�����ꂼ��̒���
            %�ɑΉ�������悤�ɂ��܂����D
            
            %�_�Ŏ��g���f�[�^�̎擾
            win=rdann(obj.Filename, 'win');
            win=cast(win, 'uint32')-StartPoint;
            win=idivide(win, Fs, 'round');
            Lf=zeros(Tm,1);
            Fe=zeros(length(If)+1, 1);
            If=[0 If];
            ReplaceNum=0;
            n=1;
            for t=1:Tm
                if t==win(n)
                    switch mod(n, 2)
                        case 1
                            ReplaceNum=Of(ceil(n/2));
                            n=n+1;
                        case 0
                            ReplaceNum=0;
                            n=n+1;
                    end
                end
                Lf(t)=ReplaceNum;
                for i=1:length(If)
                    if ReplaceNum==0
                        Fe(1)=Fe(1)+1;
                    elseif ReplaceNum==If(i)
                        Fe(i)=Fe(i)+1;
                    end
                end
            end
            
            
            %3.�g���[�j���O�f�[�^�̍\���̍쐬
            Nf=length(If);
            Dt=obj.trainingdatastruct(Nf, ...
                If, Fe);%�\���̂̒�`
            
            %4.�g���[�j���O�f�[�^�̕��ފJ�n
            
            for f=1:Nf
                B=[];
                s=string({'f', round(If(f))});%���̃e�[�u�����ݒ�
                s=join(s,"");%string�����z��̘A��
                for t=1:Tm
                    if Lf(t)==If(f)
                        A=Data(((t-1)*Fs)+1:t*Fs, :);
                        B=[B; A];
                    end
                end
                Dt.(char(s))= B;
            end
            
            obj.TrainingData=Dt;
            obj.NumberOfFrequency=length(If);
            obj.FlickerFrequency=If;
                 
        end

        
        %   [�g���[�j���O�f�[�^�\���̂̒�`]
        function [T]=trainingdatastruct(obj, NumberOfFrequency, ...
                    FlickerFrequency, FlickerEdges)   %#codegen
                
            %   [�p�����[�^���̂̐ݒ�]
            Ne=obj.NumberOfElectrode;
            Ns=obj.NumberOfSample;
            Fs=obj.SamplingFrequency;
            To=obj.OffsetTime;
            
            for n=1:NumberOfFrequency
                ZeroMatrix=zeros(Fs*FlickerEdges(n), Ne);
                s=string({'f', round(FlickerFrequency(n))});%���̃e�[�u�����ݒ�
                s=join(s,"");%string�����z��̘A��
                T.(char(s))= ZeroMatrix;
            end
        end

    %% [Public: �g���[�j���O�f�[�^�̎擾���s]
        %�������s
        function [obj]=operate(obj)
            %���������̎擾
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
