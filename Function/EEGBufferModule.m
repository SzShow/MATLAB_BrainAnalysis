classdef EEGBufferModule
    %UNTITLED ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties
        WinLength
        Overlap
    end
    
    methods
        function obj = EEGBufferModule(winLen, olap)
            %UNTITLED ���̃N���X�̃C���X�^���X���쐬
            %   �ڍא����������ɋL�q
            obj.WinLength=winLen;
            obj.Overlap=olap;

            
        end
        
        function [Output, Tepo]=divepoch(obj, Input, Ref)
            Fs=Ref.Fs;
            WinLen=obj.WinLength;
            OLap=obj.Overlap;
            [DLen, Nch]=size(Input);
            Nepo=floor((DLen-WinLen*Fs)/(Olap*Fs));
            %�o�͂̃T�C�Y���v�Z
            Output=zeros(WinLen*Fs, Nch, Nepo);
            %�G�|�b�N�̏I���ʒu�̔z��
            Tepo=zeros(Nepo, 1);
            
            %�G�|�b�N�����̊J�n
            for e=1:Nepo
                %�؂���̃X�^�[�g�ʒu��ݒ�
                st=(e-1)*OLap*Fs;
                %e�Ԗڂ̃G�|�b�N�ɐ؂������f�[�^����
                Output(:,:,e)=Input(st+1:st+WinLen*Fs, :);
                Tepo(e)=st+WinLen*Fs;
            end
        end
    end
end

