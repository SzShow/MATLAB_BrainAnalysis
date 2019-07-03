function [A, B, r, U, V] = ssvepcca(X,f,Nh,Fs)

	Ny=length(X(1,:));      %�]�g�̃`���l����
	Nt=length(X);           %���Ԓ�
	S=zeros(Nt,Ny);   %�o�͂���s��
	Y=zeros(Nt,2*Nh);       %�Q�ƃf�[�^�̃T�C�Y���m��
	 T=(1:length(X))'/Fs;	%���ԃx�N�g��

	 %SSVEP�ׂ̈̎Q�ƃf�[�^�̐���
	for k=1:Nh
		Y(:,(2*k)-1)=sin(2*pi*k*f*T);
		Y(:,2*k)=cos(2*pi*k*f*T);
	end

	%�������֕��͂̎��s(X:�]�g�CY:SSVEP�ׂ̈̎Q�ƃf�[�^)
	%�o��A�FX�̕W�{�����W���i��ԃt�B���^�̃p�����[�^�j
	%�o��B�FY�̕W�{�����W���i�t�[���G�W���j
	%�o��r�F���֌W��
	%�o��U�F�����ϐ��i��ԃt�B���^�̏o�́j
	%�o��V�F�X�R�A�i�t�[���G�����j
	%
	%�ڍׂ́ihttps://jp.mathworks.com/help/stats/canoncorr.html�j���Q�ƁD
	[A, B, r, U, V]=canoncorr(X, Y);

end

