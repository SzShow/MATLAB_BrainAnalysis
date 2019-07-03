function [ S, W, E ] = mcc( Y,f,Nh,Fs )
%maximum contrast combinationをNt*Ny（データ長*電極数）行列に適用
%   [ mat_Smcc,D ] = mcc( mat_Y,f,Nh,Fs )
%   Ny      :電極数
%   Nt      :データ長
%
%   mat_Smec:mec適用後のデータ行列()
%   D       :固有値(Ny*Nyの対角行列として、(n,n)に小さい順で固有値λnが
%            表示されます)
%   mat_Y   :一つの電極から取ったデータを列ベクトルと見なしたNt*Nyの行列です。
%   f       :SSVEP周波数[Hz]
%   Nh      :考慮する高調波の数(例：f=15[Hz]の場合、Nh=3の時は15[Hz],30[Hz],
%            45[Hz]の成分を抽出します)
%   Fs      :サンプリング周波数[Hz]
%
%   データ行列mat_Yに対してfHzおよびその高調波の成分を抜いた[mat_Y~]に対して
%   単位ノルムを持つ重みベクトル[w(Ny*1)]を乗算した時のノルムについての
%   最大化問題を解きます。（雑音成分に対するSSVEP成分の比の最大化）
%       max(w) (||mat_Y*w||^2)/(||mat_Y~*w||^2)
%   その時の解は対称行列[mat_Y*mat_Y]と[mat_Y~'*mat_Y~]に対する
%   一般化固有ベクトルの中で最大固有値を持つものとなりますので
%   一つの固有ベクトルを列ベクトルとした後、対応する固有値が大きい順に
%   重み行列[W(Ny*Ny)]に代入します。
%   最後に
%       mat_Y*W
%   を実行してSSVEPの成分およびNhより指定した高調波成分をシグナルとした時の
%   SN比を高めます。


%変数代入
Ny=length(Y(1,:));      %電極数
Nt=length(Y);           %データ長
S=zeros(length(Y),Ny);   %出力する行列
mat_X=zeros(Nt,2*Nh);       %mat_Y~の際に使用するfHzの三角関数
T=(1:Nt)/Fs;

%mat_Y~の作成
for k=1:Nh
    mat_X(:,(2*k)-1)=sin(2*pi*k*f*T);
    mat_X(:,2*k)=cos(2*pi*k*f*T);
end
mat_Ytilde=Y-(mat_X/(mat_X'*mat_X)*(mat_X'*Y));

%Nsの計算
[V,e]=eig(Y'*Y,(mat_Ytilde)'*(mat_Ytilde), 'vector');
MCCth=Nt/(Nt-2*Nh);
Ns=0;
for n=length(e):-1:1
    if e(n)<MCCth
        break;
    end
    Ns=Ns+1;
end

%重み行列Wの作成
 W=zeros(Ny,Ny);         %重み行列
E=zeros(Ny, 1);
 for n=length(e):-1:1
     W(:,length(e)-n+1)=V(:,n)/sqrt(e(n));
     E(length(e)-n+1)=e(n);
 end

S=Y*W;

end

