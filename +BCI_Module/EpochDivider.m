classdef EpochDivider
    %UNTITLED このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
        timePerEpoch	%１エポックごとの時間長
        overlapRate		%前のエポックと次のエポックの重なり率
    end
    
    methods
		%コンストラクタ
        function obj=EpochDivider(t, r)
            obj.timePerEpoch=t;
            obj.overlapRate=r;
        end
        
        %エポック分割の実行
        function o=EpochDivide(obj, input)
            %出力メモリの確保
            o=input;
            
            %実験データごとに切り取り開始
            for n=1:length(input)
                o{n}=obj.StartDivide(input{n});
            end
            
        end
    end
    
    methods (Access = private)
		
		%エポック分割の実行
        function output=StartDivide(obj, input)
            %ローカル変数生成
            output=input;	%出力の型をあわせる
            S=input.Signal;	%脳波
            Ns=length(S);	%脳波の長さ
            Te=obj.timePerEpoch;	%1エポックの長さ
            Fs=input.SamplingFreq;	%サンプリング周波数
            Ro=obj.overlapRate;	%エポックの重なり率
            Nc=size(S, 2);	%脳波のチャネル長
            
            %エポック数Neの計算
            MovableLength=Ns-(Te*Fs);	%長さTe*Fsのエポックの終点が動ける範囲
			MoveSpeed=round(Te*Fs*Ro);	%重なり率と長さより前のエポックと
								%次のエポックの終点の距離を計算
            Ne=floor(MovableLength / MoveSpeed);	%何個までのエポックなら作れるか計算
            
			%出力変数の確保
			%縦の長さ＝1エポックの長さ
			%横の長さ＝チャネル長
			%奥行きの長さ＝エポックの長さ
            output.Signal=zeros(Te*Fs, Nc, Ne);
            
            %エポック終点の位置配列の確保
            output.EpochTimeList=zeros(Te, 1);
            
            %エポック分割の実行
            for e=1:Ne
                %e番目のエポックの切り取り開始位置
                p=(e-1)*Te*Fs*Ro;
                %データ代入
                output.Signal(:,:,e) = S((p+1):(p+(Te*Fs)), :);	%e番目のエポックに波形代入
                output.EpochTimeList(e) = (p+(Te*Fs))/Fs;	%e番目のエポックの終点が何秒か代入
            end
            
        end
        
    end
    
end

