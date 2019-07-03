function [A, B, r, U, V] = waveletcca(X,f,Nh,Fs, Win)
%UNTITLED この関数の概要をここに記述
%   詳細説明をここに記述

Ny=length(X(1,:));      %電極数
Nt=length(X);           %データ長
S=zeros(Nt,Ny);   %出力する行列
Y=zeros(Nt,2*Nh);       %mat_Y~の際に使用するfHzの三角関数
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

