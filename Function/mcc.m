function [ S, W, E ] = mcc( Y,f,Nh,Fs )
%maximum contrast combination��Nt*Ny�i�f�[�^��*�d�ɐ��j�s��ɓK�p
%   [ mat_Smcc,D ] = mcc( mat_Y,f,Nh,Fs )
%   Ny      :�d�ɐ�
%   Nt      :�f�[�^��
%
%   mat_Smec:mec�K�p��̃f�[�^�s��()
%   D       :�ŗL�l(Ny*Ny�̑Ίp�s��Ƃ��āA(n,n)�ɏ��������ŌŗL�l��n��
%            �\������܂�)
%   mat_Y   :��̓d�ɂ��������f�[�^���x�N�g���ƌ��Ȃ���Nt*Ny�̍s��ł��B
%   f       :SSVEP���g��[Hz]
%   Nh      :�l�����鍂���g�̐�(��Ff=15[Hz]�̏ꍇ�ANh=3�̎���15[Hz],30[Hz],
%            45[Hz]�̐����𒊏o���܂�)
%   Fs      :�T���v�����O���g��[Hz]
%
%   �f�[�^�s��mat_Y�ɑ΂���fHz����т��̍����g�̐����𔲂���[mat_Y~]�ɑ΂���
%   �P�ʃm���������d�݃x�N�g��[w(Ny*1)]����Z�������̃m�����ɂ��Ă�
%   �ő剻���������܂��B�i�G�������ɑ΂���SSVEP�����̔�̍ő剻�j
%       max(w) (||mat_Y*w||^2)/(||mat_Y~*w||^2)
%   ���̎��̉��͑Ώ̍s��[mat_Y*mat_Y]��[mat_Y~'*mat_Y~]�ɑ΂���
%   ��ʉ��ŗL�x�N�g���̒��ōő�ŗL�l�������̂ƂȂ�܂��̂�
%   ��̌ŗL�x�N�g�����x�N�g���Ƃ�����A�Ή�����ŗL�l���傫������
%   �d�ݍs��[W(Ny*Ny)]�ɑ�����܂��B
%   �Ō��
%       mat_Y*W
%   �����s����SSVEP�̐��������Nh���w�肵�������g�������V�O�i���Ƃ�������
%   SN������߂܂��B


%�ϐ����
Ny=length(Y(1,:));      %�d�ɐ�
Nt=length(Y);           %�f�[�^��
S=zeros(length(Y),Ny);   %�o�͂���s��
mat_X=zeros(Nt,2*Nh);       %mat_Y~�̍ۂɎg�p����fHz�̎O�p�֐�
T=(1:Nt)/Fs;

%mat_Y~�̍쐬
for k=1:Nh
    mat_X(:,(2*k)-1)=sin(2*pi*k*f*T);
    mat_X(:,2*k)=cos(2*pi*k*f*T);
end
mat_Ytilde=Y-(mat_X/(mat_X'*mat_X)*(mat_X'*Y));

%Ns�̌v�Z
[V,e]=eig(Y'*Y,(mat_Ytilde)'*(mat_Ytilde), 'vector');
MCCth=Nt/(Nt-2*Nh);
Ns=0;
for n=length(e):-1:1
    if e(n)<MCCth
        break;
    end
    Ns=Ns+1;
end

%�d�ݍs��W�̍쐬
 W=zeros(Ny,Ny);         %�d�ݍs��
E=zeros(Ny, 1);
 for n=length(e):-1:1
     W(:,length(e)-n+1)=V(:,n)/sqrt(e(n));
     E(length(e)-n+1)=e(n);
 end

S=Y*W;

end

