classdef TDCMakeClass < TrainingDataClass
    %UNTITLED2 ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties
        tdcObject TrainingDataClass
        RawData
        CombinedData
        CutData
        FlickerDuration
    end
    
    methods (Access=private)
    %% [BrainAmp�p]
    %   
    %���̊֐���BrainAmp����擾�����]�g�̓ǂݎ��ƁC�p�����[�^��
    %�Z�b�e�B���O���s���܂��D
        
%         function [obj, eeg]=brainampsetting(obj)
%             
%             %�p�����[�^���̂̐ݒ�
%             Tm=obj.MeasurementTime;
%             Fs=obj.SamplingFrequency;
%             
%             %   [�g�`�̓ǂݍ���]
%             %�\�߃v���p�e�BFilename�ɋL�ڂ��ꂽ���O�����t�@�C����
%             %�ǂݍ��݂܂�
%             load(obj.Filename); %#ok<EMLOAD>
%             
%             %   [�p�����[�^�̌v�Z]
%             obj.NumberOfElectrode=length(eeg(:,1))-1; %#ok<EMNODEF>
%             obj.NumberOfSample=Tm*Fs;
%             
%             %�t�����̎擾
%             C1=strsplit([obj.Filename],'_');    %���t�C�������C�팱�җp
%             C2=strsplit(C1{1,4},'.');           %���s�񐔗p
%             [obj.Date]=C1{1,1};
%             [obj.Title]=C1{1,2};
%             [obj.Subject]=C1{1,3};
%             [obj.TrialNumber]=C2{1,1};
%             
%         end
%         
%         function [obj]=setsignalstart(obj, eeg)
%             
%             %   [�p�����[�^���̂̐ݒ�]
%             Ne=obj.NumberOfElectrode;
%             Ns=obj.NumberOfSample;
%             Fs=obj.SamplingFrequency;
%             To=obj.OffsetTime;
%             Tm=obj.MeasurementTime;
%             Lf=obj.FlickerList;
%             If=obj.FlickerIndex;
%             
%             
%             %   [�ŏ��̃g���K�[���o�����̎擾]
%             %�؂���̎��̊���߂邽�߂ɁC�ŏ��Ƀg���K�[�����o���ꂽ
%             %�������T���v���_i�Ƃ��Đݒ肵�܂��D
%             
%             for i=1:length(eeg)
%                 if(eeg(Ne+1,i)==1)
%                     TrigerPoint=i;
%                     break;
%                 end
%             end
%             
%             
% 
%             Data=zeros(Ns,Ne);  
%             OffsetLength=To*Fs;           
%             StartPoint=TrigerPoint-OffsetLength;                   
%             for i=1:Ne                     
%                 Data(:,i)=eeg(i,StartPoint:(StartPoint+Tm*Fs)-1)';     
%             end
%             
%             
%             %   [�_�Ŏ��g���̎�ސ��̌v�Z�Ɠ_�Ŏ��g���ɂ��g�`����]
%             %�܂��ŏ��ɕ��ނ����g�`�����邽�߂̍\����T���������܂��D
%             %���̂��߂ɂ͓K�؂ȃt�B�[���h���쐬���邽�߂ɁC
%             %   �P�D�v�����ɓ_�ł��������g���̎�ސ�
%             %   �Q�D�_�ł��������g�����ꂼ��̒���
%             %��c�����Ȃ���΂Ȃ�܂���D
%             %�X�ɍ\���̂̒������ϒ��Ƃ��邽�߂ɁC����͕K�v�ȃt�B�[���h����
%             %�傫�������e�[�u�����쐬���Ă��炻����\���̂ɕϊ����C
%             %�e�t�B�[���h���ɂ���s��̑傫����_�ł��������g�����ꂼ��̒���
%             %�ɑΉ�������悤�ɂ��܂����D
%             
%             %1.�_�Ŏ��g���̕��z���q�X�g�O�������쐬
%             edges=0:20;
%             h=histogram(obj.FlickerList, edges);
%             
%             %2.�g�p���ꂽ�_�Ŏ��g���̃s�b�N�A�b�v
%             Ff=[];%�_�Ŏ��g���̃��X�g������z��
%             FlickerEdges=[];%�_�Ŏ��g���̍��v�_�Ŏ��Ԃ�����z��
%             for i=1:length(edges)-1
%                 if h.BinCounts(i)>0
%                     Ff=[Ff i-1];%���g���̒l
%                     FlickerEdges=[FlickerEdges h.BinCounts(i)];%�_�ł̒���
%                 end
%             end
%             Nf=length(Ff);
%             
%             %3.�g���[�j���O�f�[�^�̍\���̍쐬
%             Dt=obj.trainingdatastruct(Nf, ...
%                 Ff, FlickerEdges);%�\���̂̒�`
%             
%             %4.�g���[�j���O�f�[�^�̕��ފJ�n
%             
%             for f=1:Nf
%                 B=[];
%                 s=string({'f', Ff(f)});%���̃e�[�u�����ݒ�
%                 s=join(s,"");%string�����z��̘A��
%                 for t=1:Tm
%                     if Lf(t)==Ff(f)
%                         A=Data(((t-1)*Fs)+1:t*Fs, :);
%                         B=[B; A];
%                     end
%                 end
%                 Dt.(char(s))= B;
%             end
%             
%             obj.TrainingData=Dt;
%             obj.NumberOfFrequency=length(Ff);
%             obj.FlickerFrequency=Ff;
%                  
%         end
        

    end
    
    %% [Public: �g���[�j���O�f�[�^�̎擾���s]
%     methods (Access=public)
%     
%         %�������s
%         function [obj]=TDCMakeClass(obj, TDC)
%             %���������̎擾
%             obj.tdcObject=TDC;
%             
%             switch obj.DataSource
%                 case 'BrainAmp'
%                     [obj, eeg]=obj.brainampsetting;
%                     obj=obj.signalacquire(eeg);
%                     
%                 case 'WFDB'
%                     [obj, eeg]=obj.wfdbsettingparam;
%                     obj=obj.wfdbacquire(eeg);
%             end
%            
%             
% 
%         end
%     end
end

