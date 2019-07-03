classdef CCAModule < BCI_Module.ProcessingModule
    %CCAModule 入力された脳波にCCAを適用
    %   入力された脳波にSSVEP対応の正準相関分析を適用します
    %   入力データを短時間の多チャネル脳波とし，
    %   参照データを調べたい周波数の正弦波・余弦波およびその高調波としています．
    %   BCIに組み込む前にコンストラクタに
    %   （調べたい周波数，高調波の数，出力するチャネル数，出力したいデータ，
    %   適用する窓関数）
    %   を入力してください．
    %   また，正準相関分析の説明は
    %   https://www.jstage.jst.go.jp/article/jnns/20/2/20_62/_pdf
    %   が分かりやすく，SSVEPへの応用例は
    %   https://arxiv.org/abs/1308.5609
    %   などに記載されています．
    %
    %   記入例１．（7Hzと14Hzを調べる）
    %   of = [ECCAOutput.SpatialFilter ECCAOutput.CorrelationEfficient];
    %   Mod = CCAModule(7, 2, 2, of, EWindowList.Hann)
    %
    %   記入例２．（7Hz,14Hz,15Hz,30Hzを調べる）
    %   of = [ECCAOutput.SpatialFilter ECCAOutput.CorrelationEfficient];
    %   Mod = CCAModule([7 15], 2, 2, of, EWindowList.Hann)
    %
    %   記入例３．（7Hz,14Hz,15Hzを調べる）
    %   of = [ECCAOutput.SpatialFilter ECCAOutput.CorrelationEfficient];
    %   Mod = CCAModule([7 15], [2 1], 2, of, EWindowList.Hann)
    
     
	properties (SetAccess=private)
		SamplingFreq 	%サンプリング周波数
        Freq    %調べたい周波数
        Harmonics   %基本波＋高調波の数
        SignalNum   %出力するチャネルの数
        OutputFeature   %出力する特徴量
        SignalRule  %今回は未使用
        Window      %使用する窓関数
	end
	
	properties (Dependent)
		FilterNum   %調べたい周波数の数
		WavePos     %脳波が何番目の特徴量にあたるか
	end
	
	%getメソッド
	methods 
		%入力された周波数の数からフィルタの数を計算
		function output = get.FilterNum(obj)
			output = length(obj.Freq);
		end
		
		%脳波にあたる特徴量を検出
		function output = get.WavePos(obj)
			import BCI_Module.ECCAOutput
            for index=1:length(obj.OutputFeature)
                if obj.OutputFeature(index) == ECCAOutput.FilterOutput
                    output=index;
                    return
                end
            end
            output = NaN;
		end

	end

	%setメソッド
	methods 

		%高調波の処理
		%Freqプロパティの要素数に合わせるために
		%条件分岐しています．
		function obj =set.Harmonics(obj, h)
            if length(h)==1
                obj.Harmonics=ones(obj.FilterNum, 1)*h;
            elseif length(h)==obj.FilterNum 
                obj.Harmonics=h;
            else
                error('引数hの長さが不適切です');
            end
		end

		%取りたいチャネル数の処理
		function obj = set.SignalNum(obj, s)
            if length(s)==1
                obj.SignalNum=ones(obj.FilterNum, 1)*s;
            elseif length(s)==obj.FilterNum 
                obj.SignalNum=s;
            else
                error('引数hの長さが不適切です');
            end
			
		end

	end

     %コンストラクタ
    methods (Access=public)
        function obj=CCAModule(f,h,s,of, win)          
            %プロパティのセット
            obj.Freq=f;
            obj.Harmonics = h;
            obj.SignalNum = s;
            obj.OutputFeature=of;
            obj.Window=win;
        end
    end
	
	%実行メソッド
    methods (Access=protected)
		function output = operate(obj,input)
			%列挙体のインポート
            import BCI_Module.ECCAOutput
			
			%EEGクラスからサンプリング周波数を取得
            obj.SamplingFreq=input.SamplingFreq;

            %出力と信号の初期設定
            output=input;
            S=input.Signal;
            S=obj.setwindow(S);

			%ローカル変数の設定
            Nepo=input.EpochNum;
            %Fout=obj.OutputFeature;
                       
            %各フィルタのチャネル幅を計算
            CCANum = obj.clacccanum(input);

            %出力サイズの確保
            output.Signal=obj.SaveFilterOutput(input, CCANum);
            output.WavePos=obj.WavePos;

            %周波数ごとに処理
            ssvepFreq=obj.Freq;
            ssvepHarmonics=obj.Harmonics;
            for n=1:length(ssvepFreq)
                f=ssvepFreq(n);
                h=ssvepHarmonics(n);
                %エポック毎にCCA適用
                for epoch=1:Nepo
                    [A,B,r,U,V]=obj.cca(S(:,:,epoch),f,h);
                    for index=1:length(obj.OutputFeature)
                        temp=output.Signal{index,n};
                        switch obj.OutputFeature(index)
                            case ECCAOutput.SpatialFilter
                                temp(:,:,epoch)=A(:,1:CCANum(n));

                            case ECCAOutput.FourierEfficient
                                temp(:,:,epoch)=B(:,1:CCANum(n));

                            case ECCAOutput.CorrelationEfficient
                                temp(:,:,epoch)=r(:,1:CCANum(n));

                            case ECCAOutput.FilterOutput
                                temp(:,:,epoch)=U(:,1:CCANum(n));

                            case ECCAOutput.FourierSeries
                                temp(:,:,epoch)=V(:,1:CCANum(n));
                        end
                        output.Signal{index,n}(:,:,epoch)=temp(:,:,epoch);
                    end

                end
				output.FeatureInfo = obj.setfeatureinfo(output.Signal);
                
            end
       
        end
        
    end
    
    methods (Access=private)
        %出力として，[出力する特徴量の種数, 対象周波数の種数]の
        %長さを持つセルを返します．
        %各セルには[特徴量の長さ，特徴量の数，エポック数]の長さを持つ
		%3次元のデータが含まれています．
		
		%各フィルタのチャネル幅を計算
		function output = clacccanum(obj, input)
			%ローカル変数の設定
			Nfilt=obj.FilterNum;
			Nch=ones(Nfilt, 1)*input.ChanelNum;
			Nharm=obj.Harmonics;
			Ns=obj.SignalNum;
			
			%出力サイズの確保
			output=zeros(Nfilt, 1);
			
			%各フィルタ毎に出力のチャネルサイズを計算
			for index=1:Nfilt
				%脳波のチャネル幅，リファレンス信号のチャネル幅，
				%ユーザが要求するチャネル数の内の最小値を計算
                output(index)=min([Nch(index), 2*Nharm(index), Ns(index)]);
			end

		end

        function o=SaveFilterOutput(obj, input, CCANum)

            import BCI_Module.ECCAOutput
            
            %ローカル変数
			Nfilt=obj.FilterNum;
            Nsig=length(obj.OutputFeature);	
            Nfreq=length(obj.Freq);
			Nharm=obj.Harmonics;
			Nepo=input.EpochNum;
			Nch=ones(Nfilt, 1)*input.ChanelNum;
			Nsamp=input.SignalNum;

            %出力のセル数の確保
            o=cell(Nsig, 1);

            %各セル内のデータサイズの確保
            for f=1:Nfreq
                for index=1:Nsig
                    %ほしい出力の種類に応じて場合分け
                    switch obj.OutputFeature(index)
                        case ECCAOutput.SpatialFilter
                            x=Nch(f);
                            y=CCANum(f);
                            z=Nepo;                        
                        case ECCAOutput.FourierEfficient
                            x=2*Nharm(f);
                            y=CCANum(f);
                            z=Nepo;                        
                        case ECCAOutput.CorrelationEfficient
                            x=1;
                            y=CCANum(f);
                            z=Nepo;                        
                        case ECCAOutput.FilterOutput
                            x=Nsamp;
                            y=CCANum(f);
                            z=Nepo;                       
                        case ECCAOutput.FourierSeries
                            x=Nsamp;
                            y=CCANum(f);
                            z=Nepo;
                    end
                    o{index, f}=zeros(x,y,z);
                end
            end
        end


        function [A, B, r, U, V, Ns]=cca(obj, Y, f, Nh)
            [A, B, r, U, V]=ssvepcca(Y, f, Nh, obj.SamplingFreq);
            Ns=length(U(1, :));
		end        
		
		function output = setfeatureinfo(obj, S)

			%Table配列の要素のサイズを確保
			FeatureName = zeros(numel(S), 1);
			FeatureLength = zeros(numel(S), 1);

			%Sのcolの特徴量の名前と長さを調べる
			n = 1;
			for row = 1:size(S, 2)
				for col= 1:size(S, 1)
					FeatureName(n) = obj.OutputFeature(col);
					FeatureLength(n) = size(S{col, row}, 1);
					n = n + 1;
				end
			end

			output = table(FeatureName, FeatureLength);

		end

    end
    
end

