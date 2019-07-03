classdef EpochDivider
    %UNTITLED ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties
        timePerEpoch	%�P�G�|�b�N���Ƃ̎��Ԓ�
        overlapRate		%�O�̃G�|�b�N�Ǝ��̃G�|�b�N�̏d�Ȃ藦
    end
    
    methods
		%�R���X�g���N�^
        function obj=EpochDivider(t, r)
            obj.timePerEpoch=t;
            obj.overlapRate=r;
        end
        
        %�G�|�b�N�����̎��s
        function o=EpochDivide(obj, input)
            %�o�̓������̊m��
            o=input;
            
            %�����f�[�^���Ƃɐ؂���J�n
            for n=1:length(input)
                o{n}=obj.StartDivide(input{n});
            end
            
        end
    end
    
    methods (Access = private)
		
		%�G�|�b�N�����̎��s
        function output=StartDivide(obj, input)
            %���[�J���ϐ�����
            output=input;	%�o�͂̌^�����킹��
            S=input.Signal;	%�]�g
            Ns=length(S);	%�]�g�̒���
            Te=obj.timePerEpoch;	%1�G�|�b�N�̒���
            Fs=input.SamplingFreq;	%�T���v�����O���g��
            Ro=obj.overlapRate;	%�G�|�b�N�̏d�Ȃ藦
            Nc=size(S, 2);	%�]�g�̃`���l����
            
            %�G�|�b�N��Ne�̌v�Z
            MovableLength=Ns-(Te*Fs);	%����Te*Fs�̃G�|�b�N�̏I�_��������͈�
			MoveSpeed=round(Te*Fs*Ro);	%�d�Ȃ藦�ƒ������O�̃G�|�b�N��
								%���̃G�|�b�N�̏I�_�̋������v�Z
            Ne=floor(MovableLength / MoveSpeed);	%���܂ł̃G�|�b�N�Ȃ���邩�v�Z
            
			%�o�͕ϐ��̊m��
			%�c�̒�����1�G�|�b�N�̒���
			%���̒������`���l����
			%���s���̒������G�|�b�N�̒���
            output.Signal=zeros(Te*Fs, Nc, Ne);
            
            %�G�|�b�N�I�_�̈ʒu�z��̊m��
            output.EpochTimeList=zeros(Te, 1);
            
            %�G�|�b�N�����̎��s
            for e=1:Ne
                %e�Ԗڂ̃G�|�b�N�̐؂���J�n�ʒu
                p=(e-1)*Te*Fs*Ro;
                %�f�[�^���
                output.Signal(:,:,e) = S((p+1):(p+(Te*Fs)), :);	%e�Ԗڂ̃G�|�b�N�ɔg�`���
                output.EpochTimeList(e) = (p+(Te*Fs))/Fs;	%e�Ԗڂ̃G�|�b�N�̏I�_�����b�����
            end
            
        end
        
    end
    
end

