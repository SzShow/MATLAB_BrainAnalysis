function [ S, V, e ] = mec( Y,f,Nh,Fs )
%minimum energy combinationをNt*Ny（データ長*電極数）行列に適用
%
%   [ mat_Smec,D ] = mec( mat_Y,f,Nh,Fs )
%   Ny      :電極数
%   Nt      :データ長
%
%   mat_Smec:mec適用後のデータ行列()
%   D       :固有値(Ny*Nyの対角行列として、(n,n)に小さい順で固有値λnが
%            表示されます)
%   mat_Y   :一つの電極から取ったデータを列ベクトルと見なしたNt*Nyの行列です。
%   f       :SSVEP周波数[Hz]
%   Nh      :考慮する高調波の数(例：f=15[Hz]の場合、Nh=3の時は15[Hz],30[Hz],
%            45[Hz]の成分を残します)
%   Fs      :サンプリング周波数[Hz]
%
%   データ行列mat_Yに対してfHzおよびその高調波の成分を抜いた[mat_Y~]に対して
%   単位ノルムを持つ重みベクトル[w(Ny*1)]を乗算した時のノルムについての
%   最小化問題を解きます。
%       min(w) ||[mat_Y~]*w||^2
%   その時の解は対称行列[mat_Y~'*mat_Y~]に対する最小固有ベクトルとなりますので
%   一つの固有ベクトルを列ベクトルとした後に、対応する固有値が小さい順に
%   重み行列[W(Ny*Ny)]に代入します。
%   最後に
%       mat_Y*W
%   を実行してSSVEPの成分およびNhより指定した高調波成分以外の周波数成分を抑えます。
%   　このアルゴリズムについて直感的な理解を深めるためには特異値分解
%   や主成分分析（PCA）について参照および比較することを強く推奨します．


%変数代入
Ny=length(Y(1,:));      %電極数
Nt=length(Y);           %データ長
mat_X=zeros(Nt,2*Nh);       %mat_Y~の際に使用するfHzの三角関数
T=(1:Nt)/Fs;

%Y~の生成
for k=1:Nh
    mat_X(:,(2*k)-1)=sin(2*pi*k*f*T);
    mat_X(:,2*k)=cos(2*pi*k*f*T);
end
mat_Ytilde=Y-(mat_X/(mat_X'*mat_X)*(mat_X'*Y));


%Nsの生成
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


%重み行列Wの作成
W=zeros(Ny,Ns);         %重み行列
for n=1:Ns
    W(:,n)=V(:,n);
end

S=Y*W;

end

