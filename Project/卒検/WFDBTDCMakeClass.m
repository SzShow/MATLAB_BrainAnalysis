classdef WFDBTDCMakeClass < TDCMakeClass
    %UNTITLED ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties
        WFDBdescription
        WFDBFlashWindow uint32
    end
    
    methods (Access=private)  
        %% wfdb�f�[�^�̎擾
        function [obj]=wfdbsettingparam(obj)
            %�ϐ��錾
            Tm=obj.MeasurementTime;
            
            %WDFB�f�[�^�̓ǂݍ���
            DESC=wfdbdesc(obj.Filename);
            Fs=DESC.SamplingFrequency;
                        
            %�A�E�g�v�b�g
            obj.RawData=rdsamp(obj.Filename);
            obj.SamplingFrequency=Fs;
            obj.WFDBdescription=DESC;
            obj.NumberOfSample=Tm*Fs;
            obj.WFDBFlashWindow=rdann(obj.Filename, 'win');
            %���
        end
        
        %% �d�ɂ̑���
        function [obj]=wfdboperateelectrode(obj)
            %[�p�����[�^�ݒ�]
            Dr=obj.RawData;
            DESC=obj.WFDBdescription;
            
            %[�d�ɕ���]
            chnum=length(Dr(1, :));
            B=[];
            s={};
            for i=1:chnum
                %�^�O����EEG�ȊO�̃`�����l�������
                if ~strcmp(DESC(1, i).Description, 'EEG')  
                    A=Dr(:, i);
                    B=[B A]; %#ok<AGROW>
                    %��������`�����l���̃^�O����s�ɕۊ�
                    s=[s, {DESC(1, i).Description}]; %#ok<AGROW>
                end
            end
            Dco=B';
            
            %[�g���K�[�x�N�g���̍쐬]
            win=obj.WFDBFlashWindow; %WFDB������_�ŏ������
            w=zeros(1, length(Dco));
            w(win(1))=1;
            Dco=[Dco ;w];
            
            %�p�����[�^���
            obj.ElectrodeList=char(s);
            obj.NumberOfElectrode=length(Dco(:, 1))-1;
            obj.CombinedData=Dco;
            obj.WFDBFlashWindow=win;
        end
           
        %% �f�[�^���̒���
        function [obj]=wfdbdatacut(obj)
            
            %   [�p�����[�^���̂̐ݒ�]
            Ne=obj.NumberOfElectrode;
            Ns=obj.NumberOfSample;
            Fs=obj.SamplingFrequency;
            To=obj.OffsetTime;
            Dco=obj.CombinedData;
            win=obj.WFDBFlashWindow;
            
            %   [�ŏ��̃g���K�[���o�����̎擾]
            for i=1:length(Dco)
                if(Dco(Ne+1,i)==1)
                    TrigerPoint=i;
                    break;
                end
            end
            
            %   [�؂���J�n�n�_�̌v�Z]  
            Offset=To*Fs;
            StartPoint=TrigerPoint-Offset;
            
            %   [�؂���̊J�n]
            Dcu=zeros(Ns,Ne);
            for i=1:Ne
                Dcu(:,i)=Dco(i,StartPoint:(StartPoint+Ns)-1)';
            end
            
            %�_�Ŏ��g���f�[�^�̕ό`
            win=win-StartPoint; %�J�n�_��0�_�ڂɒu��������
            win=idivide(win, Fs, 'round');  %�T���v���_���b���Z�i�l�̌ܓ�)
            
            obj.CutData=Dcu;
            obj.WFDBFlashWindow=win;
        end
        
        %% �_�Ŏ��g���̎��n��f�[�^�̐���
        function [obj]=wfdbtimeseriesgenerate(obj)
            
            %�p�����[�^���
            Tm=obj.MeasurementTime;
            If=obj.FlickerIndex;
            Of=obj.FlickerOrder;
            win=obj.WFDBFlashWindow;
            

            
            %�_�Ŏ��g���̎��n��f�[�^�𐶐��i�ϐ������j
            Lf=zeros(Tm,1); %FlickerList
            If=[0 If];
            Df=zeros(length(If), 1);    %�e���g���̓_�Œ���[�b]
            ReplaceNum=0;   %�u�������鐔���̕ۊǏꏊ
            n=1;    %�_�ł̐i�s��
            
            %�_�Ŏ��g���̎��n��f�[�^�𐶐��i�������s�j
            for t=1:Tm
                if t==win(n)
                    switch mod(n, 2)
                        case 1  %��͎��̎��g����
                            ReplaceNum=Of(ceil(n/2));
                            n=n+1;
                        case 0  %�����͖��_�ŏ�Ԃɖ߂�
                            ReplaceNum=0;
                            n=n+1;
                    end
                end
                %�_�Ŏ��g�����n��ւ̑��
                Lf(t)=ReplaceNum;
                %�_�ł̒����̌v�Z
                for i=1:length(If)
                    if ReplaceNum==0
                        Df(1)=Df(1)+1;
                    elseif ReplaceNum==If(i)
                        Df(i)=Df(i)+1;
                    end
                end
            end
            
            %�o��
            obj.FlickerList=Lf;
            obj.FlickerDuration=Df;
        end
        
        %% �g���[�j���O�f�[�^�̕���
        function obj=wfdbclassifydata(obj)
            %�ϐ��ݒ�
            Lf=obj.FlickerList;
            Fs=obj.SamplingFrequency;
            If=obj.FlickerIndex;
            Tm=obj.MeasurementTime;
            Dcu=obj.CutData;
            
            %3.�g���[�j���O�f�[�^�̍\���̍쐬            
%             for n=1:length(If)
%                 ZeroMatrix=zeros(Fs*Df(n), Ne);
%                 s=string({'f', round(If(n))});%���̃e�[�u�����ݒ�
%                 s=join(s,"");%string�����z��̘A��
%                 T.(char(s))= ZeroMatrix;
%             end
            
            %4.�g���[�j���O�f�[�^�̕��ފJ�n
            
            for f=1:length(If)
                B=[];
                s=string({'f', round(If(f))});%���̃e�[�u�����ݒ�
                s=join(s,"");%string�����z��̘A��
                for t=1:Tm
                    if Lf(t)==If(f)
                        A=Dcu(((t-1)*Fs)+1:t*Fs, :);
                        B=[B; A];
                    end
                end
                Dt.(char(s))= B;
            end
            
            obj.TrainingData=Dt;
            obj.NumberOfFrequency=length(If);
            obj.FlickerFrequency=If;
        end
        
    end
    
    methods (Access=public)
        function obj=operate(obj)
            obj=obj.wfdbsettingparam;
            obj=obj.wfdboperateelectrode;
            obj=obj.wfdbdatacut;
            obj=obj.wfdbtimeseriesgenerate;
            obj=obj.wfdbclassifydata;
        end
        
    end
    
end

