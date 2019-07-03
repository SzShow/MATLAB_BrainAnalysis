function [A, B, r, U, V] = waveletcca(X,f,Nh,Fs, Win)
%UNTITLED ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q

Ny=length(X(1,:));      %�d�ɐ�
Nt=length(X);           %�f�[�^��
S=zeros(Nt,Ny);   %�o�͂���s��
Y=zeros(Nt,2*Nh);       %mat_Y~�̍ۂɎg�p����fHz�̎O�p�֐�
 T=(1:length(X))'/Fs;
 
for k=1:Nh
    Y(:,(2*k)-1)=Win.*sin(2*pi*k*f*T);
    Y(:,2*k)=Win.*cos(2*pi*k*f*T);
end

[A, B, R, U, V]=canoncorr(X, Y);

r=R;

[~,Ncca]=size(A);
for n=1:Ncca
    A(:,n)=A(:,n)/sqrt(R(n));
    B(:,n)=B(:,n)/sqrt(R(n));
end

U = (X-repmat(mean(X),Nt,1))*A;
V = (Y-repmat(mean(Y),Nt,1))*B;

for n=1:Ncca
    U(:,n)=U(:,n)/norm(U(:,n));
    V(:,n)=V(:,n)/norm(V(:,n));
end
end

