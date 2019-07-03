function [ T ] = ssvepdft( S,f,Nh,Fs )
%ssvepsnr 
%   �ڍא����������ɋL�q

X=zeros(length(S),2*Nh);

Ny=length(S(1,:));
Nt=length(S);
T=(1:Nt)/Fs;

%�M�������̌v�Z
for k=1:Nh
    X(:,(2*k)-1)=sin(2*pi*k*f*T);
    X(:,2*k)=cos(2*pi*k*f*T);
end

P=zeros(Nh,Ny);
for k=0:Nh-1
    for l=1:Ny
        P(k+1,l)=norm(X(:,2*k+(1:2))'*S(:,l))^2;
    end
end


%�X�y�N�g���̎Z�o
T=0;
for k=1:Nh
    for l=1:Ny
        T=T+(1/Ny*Nh)*(P(k,l));
    end
end
T=mag2db(T);

end

