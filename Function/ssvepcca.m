function [A, B, r, U, V] = ssvepcca(X,f,Nh,Fs)

	Ny=length(X(1,:));      %脳波のチャネル数
	Nt=length(X);           %時間長
	S=zeros(Nt,Ny);   %出力する行列
	Y=zeros(Nt,2*Nh);       %参照データのサイズを確保
	 T=(1:length(X))'/Fs;	%時間ベクトル

	 %SSVEPの為の参照データの生成
	for k=1:Nh
		Y(:,(2*k)-1)=sin(2*pi*k*f*T);
		Y(:,2*k)=cos(2*pi*k*f*T);
	end

	%正準相関分析の実行(X:脳波，Y:SSVEPの為の参照データ)
	%出力A：Xの標本正準係数（空間フィルタのパラメータ）
	%出力B：Yの標本正準係数（フーリエ係数）
	%出力r：相関係数
	%出力U：正準変数（空間フィルタの出力）
	%出力V：スコア（フーリエ級数）
	%
	%詳細は（https://jp.mathworks.com/help/stats/canoncorr.html）を参照．
	[A, B, r, U, V]=canoncorr(X, Y);

end

