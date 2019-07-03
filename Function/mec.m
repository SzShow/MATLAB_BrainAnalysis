function [ S, V, e ] = mec( Y,f,Nh,Fs )
%minimum energy combination��Nt*Ny�i�f�[�^��*�d�ɐ��j�s��ɓK�p
%
%   [ mat_Smec,D ] = mec( mat_Y,f,Nh,Fs )
%   Ny      :�d�ɐ�
%   Nt      :�f�[�^��
%
%   mat_Smec:mec�K�p��̃f�[�^�s��()
%   D       :�ŗL�l(Ny*Ny�̑Ίp�s��Ƃ��āA(n,n)�ɏ��������ŌŗL�l��n��
%            �\������܂�)
%   mat_Y   :��̓d�ɂ��������f�[�^���x�N�g���ƌ��Ȃ���Nt*Ny�̍s��ł��B
%   f       :SSVEP���g��[Hz]
%   Nh      :�l�����鍂���g�̐�(��Ff=15[Hz]�̏ꍇ�ANh=3�̎���15[Hz],30[Hz],
%            45[Hz]�̐������c���܂�)
%   Fs      :�T���v�����O���g��[Hz]
%
%   �f�[�^�s��mat_Y�ɑ΂���fHz����т��̍����g�̐����𔲂���[mat_Y~]�ɑ΂���
%   �P�ʃm���������d�݃x�N�g��[w(Ny*1)]����Z�������̃m�����ɂ��Ă�
%   �ŏ������������܂��B
%       min(w) ||[mat_Y~]*w||^2
%   ���̎��̉��͑Ώ̍s��[mat_Y~'*mat_Y~]�ɑ΂���ŏ��ŗL�x�N�g���ƂȂ�܂��̂�
%   ��̌ŗL�x�N�g�����x�N�g���Ƃ�����ɁA�Ή�����ŗL�l������������
%   �d�ݍs��[W(Ny*Ny)]�ɑ�����܂��B
%   �Ō��
%       mat_Y*W
%   �����s����SSVEP�̐��������Nh���w�肵�������g�����ȊO�̎��g��������}���܂��B
%   �@���̃A���S���Y���ɂ��Ē����I�ȗ�����[�߂邽�߂ɂ͓��ْl����
%   ��听�����́iPCA�j�ɂ��ĎQ�Ƃ���є�r���邱�Ƃ������������܂��D


%�ϐ����
Ny=length(Y(1,:));      %�d�ɐ�
Nt=length(Y);           %�f�[�^��
mat_X=zeros(Nt,2*Nh);       %mat_Y~�̍ۂɎg�p����fHz�̎O�p�֐�
T=(1:Nt)/Fs;

%Y~�̐���
for k=1:Nh
    mat_X(:,(2*k)-1)=sin(2*pi*k*f*T);
    mat_X(:,2*k)=cos(2*pi*k*f*T);
end
mat_Ytilde=Y-(mat_X/(mat_X'*mat_X)*(mat_X'*Y));


%Ns�̐���
[V,e]=eig((mat_Ytilde)'*(mat_Ytilde), 'vector');
eigenvalue_sum=sum(e);
eigenvalue_Nsum=0;
for i=1:Ny
    eigenvalue_Nsum=eigenvalue_Nsum+e(i);
    if eigenvalue_Nsum>eigenvalue_sum*0.1
        Ns=i-1;
        break;
    end
end
if Ns==0
    Ns=1;
end


%�d�ݍs��W�̍쐬
W=zeros(Ny,Ns);         %�d�ݍs��
for n=1:Ns
    W(:,n)=V(:,n);
end

S=Y*W;

end

