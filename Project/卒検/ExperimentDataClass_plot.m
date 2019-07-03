classdef ExperimentDataClass_plot
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
        Filename        %�ǂݍ��݃t�@�C��
        Fs              %�T���v�����O���g��
        Ts              %�v������
        El              %�d�Ɉʒu�Ɣԍ��̑Ή��\
        Ff              %�_�Ŏ��g��
        Stimulus        %���݂̓_�Ŏ��g��  
        
        %I:�擾����
        To              %�g���K�[����̃I�t�Z�b�g
        Tw              %���ԑ��̒���
        Ti              %��͊Ԋu
        W               %���֐�
        
        %O:�v���f�[�^
        Y               %�f�[�^�s�� 
        Ny              %�d�ɐ�
        Nt              %�f�[�^��
        Np              %�f�[�^�̑�������
        Nw              %�����ς݃f�[�^�̃T���v����
        Fp              %�e�f�[�^�擾���̓_�Ŏ��g��
        Ta
        T              %���ԏ��x�N�g��
        
        %O:�t�����
        Date            %������
        Title           %������
        Subject         %�팱�Ҕԍ�
        TrialNumber     %���s�ԍ�
        
        
    end
    properties(Dependent)

    end
    
    methods
        %%
        %�f�[�^�̐؂��蕪������
        function [obj]=dividedata(obj, eeg)
            %�ŏ��̃g���K�[���o�����̎擾
            Start=0;
            for i=1:length(eeg)
                if(eeg([obj.Ny]+1,i)==1)
                    Start=i;
                    break;
                end
            end
            
            %�����f�[�^�̐؂���
            Data=zeros([obj.Nt],[obj.Ny]);
            Offset=[obj.To]*[obj.Fs];
            Ps=Start-Offset;
            for i=1:obj.Ny                      
                Data(:,i)=eeg(i,Ps:(Ps+obj.Nt)-1)';
            end
            
            %�����f�[�^�̕���
            obj.Np=length(obj.Tw:obj.Ti:obj.Ts);
            Data2=zeros([obj.Tw]*[obj.Fs], [obj.Ny], obj.Np);
            try
                for i=1:obj.Np
                    Data2(:,:,i)=Data((i-1)*[obj.Fs]*[obj.Ti]+1:(i-1)*[obj.Fs]*[obj.Ti]+([obj.Tw]*[obj.Fs]), :);
                end
            catch
            end
            obj.T=-obj.To+obj.Tw:obj.Ti:-obj.To+obj.Ts;
            obj.Nw=obj.Tw*obj.Fs;
            [obj.Y]=Data2;            
        end
        
        %%
        %�������s
        function [obj]=operate(obj)
            %���������̎擾
            load([obj.Filename]);
            [obj.Nt]=[obj.Ts]*[obj.Fs];
            obj.Ta=1/obj.Fs-obj.To:1/obj.Fs:obj.Ts-obj.To;
            
            %�t�����̎擾
            C1=strsplit([obj.Filename],'_');
            C2=strsplit(C1{1,4},'.');
            [obj.Date]=C1{1,1};
            [obj.Title]=C1{1,2};
            [obj.Subject]=C1{1,3};
            [obj.TrialNumber]=C2{1,1};
            
            %�v���f�[�^�̕���
            obj=obj.dividedata(eeg);
            
            %�_�ŏ��̎擾
            obj.Fp=zeros(obj.Np, 1);
            for p=1:obj.Np
                t=ceil(obj.Ti*p-obj.To);
                obj.Fp(p)=obj.Stimulus(t);
            end
        end
    end
    
end

