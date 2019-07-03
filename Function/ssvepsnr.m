function [ T ] = ssvepsnr( mat_S,f,Nh,Fs )
%ssvepsnr 
%   �ڍא����������ɋL�q

X=zeros(length(mat_S),2*Nh);

Ny=length(mat_S(1,:));
Nt=length(mat_S);
T=(1:Nt)/Fs;

%�M�������̌v�Z
for k=1:Nh
    X(:,(2*k)-1)=sin(2*pi*k*f*T);
    X(:,2*k)=cos(2*pi*k*f*T);
end

P=zeros(Nh,Ny);
for k=0:Nh-1
    for l=1:Ny
        P(k+1,l)=norm(X(:,2*k+(1:2))'*mat_S(:,l))^2;
    end
end

%�G�������̌v�Z
mat_Stilde=mat_S-(X*inv(X'*X)*(X'*mat_S));
A=zeros(Nh,Ny);
Nl=zeros(Nh,Ny);
ARp=15;
for l=1:Ny
    [a,e]=aryule(mat_Stilde(:,l),ARp);
    for k=1:Nh
        for p=1:ARp
            A(k,l)=A(k,l)+a(p)*exp(-2*pi*1i*p*k*f/Fs);
        end
        Nl(k,l)=(pi*Nt/4)*(e/abs(1+A(k,l))^2);
    end
end

%SN��̎Z�o
T=0;
for k=1:Nh
    for l=1:Ny
        T=T+(1/Ny*Nh)*(P(k,l)/Nl(k,l));
    end
end
T=mag2db(T);

end

